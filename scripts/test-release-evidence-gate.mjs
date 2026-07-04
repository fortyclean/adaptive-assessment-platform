#!/usr/bin/env node
import { mkdirSync, rmSync, writeFileSync } from 'node:fs';
import { spawnSync } from 'node:child_process';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = path.resolve(__dirname, '..');
const testDir = path.join(repoRoot, 'qa-artifacts', 'release-validation', 'self-test');

function writeJson(filePath, value) {
  writeFileSync(filePath, `${JSON.stringify(value, null, 2)}\n`);
}

function baseEvidence(overrides = {}) {
  return {
    release: 'self-test',
    packageId: 'com.adaptivemastery.app',
    ci: {
      runNumber: 'self-test',
      commit: '0000000',
      backendBuildAndTest: true,
      flutterAnalyzeAndTest: true,
      productionSecretScan: true,
    },
    android: {
      physicalDeviceModel: 'Self Test Android',
      apkInstalled: true,
      roleSmokeJourneysPassed: true,
      notificationPermissionGranted: false,
      notificationPermissionStatus: 'not_applicable_android_below_33',
      notificationPermissionEvidencePath:
        'qa-artifacts/release-validation/self-test/android-notification.txt',
    },
    oneSignal: {
      dashboardPushSent: true,
      dashboardPushReceivedOnDevice: true,
      notificationTapOpenedApp: true,
      evidencePath: 'qa-artifacts/release-validation/self-test/onesignal.txt',
      containsNoSecretsOrPii: true,
    },
    sentry: {
      authorizedBetaDsnUsed: true,
      syntheticEventSent: true,
      syntheticEventReceived: true,
      evidencePath: 'qa-artifacts/release-validation/self-test/sentry.txt',
      containsNoSecretsOrPii: true,
    },
    internalBeta: {
      distributionChannel: 'internal-test',
      releaseOwner: 'release-owner',
      releaseOwnerApproved: true,
      rollbackPlanReviewed: true,
      supportContactReady: true,
      evidencePath: 'qa-artifacts/release-validation/self-test/internal-beta.txt',
    },
    ...overrides,
  };
}

function runGate(evidenceFile) {
  return spawnSync(
    process.execPath,
    ['scripts/verify-release-evidence.mjs', '--strict', '--evidence', evidenceFile],
    {
      cwd: repoRoot,
      encoding: 'utf8',
    },
  );
}

function assert(condition, message) {
  if (!condition) {
    throw new Error(message);
  }
}

function writeSafeEvidenceFiles() {
  writeFileSync(
    path.join(testDir, 'android-notification.txt'),
    'Android API 29 notification permission is not applicable for runtime prompt.\n',
  );
  writeFileSync(
    path.join(testDir, 'onesignal.txt'),
    'OneSignal dashboard push was sent, received, and tapped with all identifiers redacted.\n',
  );
  writeFileSync(
    path.join(testDir, 'sentry.txt'),
    'Sentry beta synthetic validation event was received with no PII or tokens.\n',
  );
  writeFileSync(
    path.join(testDir, 'internal-beta.txt'),
    'Internal beta owner approval, rollback plan, and support contact were reviewed.\n',
  );
}

function expectGatePasses(name, evidence) {
  const evidenceFile = `qa-artifacts/release-validation/self-test/${name}.json`;
  writeJson(path.join(repoRoot, evidenceFile), evidence);
  const result = runGate(evidenceFile);
  assert(
    result.status === 0,
    `${name} expected to pass, got ${result.status}\n${result.stdout}\n${result.stderr}`,
  );
}

function expectGateFails(name, evidence, expectedText) {
  const evidenceFile = `qa-artifacts/release-validation/self-test/${name}.json`;
  writeJson(path.join(repoRoot, evidenceFile), evidence);
  const result = runGate(evidenceFile);
  const output = `${result.stdout}\n${result.stderr}`;
  assert(result.status !== 0, `${name} expected to fail, but passed\n${output}`);
  assert(
    output.includes(expectedText),
    `${name} expected output to include "${expectedText}"\n${output}`,
  );
}

try {
  rmSync(testDir, { recursive: true, force: true });
  mkdirSync(testDir, { recursive: true });
  writeSafeEvidenceFiles();

  expectGatePasses('valid-evidence', baseEvidence());

  expectGateFails(
    'outside-evidence-path',
    baseEvidence({
      oneSignal: {
        ...baseEvidence().oneSignal,
        evidencePath: 'release/onesignal-dashboard-validation.md',
      },
    }),
    'oneSignal.evidencePath must point inside qa-artifacts/release-validation',
  );

  expectGateFails(
    'missing-evidence-file',
    baseEvidence({
      sentry: {
        ...baseEvidence().sentry,
        evidencePath: 'qa-artifacts/release-validation/self-test/missing-sentry.txt',
      },
    }),
    'sentry.evidencePath file does not exist',
  );

  writeFileSync(
    path.join(testDir, 'onesignal-with-secret.txt'),
    'Do not approve: user@example.com Authorization: Bearer secret-token-value\n',
  );
  expectGateFails(
    'sensitive-evidence-file',
    baseEvidence({
      oneSignal: {
        ...baseEvidence().oneSignal,
        evidencePath: 'qa-artifacts/release-validation/self-test/onesignal-with-secret.txt',
      },
    }),
    'oneSignal.evidencePath appears to contain sensitive data',
  );

  console.log('Release evidence gate self-tests passed.');
} finally {
  rmSync(testDir, { recursive: true, force: true });
}
