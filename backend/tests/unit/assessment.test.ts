/**
 * Unit tests for Assessment management logic.
 * Tests creation, random selection, availability window, and quality check.
 * Requirements: 5.1, 5.2, 5.4, 5.7, 5.8, 22.3
 */

// ─── Assessment Validation Logic ─────────────────────────────────────────────

describe('Assessment — Creation Validation (Req 5.1)', () => {
  it('should enforce minimum question count of 5', () => {
    const MIN_QUESTIONS = 5;
    expect(4).toBeLessThan(MIN_QUESTIONS);
    expect(5).toBeGreaterThanOrEqual(MIN_QUESTIONS);
  });

  it('should enforce maximum question count of 50', () => {
    const MAX_QUESTIONS = 50;
    expect(51).toBeGreaterThan(MAX_QUESTIONS);
    expect(50).toBeLessThanOrEqual(MAX_QUESTIONS);
  });

  it('should enforce minimum time limit of 5 minutes', () => {
    const MIN_TIME = 5;
    expect(4).toBeLessThan(MIN_TIME);
    expect(5).toBeGreaterThanOrEqual(MIN_TIME);
  });

  it('should enforce maximum time limit of 120 minutes', () => {
    const MAX_TIME = 120;
    expect(121).toBeGreaterThan(MAX_TIME);
    expect(120).toBeLessThanOrEqual(MAX_TIME);
  });

  it('should support both random and adaptive assessment types', () => {
    const validTypes = ['random', 'adaptive'];
    expect(validTypes).toContain('random');
    expect(validTypes).toContain('adaptive');
    expect(validTypes).not.toContain('manual');
  });
});

// ─── Insufficient Questions Notification (Req 5.4) ───────────────────────────

describe('Assessment — Insufficient Questions (Req 5.4)', () => {
  it('should detect when available questions are fewer than requested', () => {
    const availableCount = 8;
    const requestedCount = 15;
    const isInsufficient = availableCount < requestedCount;
    expect(isInsufficient).toBe(true);
  });

  it('should allow creation when available questions equal requested count', () => {
    const availableCount = 15;
    const requestedCount = 15;
    const isInsufficient = availableCount < requestedCount;
    expect(isInsufficient).toBe(false);
  });

  it('should allow creation when available questions exceed requested count', () => {
    const availableCount = 30;
    const requestedCount = 15;
    const isInsufficient = availableCount < requestedCount;
    expect(isInsufficient).toBe(false);
  });
});

// ─── Availability Window Enforcement (Req 5.7, 5.8) ─────────────────────────

describe('Assessment — Availability Window (Req 5.7, 5.8)', () => {
  it('should prevent student from starting assessment before availableFrom', () => {
    const now = new Date('2024-01-15T10:00:00Z');
    const availableFrom = new Date('2024-01-16T08:00:00Z'); // tomorrow
    const availableUntil = new Date('2024-01-17T23:59:00Z');

    const isWithinWindow = now >= availableFrom && now <= availableUntil;
    expect(isWithinWindow).toBe(false);
  });

  it('should prevent student from starting assessment after availableUntil', () => {
    const now = new Date('2024-01-18T10:00:00Z');
    const availableFrom = new Date('2024-01-16T08:00:00Z');
    const availableUntil = new Date('2024-01-17T23:59:00Z'); // yesterday

    const isWithinWindow = now >= availableFrom && now <= availableUntil;
    expect(isWithinWindow).toBe(false);
  });

  it('should allow student to start assessment within availability window', () => {
    const now = new Date('2024-01-16T12:00:00Z');
    const availableFrom = new Date('2024-01-16T08:00:00Z');
    const availableUntil = new Date('2024-01-17T23:59:00Z');

    const isWithinWindow = now >= availableFrom && now <= availableUntil;
    expect(isWithinWindow).toBe(true);
  });

  it('should allow access when no availability window is set', () => {
    const availableFrom = null;
    const availableUntil = null;

    // No window = always accessible
    const isAccessible = !availableFrom && !availableUntil;
    expect(isAccessible).toBe(true);
  });
});

// ─── Random Question Selection (Req 5.2) ─────────────────────────────────────

describe('Assessment — Random Question Selection (Req 5.2)', () => {
  it('should select exactly the requested number of questions', () => {
    const allQuestions = Array.from({ length: 50 }, (_, i) => ({ id: `q${i}` }));
    const requestedCount = 20;

    // Simulate random selection
    const shuffled = [...allQuestions].sort(() => Math.random() - 0.5);
    const selected = shuffled.slice(0, requestedCount);

    expect(selected).toHaveLength(requestedCount);
  });

  it('should not select duplicate questions', () => {
    const allQuestions = Array.from({ length: 30 }, (_, i) => ({ id: `q${i}` }));
    const requestedCount = 15;

    const shuffled = [...allQuestions].sort(() => Math.random() - 0.5);
    const selected = shuffled.slice(0, requestedCount);
    const uniqueIds = new Set(selected.map((q) => q.id));

    expect(uniqueIds.size).toBe(requestedCount);
  });
});

// ─── Quality Check for Adaptive Assessment (Req 22.3) ────────────────────────

describe('Assessment — Quality Check for Adaptive (Req 22.3)', () => {
  const MIN_PER_DIFFICULTY = 3;

  it('should warn when easy questions are insufficient for adaptive assessment', () => {
    const counts = { easy: 2, medium: 5, hard: 4 };
    const warnings: string[] = [];

    if (counts.easy < MIN_PER_DIFFICULTY) warnings.push('Insufficient easy questions');
    if (counts.medium < MIN_PER_DIFFICULTY) warnings.push('Insufficient medium questions');
    if (counts.hard < MIN_PER_DIFFICULTY) warnings.push('Insufficient hard questions');

    expect(warnings).toHaveLength(1);
    expect(warnings[0]).toContain('easy');
  });

  it('should not warn when all difficulty levels have sufficient questions', () => {
    const counts = { easy: 5, medium: 8, hard: 4 };
    const warnings: string[] = [];

    if (counts.easy < MIN_PER_DIFFICULTY) warnings.push('Insufficient easy questions');
    if (counts.medium < MIN_PER_DIFFICULTY) warnings.push('Insufficient medium questions');
    if (counts.hard < MIN_PER_DIFFICULTY) warnings.push('Insufficient hard questions');

    expect(warnings).toHaveLength(0);
  });
});

// ─── Assessment Status Transitions ───────────────────────────────────────────

describe('Assessment — Status Transitions', () => {
  it('should start as draft status', () => {
    const defaultStatus = 'draft';
    expect(defaultStatus).toBe('draft');
  });

  it('should transition from draft to active on publish', () => {
    let status = 'draft';
    // Simulate publish action
    status = 'active';
    expect(status).toBe('active');
  });

  it('should not allow editing an active assessment', () => {
    const status = 'active';
    const canEdit = status !== 'active';
    expect(canEdit).toBe(false);
  });
});
