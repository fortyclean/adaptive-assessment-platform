import { readFileSync } from 'node:fs';

const workflowPath = '.github/workflows/build-apk.yml';
const workflow = readFileSync(workflowPath, 'utf8');

const forbiddenPatterns = [
  { label: 'demo admin password', pattern: /Admin@123/i },
  { label: 'demo teacher password', pattern: /Teacher@123/i },
  { label: 'demo student password', pattern: /Student@123/i },
  { label: 'demo login section', pattern: /demo\s+(accounts?|logins?|credentials?)/i },
  { label: 'Arabic demo login section', pattern: /بيانات\s+الدخول\s+التجريبية/u },
  { label: 'mojibake release text', pattern: /Ø|Ù|ðŸ/u },
];

const findings = forbiddenPatterns
  .filter(({ pattern }) => pattern.test(workflow))
  .map(({ label }) => label);

if (findings.length > 0) {
  console.error('Release notes safety check failed:');
  for (const finding of findings) console.error(`- ${finding}`);
  process.exit(1);
}

console.log('Release notes safety check passed.');
