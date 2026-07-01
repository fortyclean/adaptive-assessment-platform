#!/usr/bin/env node
import { createHash } from 'node:crypto';
import { existsSync, mkdirSync, readdirSync, readFileSync, statSync, writeFileSync } from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = path.resolve(__dirname, '..');
const defaultSource = path.resolve(repoRoot, '..', 'stitch_adaptive_assessment_platform');
const defaultOutDir = path.resolve(
  repoRoot,
  'qa-artifacts',
  'release-validation',
);

const args = new Map();
for (let i = 2; i < process.argv.length; i += 1) {
  const arg = process.argv[i];
  if (!arg.startsWith('--')) continue;
  const [key, inlineValue] = arg.slice(2).split('=', 2);
  const value = inlineValue ?? process.argv[i + 1];
  args.set(key, value);
  if (inlineValue === undefined) i += 1;
}

const sourceRoot = path.resolve(args.get('source') ?? defaultSource);
const outDir = path.resolve(args.get('out') ?? defaultOutDir);
const expectedCount = Number(args.get('expected') ?? 75);
const viewport = args.get('viewport') ?? '390x844';

function sha256(filePath) {
  return createHash('sha256').update(readFileSync(filePath)).digest('hex');
}

function pngDimensions(filePath) {
  const buffer = readFileSync(filePath);
  const signature = buffer.subarray(0, 8).toString('hex');
  if (signature !== '89504e470d0a1a0a') {
    return null;
  }
  return {
    width: buffer.readUInt32BE(16),
    height: buffer.readUInt32BE(20),
  };
}

function screenNumber(name) {
  const match = /^_(\d+)$/.exec(name);
  return match ? Number(match[1]) : null;
}

if (!existsSync(sourceRoot)) {
  console.error(`Stitch source folder not found: ${sourceRoot}`);
  process.exit(2);
}

const references = readdirSync(sourceRoot, { withFileTypes: true })
  .filter((entry) => entry.isDirectory())
  .map((entry) => ({ name: entry.name, number: screenNumber(entry.name) }))
  .filter((entry) => entry.number !== null && entry.number >= 1 && entry.number <= expectedCount)
  .sort((a, b) => a.number - b.number)
  .map((entry) => {
    const folder = path.join(sourceRoot, entry.name);
    const screenPath = path.join(folder, 'screen.png');
    const codePath = path.join(folder, 'code.html');
    const hasScreen = existsSync(screenPath);
    const hasCode = existsSync(codePath);
    const dimensions = hasScreen ? pngDimensions(screenPath) : null;

    return {
      id: entry.number,
      folder: path.relative(repoRoot, folder).replaceAll(path.sep, '/'),
      screen: hasScreen
        ? {
            file: path.relative(repoRoot, screenPath).replaceAll(path.sep, '/'),
            bytes: statSync(screenPath).size,
            sha256: sha256(screenPath),
            dimensions,
          }
        : null,
      code: hasCode
        ? {
            file: path.relative(repoRoot, codePath).replaceAll(path.sep, '/'),
            bytes: statSync(codePath).size,
            sha256: sha256(codePath),
          }
        : null,
      status: hasScreen && hasCode ? 'ready' : 'missing-assets',
    };
  });

const foundIds = new Set(references.map((reference) => reference.id));
const missingIds = Array.from({ length: expectedCount }, (_, index) => index + 1)
  .filter((id) => !foundIds.has(id));
const inconsistentDimensions = references
  .filter((reference) => reference.screen?.dimensions)
  .filter((reference) => {
    const { width, height } = reference.screen.dimensions;
    return width <= 0 || height <= 0;
  })
  .map((reference) => reference.id);

const summary = {
  generatedAt: new Date().toISOString(),
  sourceRoot,
  expectedCount,
  actualCount: references.length,
  viewport,
  missingIds,
  inconsistentDimensions,
  readyCount: references.filter((reference) => reference.status === 'ready').length,
};

const inventory = {
  summary,
  references,
};

mkdirSync(outDir, { recursive: true });
const jsonPath = path.join(outDir, 'stitch-visual-reference-inventory.json');
const mdPath = path.join(outDir, 'stitch-visual-reference-inventory.md');

writeFileSync(jsonPath, `${JSON.stringify(inventory, null, 2)}\n`);

const rows = references.map((reference) => {
  const dimensions = reference.screen?.dimensions
    ? `${reference.screen.dimensions.width}x${reference.screen.dimensions.height}`
    : 'missing';
  const screenSha = reference.screen?.sha256.slice(0, 12) ?? 'missing';
  const codeSha = reference.code?.sha256.slice(0, 12) ?? 'missing';
  return `| ${reference.id} | ${reference.status} | ${dimensions} | ${reference.screen?.bytes ?? 0} | ${screenSha} | ${codeSha} |`;
});

writeFileSync(
  mdPath,
  [
    '# Stitch Visual Reference Inventory',
    '',
    `Generated at: ${summary.generatedAt}`,
    '',
    `Source: \`${sourceRoot}\``,
    '',
    `Fixed comparison viewport target: \`${viewport}\``,
    '',
    `Ready references: ${summary.readyCount}/${summary.expectedCount}`,
    '',
    `Missing IDs: ${summary.missingIds.length ? summary.missingIds.join(', ') : 'none'}`,
    '',
    '| Screen | Status | Source dimensions | PNG bytes | PNG SHA-256 | HTML SHA-256 |',
    '|---:|---|---:|---:|---|---|',
    ...rows,
    '',
  ].join('\n'),
);

if (summary.actualCount !== expectedCount || summary.missingIds.length > 0) {
  console.error(
    `Expected ${expectedCount} Stitch references but found ${summary.actualCount}. Missing: ${summary.missingIds.join(', ') || 'none'}`,
  );
  process.exit(1);
}

if (references.some((reference) => reference.status !== 'ready')) {
  console.error('Some Stitch references are missing screen.png or code.html.');
  process.exit(1);
}

console.log(`Wrote ${jsonPath}`);
console.log(`Wrote ${mdPath}`);
