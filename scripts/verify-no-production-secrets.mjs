import { execFileSync } from 'node:child_process';
import { readFileSync } from 'node:fs';

const trackedFiles = execFileSync('git', ['ls-files', '-z'], {
  encoding: 'utf8',
}).split('\0').filter(Boolean);

const blockedFiles = new Set(['backend/.env.production']);
const secretPattern = /^\s*(JWT_SECRET|REFRESH_TOKEN_SECRET|ENCRYPTION_KEY|MONGODB_URI|REDIS_URL|ONESIGNAL_API_KEY)\s*=\s*(?!\s*(?:$|#))/mi;
const findings = [];

for (const file of trackedFiles) {
  if (blockedFiles.has(file)) findings.push(`${file}: production environment file is tracked`);
  if (file.endsWith('.example') || file.endsWith('.md') || file.endsWith('.lock')) continue;
  try {
    if (secretPattern.test(readFileSync(file, 'utf8'))) {
      findings.push(`${file}: contains a configured production secret variable`);
    }
  } catch {
    // Binary and unreadable files are outside this text scan.
  }
}

if (findings.length > 0) {
  console.error('Production-secret scan failed:');
  for (const finding of findings) console.error(`- ${finding}`);
  process.exit(1);
}

console.log('Production-secret scan passed.');
