#!/usr/bin/env node
import { mkdirSync, readFileSync, writeFileSync } from 'node:fs';
import https from 'node:https';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = path.resolve(__dirname, '..');

const args = new Map();
for (let i = 2; i < process.argv.length; i += 1) {
  const arg = process.argv[i];
  if (!arg.startsWith('--')) continue;
  const [key, inlineValue] = arg.slice(2).split('=', 2);
  const value = inlineValue ?? process.argv[i + 1];
  args.set(key, value);
  if (inlineValue === undefined) i += 1;
}

const repo = args.get('repo') ?? 'fortyclean/adaptive-assessment-platform';
const branch = args.get('branch') ?? 'main';
const templatePath = path.resolve(
  repoRoot,
  args.get('template') ?? 'release/release-evidence-template.json',
);
const outputPath = path.resolve(
  repoRoot,
  args.get('out') ?? 'qa-artifacts/release-validation/release-evidence.json',
);

function requestJson(url) {
  return new Promise((resolve, reject) => {
    const request = https.request(
      url,
      {
        headers: {
          Accept: 'application/vnd.github+json',
          'User-Agent': 'adaptive-release-evidence-init',
        },
      },
      (response) => {
        let body = '';
        response.setEncoding('utf8');
        response.on('data', (chunk) => {
          body += chunk;
        });
        response.on('end', () => {
          if (response.statusCode < 200 || response.statusCode >= 300) {
            reject(
              new Error(
                `GitHub API request failed with ${response.statusCode}: ${body}`,
              ),
            );
            return;
          }
          resolve(JSON.parse(body));
        });
      },
    );
    request.on('error', reject);
    request.end();
  });
}

async function latestSuccessfulCiRun() {
  const runs = await requestJson(
    `https://api.github.com/repos/${repo}/actions/workflows/ci.yml/runs?branch=${branch}&status=success&per_page=1`,
  );
  const run = runs.workflow_runs?.[0];
  if (!run) return null;

  const jobs = await requestJson(
    `https://api.github.com/repos/${repo}/actions/runs/${run.id}/jobs?per_page=50`,
  );
  const successfulJobs = new Set(
    (jobs.jobs ?? [])
      .filter((job) => job.conclusion === 'success')
      .map((job) => job.name),
  );

  return {
    runNumber: String(run.run_number),
    commit: run.head_sha,
    backendBuildAndTest: successfulJobs.has('Backend build and test'),
    flutterAnalyzeAndTest: successfulJobs.has('Flutter analyze and test'),
    productionSecretScan: successfulJobs.has('Production secret scan'),
    releaseEvidencePreview: successfulJobs.has('Release evidence preview'),
    htmlUrl: run.html_url,
  };
}

const evidence = JSON.parse(readFileSync(templatePath, 'utf8'));
const ci = await latestSuccessfulCiRun();

if (ci) {
  evidence.ci.runNumber = ci.runNumber;
  evidence.ci.commit = ci.commit;
  evidence.ci.backendBuildAndTest = ci.backendBuildAndTest;
  evidence.ci.flutterAnalyzeAndTest = ci.flutterAnalyzeAndTest;
  evidence.ci.productionSecretScan = ci.productionSecretScan;
}

mkdirSync(path.dirname(outputPath), { recursive: true });
writeFileSync(outputPath, `${JSON.stringify(evidence, null, 2)}\n`);

console.log(`Wrote ${path.relative(repoRoot, outputPath)}`);
if (ci) {
  console.log(
    `Filled CI evidence from run #${ci.runNumber} (${ci.commit.slice(0, 7)}): ${ci.htmlUrl}`,
  );
  if (!ci.releaseEvidencePreview) {
    console.log(
      'Note: latest successful CI did not include the release evidence preview job.',
    );
  }
} else {
  console.log('No successful CI run was found; CI fields remain empty.');
}
console.log(
  'Next: complete OneSignal, Sentry, Android, and internal Beta fields after the external checks are executed.',
);
