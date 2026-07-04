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

function requireAndroidNotificationEvidence(android) {
  if (android?.notificationPermissionGranted === true) return;

  if (
    android?.notificationPermissionStatus === 'not_applicable_android_below_33' &&
    typeof android?.notificationPermissionEvidencePath === 'string' &&
    android.notificationPermissionEvidencePath.trim().length > 0
  ) {
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
  requireText('oneSignal.evidencePath', evidence.oneSignal?.evidencePath);
  requireTrue('oneSignal.containsNoSecretsOrPii', evidence.oneSignal?.containsNoSecretsOrPii);

  requireTrue('sentry.authorizedBetaDsnUsed', evidence.sentry?.authorizedBetaDsnUsed);
  requireTrue('sentry.syntheticEventSent', evidence.sentry?.syntheticEventSent);
  requireTrue('sentry.syntheticEventReceived', evidence.sentry?.syntheticEventReceived);
  requireText('sentry.evidencePath', evidence.sentry?.evidencePath);
  requireTrue('sentry.containsNoSecretsOrPii', evidence.sentry?.containsNoSecretsOrPii);

  requireText('internalBeta.distributionChannel', evidence.internalBeta?.distributionChannel);
  requireText('internalBeta.releaseOwner', evidence.internalBeta?.releaseOwner);
  requireTrue('internalBeta.releaseOwnerApproved', evidence.internalBeta?.releaseOwnerApproved);
  requireTrue('internalBeta.rollbackPlanReviewed', evidence.internalBeta?.rollbackPlanReviewed);
  requireTrue('internalBeta.supportContactReady', evidence.internalBeta?.supportContactReady);
  requireText('internalBeta.evidencePath', evidence.internalBeta?.evidencePath);
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
