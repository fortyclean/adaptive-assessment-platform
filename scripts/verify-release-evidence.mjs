#!/usr/bin/env node
import { existsSync, readFileSync } from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = path.resolve(__dirname, '..');
const strict = process.argv.includes('--strict');
const evidenceArgIndex = process.argv.findIndex((arg) => arg === '--evidence');
const evidencePath = path.resolve(
  repoRoot,
  evidenceArgIndex >= 0 && process.argv[evidenceArgIndex + 1]
    ? process.argv[evidenceArgIndex + 1]
    : 'qa-artifacts/release-validation/release-evidence.json',
);

const requiredDocs = [
  'release/internal-beta-runbook.md',
  'release/onesignal-dashboard-validation.md',
  'release/sentry-beta-validation.md',
  'release/release-evidence-template.json',
];

const blockers = [];
const warnings = [];
const evidenceDir = path.join(repoRoot, 'qa-artifacts', 'release-validation');
const textEvidenceExtensions = new Set([
  '.csv',
  '.json',
  '.log',
  '.md',
  '.txt',
  '.xml',
  '.yaml',
  '.yml',
]);
const sensitiveEvidencePatterns = [
  { label: 'email address', pattern: /[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}/i },
  {
    label: 'phone number',
    pattern: /(?:\+?\d[\s().-]*){9,}\d/,
  },
  {
    label: 'OpenAI/GitHub/Slack-style token',
    pattern: /\b(?:sk|sk-proj|ghp|github_pat|xoxb|xoxp)_[A-Za-z0-9_-]{10,}\b/,
  },
  {
    label: 'bearer token',
    pattern: /\bAuthorization\s*:\s*Bearer\s+[A-Za-z0-9._~+/=-]{10,}/i,
  },
  {
    label: 'JWT-like token',
    pattern: /\beyJ[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}\b/,
  },
  {
    label: 'Sentry DSN assignment',
    pattern: /\bSENTRY_DSN\b\s*[:=]\s*\S+/i,
  },
  {
    label: 'OneSignal secret key',
    pattern: /\bONESIGNAL_(?:REST_API_KEY|USER_AUTH_KEY|API_KEY)\b\s*[:=]/i,
  },
];

for (const doc of requiredDocs) {
  if (!existsSync(path.join(repoRoot, doc))) {
    blockers.push(`Missing release validation document: ${doc}`);
  }
}

let evidence = null;
if (!existsSync(evidencePath)) {
  warnings.push(
    `No filled release evidence file found at ${path.relative(repoRoot, evidencePath)}. ` +
      'Copy release/release-evidence-template.json there after the external Beta checks are executed.',
  );
} else {
  try {
    evidence = JSON.parse(readFileSync(evidencePath, 'utf8'));
  } catch (error) {
    blockers.push(`Release evidence file is not valid JSON: ${error.message}`);
  }
}

function requireTrue(pathLabel, value) {
  if (value !== true) blockers.push(`${pathLabel} must be true`);
}

function requireText(pathLabel, value) {
  if (typeof value !== 'string' || value.trim().length === 0) {
    blockers.push(`${pathLabel} must be filled`);
  }
}

function requireEvidenceFile(pathLabel, value, options = {}) {
  requireText(pathLabel, value);
  if (typeof value !== 'string' || value.trim().length === 0) return;

  const normalizedValue = value.replaceAll('\\', '/');
  const absolutePath = path.resolve(repoRoot, normalizedValue);
  const relativePath = path.relative(repoRoot, absolutePath);
  const relativeToEvidenceDir = path.relative(evidenceDir, absolutePath);

  if (relativeToEvidenceDir.startsWith('..') || path.isAbsolute(relativeToEvidenceDir)) {
    blockers.push(`${pathLabel} must point inside qa-artifacts/release-validation`);
    return;
  }

  if (!existsSync(absolutePath)) {
    blockers.push(`${pathLabel} file does not exist: ${relativePath}`);
    return;
  }

  if (!options.scanForSensitiveData) return;

  const extension = path.extname(absolutePath).toLowerCase();
  if (!textEvidenceExtensions.has(extension)) {
    warnings.push(
      `${pathLabel} uses a non-text evidence file; verify manually that it is redacted: ${relativePath}`,
    );
    return;
  }

  const content = readFileSync(absolutePath, 'utf8');
  for (const { label, pattern } of sensitiveEvidencePatterns) {
    if (pattern.test(content)) {
      blockers.push(`${pathLabel} appears to contain sensitive data (${label}): ${relativePath}`);
    }
  }
}

function requireAndroidNotificationEvidence(android) {
  if (android?.notificationPermissionGranted === true) return;

  if (
    android?.notificationPermissionStatus === 'not_applicable_android_below_33' &&
    typeof android?.notificationPermissionEvidencePath === 'string' &&
    android.notificationPermissionEvidencePath.trim().length > 0
  ) {
    requireEvidenceFile(
      'android.notificationPermissionEvidencePath',
      android.notificationPermissionEvidencePath,
      { scanForSensitiveData: true },
    );
    return;
  }

  blockers.push(
    'android.notificationPermissionGranted must be true, or ' +
      'android.notificationPermissionStatus must be not_applicable_android_below_33 ' +
      'with android.notificationPermissionEvidencePath filled',
  );
}

if (evidence) {
  requireText('ci.runNumber', evidence.ci?.runNumber);
  requireText('ci.commit', evidence.ci?.commit);
  requireTrue('ci.backendBuildAndTest', evidence.ci?.backendBuildAndTest);
  requireTrue('ci.flutterAnalyzeAndTest', evidence.ci?.flutterAnalyzeAndTest);
  requireTrue('ci.productionSecretScan', evidence.ci?.productionSecretScan);

  requireText('android.physicalDeviceModel', evidence.android?.physicalDeviceModel);
  requireTrue('android.apkInstalled', evidence.android?.apkInstalled);
  requireTrue('android.roleSmokeJourneysPassed', evidence.android?.roleSmokeJourneysPassed);
  requireAndroidNotificationEvidence(evidence.android);

  requireTrue('oneSignal.dashboardPushSent', evidence.oneSignal?.dashboardPushSent);
  requireTrue(
    'oneSignal.dashboardPushReceivedOnDevice',
    evidence.oneSignal?.dashboardPushReceivedOnDevice,
  );
  requireTrue('oneSignal.notificationTapOpenedApp', evidence.oneSignal?.notificationTapOpenedApp);
  requireEvidenceFile('oneSignal.evidencePath', evidence.oneSignal?.evidencePath, {
    scanForSensitiveData: evidence.oneSignal?.containsNoSecretsOrPii === true,
  });
  requireTrue('oneSignal.containsNoSecretsOrPii', evidence.oneSignal?.containsNoSecretsOrPii);

  requireTrue('sentry.authorizedBetaDsnUsed', evidence.sentry?.authorizedBetaDsnUsed);
  requireTrue('sentry.syntheticEventSent', evidence.sentry?.syntheticEventSent);
  requireTrue('sentry.syntheticEventReceived', evidence.sentry?.syntheticEventReceived);
  requireEvidenceFile('sentry.evidencePath', evidence.sentry?.evidencePath, {
    scanForSensitiveData: evidence.sentry?.containsNoSecretsOrPii === true,
  });
  requireTrue('sentry.containsNoSecretsOrPii', evidence.sentry?.containsNoSecretsOrPii);

  requireText('internalBeta.distributionChannel', evidence.internalBeta?.distributionChannel);
  requireText('internalBeta.releaseOwner', evidence.internalBeta?.releaseOwner);
  requireTrue('internalBeta.releaseOwnerApproved', evidence.internalBeta?.releaseOwnerApproved);
  requireTrue('internalBeta.rollbackPlanReviewed', evidence.internalBeta?.rollbackPlanReviewed);
  requireTrue('internalBeta.supportContactReady', evidence.internalBeta?.supportContactReady);
  requireEvidenceFile('internalBeta.evidencePath', evidence.internalBeta?.evidencePath, {
    scanForSensitiveData: true,
  });
}

console.log('Release evidence gate');
console.log('=====================');
console.log(`Evidence file: ${path.relative(repoRoot, evidencePath)}`);

if (warnings.length > 0) {
  console.log('\nWarnings:');
  for (const warning of warnings) console.log(`- ${warning}`);
}

if (blockers.length > 0) {
  console.log('\nBlockers:');
  for (const blocker of blockers) console.log(`- ${blocker}`);
} else {
  console.log('\nAll release evidence checks passed.');
}

if (strict && (warnings.length > 0 || blockers.length > 0)) {
  process.exit(1);
}
