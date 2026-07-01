import { roleSeedAccounts } from '../fixtures/roleSeedAccounts';

describe('Role seed accounts fixture', () => {
  it('provides reproducible admin, teacher, and student accounts for smoke journeys', () => {
    expect(Object.keys(roleSeedAccounts).sort()).toEqual(['admin', 'student', 'teacher']);

    for (const account of Object.values(roleSeedAccounts)) {
      expect(account.username).toEqual(expect.any(String));
      expect(account.password).toMatch(/^(?=.*[A-Z])(?=.*\d).{8,}$/);
      expect(account.email).toContain('@');
      expect(['admin', 'teacher', 'student']).toContain(account.role);
    }
  });

  it('keeps usernames and emails unique across roles', () => {
    const usernames = Object.values(roleSeedAccounts).map((account) => account.username);
    const emails = Object.values(roleSeedAccounts).map((account) => account.email);

    expect(new Set(usernames).size).toBe(usernames.length);
    expect(new Set(emails).size).toBe(emails.length);
  });
});
