#!/usr/bin/env node
import { existsSync, readFileSync, rmSync } from 'node:fs';
import { spawnSync } from 'node:child_process';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = path.resolve(__dirname, '..');
const release = 'self-test-placeholders';
const evidenceDir = path.join(repoRoot, 'qa-artifacts', 'release-validation');
const expectedFiles = [
  `onesignal-dashboard-${release}.md`,
  `sentry-beta-${release}.md`,
  `internal-beta-${release}.md`,
];

function assert(condition, message) {
  if (!condition) {
    throw new Error(message);
  }
}

for (const fileName of expectedFiles) {
  rmSync(path.join(evidenceDir, fileName), { force: true });
}

const result = spawnSync(
  process.execPath,
  ['scripts/create-release-evidence-placeholders.mjs', '--release', release],
  {
    cwd: repoRoot,
    encoding: 'utf8',
  },
);

assert(
  result.status === 0,
  `placeholder creation failed with ${result.status}\n${result.stdout}\n${result.stderr}`,
);
assert(result.stdout.includes('Keep booleans false'), 'output must remind users not to mark booleans true');

for (const fileName of expectedFiles) {
  const filePath = path.join(evidenceDir, fileName);
  assert(existsSync(filePath), `${fileName} was not created`);

  const content = readFileSync(filePath, 'utf8');
  assert(content.includes('Redaction checklist'), `${fileName} must include a redaction checklist`);
  assert(!content.includes('@'), `${fileName} must not include email-like placeholders`);
  assert(!content.includes('<authorized-beta-dsn>'), `${fileName} must not include DSN placeholders`);
}

for (const fileName of expectedFiles) {
  rmSync(path.join(evidenceDir, fileName), { force: true });
}

console.log('Release evidence placeholder self-tests passed.');
