#!/usr/bin/env node
import { existsSync, mkdirSync, writeFileSync } from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = path.resolve(__dirname, '..');
const evidenceDir = path.join(repoRoot, 'qa-artifacts', 'release-validation');

const args = new Map();
for (let index = 2; index < process.argv.length; index += 1) {
  const arg = process.argv[index];
  if (!arg.startsWith('--')) continue;
  const [key, inlineValue] = arg.slice(2).split('=', 2);
  const value = inlineValue ?? process.argv[index + 1];
  args.set(key, value);
  if (inlineValue === undefined) index += 1;
}

const release = sanitizeFilePart(args.get('release') ?? 'current');
const overwrite = process.argv.includes('--overwrite');

function sanitizeFilePart(value) {
  return String(value)
    .trim()
    .replace(/[^A-Za-z0-9._-]+/g, '-')
    .replace(/^-+|-+$/g, '');
}

function todayIsoDate() {
  return new Date().toISOString().slice(0, 10);
}

function writePlaceholder(fileName, title, body) {
  const filePath = path.join(evidenceDir, fileName);
  if (existsSync(filePath) && !overwrite) {
    return {
      relativePath: path.relative(repoRoot, filePath).replaceAll('\\', '/'),
      skipped: true,
    };
  }

  writeFileSync(
    filePath,
    [
      `# ${title}`,
      '',
      `- Release: ${release}`,
      `- Created: ${todayIsoDate()}`,
      '- Redaction status: pending manual completion',
      '',
      body.trim(),
      '',
      '## Redaction checklist',
      '',
      '- [ ] No dashboard credentials.',
      '- [ ] No API keys, DSNs, access tokens, refresh tokens, or bearer tokens.',
      '- [ ] No emails, phone numbers, subscription IDs, player IDs, or user IDs.',
      '- [ ] Screenshots/photos are manually redacted before marking the evidence safe.',
      '- [ ] This file has been checked with `node scripts/verify-release-evidence.mjs`.',
      '',
    ].join('\n'),
  );

  return {
    relativePath: path.relative(repoRoot, filePath).replaceAll('\\', '/'),
    skipped: false,
  };
}

mkdirSync(evidenceDir, { recursive: true });

const files = {
  oneSignal: writePlaceholder(
    `onesignal-dashboard-${release}.md`,
    'OneSignal dashboard push evidence',
    `
## Evidence to complete after the dashboard test

- Package ID:
- App version / versionCode:
- Device model only:
- Dashboard send timestamp:
- Push subscription opt-in confirmed: no
- Dashboard push sent: no
- Push received on physical device: no
- Notification tap opened app: no
- Logcat checked for payload/PII leakage: no

## Redacted artifact references

- Dashboard delivery screenshot/photo:
- Device notification screenshot/photo:
- Redacted logcat excerpt:
`,
  ),
  sentry: writePlaceholder(
    `sentry-beta-${release}.md`,
    'Sentry Beta synthetic event evidence',
    `
## Evidence to complete after the safe synthetic event

- Package ID:
- App version / versionCode:
- Environment: beta
- Authorized Beta DSN used at build/run time: no
- Synthetic event sent: no
- Synthetic event received in Sentry: no
- Event message: Bad state: release-validation-synthetic-event
- Event reviewed for PII/tokens/payloads: no

## Redacted artifact references

- Redacted Sentry event screenshot/photo:
- Notes:
`,
  ),
  internalBeta: writePlaceholder(
    `internal-beta-${release}.md`,
    'Internal Beta approval evidence',
    `
## Evidence to complete after internal distribution

- Distribution channel:
- Release owner:
- Package ID:
- Version name / versionCode:
- Signed artifact path:
- SHA-256:
- Rollback plan reviewed: no
- Support contact ready: no
- Release owner approved: no

## Redacted artifact references

- Store/test distribution screenshot/photo:
- Signed artifact verification output:
- Approval note location:
`,
  ),
};

console.log('Release evidence placeholder files');
console.log('==================================');
for (const [key, value] of Object.entries(files)) {
  const status = value.skipped ? 'exists' : 'written';
  console.log(`- ${key}: ${status}: ${value.relativePath}`);
}

console.log('\nSuggested release-evidence.json fields after real external validation:');
console.log(
  JSON.stringify(
    {
      oneSignal: {
        evidencePath: files.oneSignal.relativePath,
        containsNoSecretsOrPii: false,
      },
      sentry: {
        evidencePath: files.sentry.relativePath,
        containsNoSecretsOrPii: false,
      },
      internalBeta: {
        evidencePath: files.internalBeta.relativePath,
      },
    },
    null,
    2,
  ),
);

console.log(
  '\nKeep booleans false until the real dashboard push, Sentry event, and internal Beta approval are completed.',
);
