#!/usr/bin/env node
import { existsSync, readFileSync, rmSync } from 'node:fs';
import { spawnSync } from 'node:child_process';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = path.resolve(__dirname, '..');
const output = 'qa-artifacts/release-validation/self-test-init-release-evidence.json';
const outputPath = path.join(repoRoot, output);

function assert(condition, message) {
  if (!condition) {
    throw new Error(message);
  }
}

rmSync(outputPath, { force: true });

const result = spawnSync(
  process.execPath,
  ['scripts/init-release-evidence.mjs', '--no-ci', '--out', output],
  {
    cwd: repoRoot,
    encoding: 'utf8',
  },
);

assert(
  result.status === 0,
  `init-release-evidence failed with ${result.status}\n${result.stdout}\n${result.stderr}`,
);
assert(existsSync(outputPath), 'expected release evidence output file to be created');

const evidence = JSON.parse(readFileSync(outputPath, 'utf8'));
assert(evidence.release === '1.0.111', `expected release 1.0.111, got ${evidence.release}`);
assert(
  evidence.packageId === 'com.adaptivemastery.app',
  `expected package id com.adaptivemastery.app, got ${evidence.packageId}`,
);
assert(evidence.ci.runNumber === '', 'CI run number should remain empty when --no-ci is used');

rmSync(outputPath, { force: true });

console.log('Release evidence init self-tests passed.');
