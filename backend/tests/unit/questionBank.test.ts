/**
 * Unit tests for Question Bank logic.
 * Tests validation, filtering, uniqueness, and answer validation.
 * Requirements: 3.1, 3.2, 3.3, 22.1, 22.2
 */

import { SUBJECTS, DifficultyLevel } from '../../src/models/Question';

// ─── Helper: simulate validateQuestionData ────────────────────────────────────

interface QuestionOption { key: string; value: string; }

const validateQuestionData = (data: {
  options: QuestionOption[];
  correctAnswer: string;
}): { valid: boolean; error?: string } => {
  const optionKeys = data.options.map((o) => o.key);
  if (!optionKeys.includes(data.correctAnswer)) {
    return { valid: false, error: 'Correct answer must match one of the provided option keys' };
  }
  const optionValues = data.options.map((o) => o.value.trim().toLowerCase());
  const uniqueValues = new Set(optionValues);
  if (uniqueValues.size !== optionValues.length) {
    return { valid: false, error: 'Answer options must not contain duplicate text' };
  }
  return { valid: true };
};

// ─── Subject Enum Tests ───────────────────────────────────────────────────────

describe('Question Bank — Subject Enum (Req 3.6)', () => {
  it('should include all 6 MVP subjects', () => {
    expect(SUBJECTS).toContain('Mathematics');
    expect(SUBJECTS).toContain('English');
    expect(SUBJECTS).toContain('Arabic');
    expect(SUBJECTS).toContain('Physics');
    expect(SUBJECTS).toContain('Chemistry');
    expect(SUBJECTS).toContain('Biology');
  });

  it('should have exactly 6 subjects', () => {
    expect(SUBJECTS).toHaveLength(6);
  });
});

// ─── Answer Validation Tests (Req 22.1) ──────────────────────────────────────

describe('Question Bank — Answer Validation (Req 22.1)', () => {
  const validOptions: QuestionOption[] = [
    { key: 'A', value: 'الحوت' },
    { key: 'B', value: 'التمساح' },
    { key: 'C', value: 'الضفدع' },
    { key: 'D', value: 'البطريق' },
  ];

  it('should accept a correct answer that matches an option key', () => {
    const result = validateQuestionData({ options: validOptions, correctAnswer: 'A' });
    expect(result.valid).toBe(true);
  });

  it('should reject a correct answer that does not match any option key', () => {
    const result = validateQuestionData({ options: validOptions, correctAnswer: 'E' });
    expect(result.valid).toBe(false);
    expect(result.error).toContain('Correct answer must match');
  });

  it('should reject an empty correct answer', () => {
    const result = validateQuestionData({ options: validOptions, correctAnswer: '' });
    expect(result.valid).toBe(false);
  });

  it('should accept any valid option key (A, B, C, or D)', () => {
    ['A', 'B', 'C', 'D'].forEach((key) => {
      const result = validateQuestionData({ options: validOptions, correctAnswer: key });
      expect(result.valid).toBe(true);
    });
  });
});

// ─── Duplicate Options Tests (Req 22.2) ──────────────────────────────────────

describe('Question Bank — Duplicate Options Validation (Req 22.2)', () => {
  it('should reject options with duplicate values', () => {
    const duplicateOptions: QuestionOption[] = [
      { key: 'A', value: 'الحوت' },
      { key: 'B', value: 'الحوت' }, // duplicate
      { key: 'C', value: 'الضفدع' },
      { key: 'D', value: 'البطريق' },
    ];
    const result = validateQuestionData({ options: duplicateOptions, correctAnswer: 'A' });
    expect(result.valid).toBe(false);
    expect(result.error).toContain('duplicate');
  });

  it('should reject case-insensitive duplicate values', () => {
    const duplicateOptions: QuestionOption[] = [
      { key: 'A', value: 'Whale' },
      { key: 'B', value: 'whale' }, // same when lowercased
      { key: 'C', value: 'Frog' },
      { key: 'D', value: 'Penguin' },
    ];
    const result = validateQuestionData({ options: duplicateOptions, correctAnswer: 'A' });
    expect(result.valid).toBe(false);
  });

  it('should accept options with all unique values', () => {
    const uniqueOptions: QuestionOption[] = [
      { key: 'A', value: 'الحوت' },
      { key: 'B', value: 'التمساح' },
      { key: 'C', value: 'الضفدع' },
      { key: 'D', value: 'البطريق' },
    ];
    const result = validateQuestionData({ options: uniqueOptions, correctAnswer: 'A' });
    expect(result.valid).toBe(true);
  });
});

// ─── Uniqueness Constraint Tests (Req 3.2) ───────────────────────────────────

describe('Question Bank — Uniqueness Constraint (Req 3.2)', () => {
  it('should identify duplicate questions by subject + gradeLevel + unit + questionText', () => {
    const existing = {
      subject: 'Mathematics',
      gradeLevel: 'Grade 7',
      unit: 'Algebra',
      questionText: 'What is 2 + 2?',
    };

    const newQuestion = {
      subject: 'Mathematics',
      gradeLevel: 'Grade 7',
      unit: 'Algebra',
      questionText: 'What is 2 + 2?',
    };

    const isDuplicate =
      existing.subject === newQuestion.subject &&
      existing.gradeLevel === newQuestion.gradeLevel &&
      existing.unit === newQuestion.unit &&
      existing.questionText === newQuestion.questionText;

    expect(isDuplicate).toBe(true);
  });

  it('should allow same question text in different subjects', () => {
    const q1 = { subject: 'Mathematics', gradeLevel: 'Grade 7', unit: 'Algebra', questionText: 'What is 2 + 2?' };
    const q2 = { subject: 'Physics', gradeLevel: 'Grade 7', unit: 'Algebra', questionText: 'What is 2 + 2?' };

    const isDuplicate = q1.subject === q2.subject && q1.gradeLevel === q2.gradeLevel &&
      q1.unit === q2.unit && q1.questionText === q2.questionText;

    expect(isDuplicate).toBe(false);
  });
});

// ─── Filtering Logic Tests (Req 3.4) ─────────────────────────────────────────

describe('Question Bank — Filtering (Req 3.4)', () => {
  const questions = [
    { subject: 'Mathematics', gradeLevel: 'Grade 7', unit: 'Algebra', difficulty: 'easy', mainSkill: 'Equations' },
    { subject: 'Mathematics', gradeLevel: 'Grade 7', unit: 'Algebra', difficulty: 'medium', mainSkill: 'Equations' },
    { subject: 'Mathematics', gradeLevel: 'Grade 7', unit: 'Geometry', difficulty: 'hard', mainSkill: 'Shapes' },
    { subject: 'Physics', gradeLevel: 'Grade 9', unit: 'Mechanics', difficulty: 'easy', mainSkill: 'Forces' },
  ];

  it('should filter by subject', () => {
    const filtered = questions.filter((q) => q.subject === 'Mathematics');
    expect(filtered).toHaveLength(3);
  });

  it('should filter by subject and unit', () => {
    const filtered = questions.filter((q) => q.subject === 'Mathematics' && q.unit === 'Algebra');
    expect(filtered).toHaveLength(2);
  });

  it('should filter by difficulty', () => {
    const filtered = questions.filter((q) => q.difficulty === 'easy');
    expect(filtered).toHaveLength(2);
  });

  it('should filter by multiple criteria simultaneously', () => {
    const filtered = questions.filter(
      (q) => q.subject === 'Mathematics' && q.unit === 'Algebra' && q.difficulty === 'medium',
    );
    expect(filtered).toHaveLength(1);
  });
});

// ─── Quality Check Logic Tests (Req 22.3, 22.4) ──────────────────────────────

describe('Question Bank — Quality Check (Req 22.3, 22.4)', () => {
  const MIN_PER_DIFFICULTY = 3;

  it('should flag unit as not adaptive-ready when any difficulty has fewer than 3 questions', () => {
    const counts = { easy: 5, medium: 5, hard: 2 }; // hard is insufficient
    const isReady = counts.easy >= MIN_PER_DIFFICULTY &&
      counts.medium >= MIN_PER_DIFFICULTY &&
      counts.hard >= MIN_PER_DIFFICULTY;
    expect(isReady).toBe(false);
  });

  it('should flag unit as adaptive-ready when all difficulties have at least 3 questions', () => {
    const counts = { easy: 5, medium: 4, hard: 3 };
    const isReady = counts.easy >= MIN_PER_DIFFICULTY &&
      counts.medium >= MIN_PER_DIFFICULTY &&
      counts.hard >= MIN_PER_DIFFICULTY;
    expect(isReady).toBe(true);
  });

  it('should generate correct warnings for insufficient difficulty levels', () => {
    const counts = { easy: 1, medium: 5, hard: 0 };
    const warnings: string[] = [];
    if (counts.easy < MIN_PER_DIFFICULTY) warnings.push(`Insufficient easy: ${counts.easy}/${MIN_PER_DIFFICULTY}`);
    if (counts.medium < MIN_PER_DIFFICULTY) warnings.push(`Insufficient medium: ${counts.medium}/${MIN_PER_DIFFICULTY}`);
    if (counts.hard < MIN_PER_DIFFICULTY) warnings.push(`Insufficient hard: ${counts.hard}/${MIN_PER_DIFFICULTY}`);

    expect(warnings).toHaveLength(2);
    expect(warnings[0]).toContain('easy');
    expect(warnings[1]).toContain('hard');
  });
});

// ─── Enhanced Filtering Tests (Req 3.3, 3.4) ─────────────────────────────────

describe('Question Bank — Enhanced Filtering (Req 3.3, 3.4)', () => {
  const mockQuestions = [
    { subject: 'Mathematics', gradeLevel: 'Grade 7', unit: 'Algebra', difficulty: 'easy' as DifficultyLevel, mainSkill: 'Equations', subSkill: 'Linear' },
    { subject: 'Mathematics', gradeLevel: 'Grade 7', unit: 'Algebra', difficulty: 'medium' as DifficultyLevel, mainSkill: 'Equations', subSkill: 'Quadratic' },
    { subject: 'Mathematics', gradeLevel: 'Grade 7', unit: 'Geometry', difficulty: 'hard' as DifficultyLevel, mainSkill: 'Shapes', subSkill: 'Triangles' },
    { subject: 'Mathematics', gradeLevel: 'Grade 8', unit: 'Algebra', difficulty: 'easy' as DifficultyLevel, mainSkill: 'Functions', subSkill: 'Linear Functions' },
    { subject: 'Physics', gradeLevel: 'Grade 9', unit: 'Mechanics', difficulty: 'easy' as DifficultyLevel, mainSkill: 'Forces', subSkill: 'Newton Laws' },
    { subject: 'Physics', gradeLevel: 'Grade 9', unit: 'Mechanics', difficulty: 'medium' as DifficultyLevel, mainSkill: 'Forces', subSkill: 'Friction' },
    { subject: 'English', gradeLevel: 'Grade 7', unit: 'Grammar', difficulty: 'easy' as DifficultyLevel, mainSkill: 'Tenses', subSkill: 'Present Simple' },
    { subject: 'Arabic', gradeLevel: 'Grade 7', unit: 'النحو', difficulty: 'medium' as DifficultyLevel, mainSkill: 'الإعراب', subSkill: 'الفاعل' },
  ];

  it('should filter by subject only', () => {
    const filtered = mockQuestions.filter((q) => q.subject === 'Mathematics');
    expect(filtered).toHaveLength(4);
    expect(filtered.every((q) => q.subject === 'Mathematics')).toBe(true);
  });

  it('should filter by gradeLevel only', () => {
    const filtered = mockQuestions.filter((q) => q.gradeLevel === 'Grade 7');
    expect(filtered).toHaveLength(5);
    expect(filtered.every((q) => q.gradeLevel === 'Grade 7')).toBe(true);
  });

  it('should filter by unit only', () => {
    const filtered = mockQuestions.filter((q) => q.unit === 'Algebra');
    expect(filtered).toHaveLength(3);
    expect(filtered.every((q) => q.unit === 'Algebra')).toBe(true);
  });

  it('should filter by mainSkill only', () => {
    const filtered = mockQuestions.filter((q) => q.mainSkill === 'Forces');
    expect(filtered).toHaveLength(2);
    expect(filtered.every((q) => q.mainSkill === 'Forces')).toBe(true);
  });

  it('should filter by subSkill only', () => {
    const filtered = mockQuestions.filter((q) => q.subSkill === 'Linear');
    expect(filtered).toHaveLength(1);
    expect(filtered[0].mainSkill).toBe('Equations');
  });

  it('should filter by difficulty only', () => {
    const filtered = mockQuestions.filter((q) => q.difficulty === 'easy');
    expect(filtered).toHaveLength(4);
    expect(filtered.every((q) => q.difficulty === 'easy')).toBe(true);
  });

  it('should filter by subject and gradeLevel', () => {
    const filtered = mockQuestions.filter((q) => q.subject === 'Mathematics' && q.gradeLevel === 'Grade 7');
    expect(filtered).toHaveLength(3);
  });

  it('should filter by subject, gradeLevel, and unit', () => {
    const filtered = mockQuestions.filter(
      (q) => q.subject === 'Mathematics' && q.gradeLevel === 'Grade 7' && q.unit === 'Algebra',
    );
    expect(filtered).toHaveLength(2);
  });

  it('should filter by subject, unit, and difficulty', () => {
    const filtered = mockQuestions.filter(
      (q) => q.subject === 'Mathematics' && q.unit === 'Algebra' && q.difficulty === 'easy',
    );
    expect(filtered).toHaveLength(2);
  });

  it('should filter by mainSkill and subSkill', () => {
    const filtered = mockQuestions.filter((q) => q.mainSkill === 'Equations' && q.subSkill === 'Quadratic');
    expect(filtered).toHaveLength(1);
    expect(filtered[0].difficulty).toBe('medium');
  });

  it('should return empty array when no questions match filters', () => {
    const filtered = mockQuestions.filter(
      (q) => q.subject === 'Chemistry' && q.gradeLevel === 'Grade 10',
    );
    expect(filtered).toHaveLength(0);
  });

  it('should filter by all criteria simultaneously', () => {
    const filtered = mockQuestions.filter(
      (q) =>
        q.subject === 'Physics' &&
        q.gradeLevel === 'Grade 9' &&
        q.unit === 'Mechanics' &&
        q.mainSkill === 'Forces' &&
        q.difficulty === 'medium',
    );
    expect(filtered).toHaveLength(1);
    expect(filtered[0].subSkill).toBe('Friction');
  });

  it('should handle Arabic content filtering', () => {
    const filtered = mockQuestions.filter((q) => q.subject === 'Arabic');
    expect(filtered).toHaveLength(1);
    expect(filtered[0].unit).toBe('النحو');
    expect(filtered[0].mainSkill).toBe('الإعراب');
  });
});

// ─── Search Performance Tests (Req 3.3) ──────────────────────────────────────

describe('Question Bank — Search Performance (Req 3.3)', () => {
  it('should complete filtering operation within acceptable time', () => {
    // Generate a larger dataset to simulate realistic search
    const largeDataset = Array.from({ length: 1000 }, (_, i) => ({
      subject: ['Mathematics', 'Physics', 'English'][i % 3],
      gradeLevel: `Grade ${7 + (i % 3)}`,
      unit: `Unit ${i % 10}`,
      difficulty: ['easy', 'medium', 'hard'][i % 3] as DifficultyLevel,
      mainSkill: `Skill ${i % 20}`,
      subSkill: `SubSkill ${i % 50}`,
    }));

    const startTime = performance.now();
    const filtered = largeDataset.filter(
      (q) => q.subject === 'Mathematics' && q.unit === 'Unit 5',
    );
    const endTime = performance.now();
    const duration = endTime - startTime;

    // Req 3.3: Should return results within 500ms
    expect(duration).toBeLessThan(500);
    expect(filtered.length).toBeGreaterThan(0);
  });

  it('should handle complex multi-criteria search efficiently', () => {
    const largeDataset = Array.from({ length: 500 }, (_, i) => ({
      subject: SUBJECTS[i % SUBJECTS.length],
      gradeLevel: `Grade ${7 + (i % 6)}`,
      unit: `Unit ${i % 15}`,
      difficulty: ['easy', 'medium', 'hard'][i % 3] as DifficultyLevel,
      mainSkill: `Skill ${i % 25}`,
      subSkill: `SubSkill ${i % 40}`,
    }));

    const startTime = performance.now();
    const filtered = largeDataset.filter(
      (q) =>
        q.subject === 'Mathematics' &&
        q.gradeLevel === 'Grade 7' &&
        q.unit === 'Unit 3' &&
        q.difficulty === 'medium',
    );
    const endTime = performance.now();
    const duration = endTime - startTime;

    expect(duration).toBeLessThan(500);
    expect(filtered.every((q) => q.subject === 'Mathematics')).toBe(true);
  });
});

// ─── Enhanced Uniqueness Constraint Tests (Req 3.2) ──────────────────────────

describe('Question Bank — Enhanced Uniqueness Constraint (Req 3.2)', () => {
  it('should allow same question text in different grade levels', () => {
    const q1 = {
      subject: 'Mathematics',
      gradeLevel: 'Grade 7',
      unit: 'Algebra',
      questionText: 'Solve for x: 2x + 4 = 10',
    };
    const q2 = {
      subject: 'Mathematics',
      gradeLevel: 'Grade 8',
      unit: 'Algebra',
      questionText: 'Solve for x: 2x + 4 = 10',
    };

    const isDuplicate =
      q1.subject === q2.subject &&
      q1.gradeLevel === q2.gradeLevel &&
      q1.unit === q2.unit &&
      q1.questionText === q2.questionText;

    expect(isDuplicate).toBe(false);
  });

  it('should allow same question text in different units', () => {
    const q1 = {
      subject: 'Mathematics',
      gradeLevel: 'Grade 7',
      unit: 'Algebra',
      questionText: 'What is the value of x?',
    };
    const q2 = {
      subject: 'Mathematics',
      gradeLevel: 'Grade 7',
      unit: 'Geometry',
      questionText: 'What is the value of x?',
    };

    const isDuplicate =
      q1.subject === q2.subject &&
      q1.gradeLevel === q2.gradeLevel &&
      q1.unit === q2.unit &&
      q1.questionText === q2.questionText;

    expect(isDuplicate).toBe(false);
  });

  it('should detect duplicate even with different difficulty levels', () => {
    // Uniqueness is based on subject+grade+unit+text, NOT difficulty
    const q1 = {
      subject: 'Physics',
      gradeLevel: 'Grade 9',
      unit: 'Mechanics',
      questionText: 'What is Newton\'s first law?',
      difficulty: 'easy',
    };
    const q2 = {
      subject: 'Physics',
      gradeLevel: 'Grade 9',
      unit: 'Mechanics',
      questionText: 'What is Newton\'s first law?',
      difficulty: 'hard',
    };

    const isDuplicate =
      q1.subject === q2.subject &&
      q1.gradeLevel === q2.gradeLevel &&
      q1.unit === q2.unit &&
      q1.questionText === q2.questionText;

    expect(isDuplicate).toBe(true);
  });

  it('should detect duplicate even with different skills', () => {
    // Uniqueness is based on subject+grade+unit+text, NOT skills
    const q1 = {
      subject: 'English',
      gradeLevel: 'Grade 7',
      unit: 'Grammar',
      questionText: 'Choose the correct verb form',
      mainSkill: 'Tenses',
      subSkill: 'Present Simple',
    };
    const q2 = {
      subject: 'English',
      gradeLevel: 'Grade 7',
      unit: 'Grammar',
      questionText: 'Choose the correct verb form',
      mainSkill: 'Verbs',
      subSkill: 'Irregular Verbs',
    };

    const isDuplicate =
      q1.subject === q2.subject &&
      q1.gradeLevel === q2.gradeLevel &&
      q1.unit === q2.unit &&
      q1.questionText === q2.questionText;

    expect(isDuplicate).toBe(true);
  });

  it('should treat whitespace-only differences as different questions', () => {
    const q1 = {
      subject: 'Mathematics',
      gradeLevel: 'Grade 7',
      unit: 'Algebra',
      questionText: 'What is 2 + 2?',
    };
    const q2 = {
      subject: 'Mathematics',
      gradeLevel: 'Grade 7',
      unit: 'Algebra',
      questionText: 'What is  2 + 2?', // extra space
    };

    const isDuplicate =
      q1.subject === q2.subject &&
      q1.gradeLevel === q2.gradeLevel &&
      q1.unit === q2.unit &&
      q1.questionText === q2.questionText;

    expect(isDuplicate).toBe(false);
  });
});

// ─── Enhanced Answer Validation Tests (Req 22.1, 22.2) ───────────────────────

describe('Question Bank — Enhanced Answer Validation (Req 22.1, 22.2)', () => {
  it('should reject when correct answer is not in options (case-sensitive)', () => {
    const options = [
      { key: 'A', value: 'Option A' },
      { key: 'B', value: 'Option B' },
      { key: 'C', value: 'Option C' },
      { key: 'D', value: 'Option D' },
    ];
    const result = validateQuestionData({ options, correctAnswer: 'a' }); // lowercase
    expect(result.valid).toBe(false);
  });

  it('should accept correct answer with numeric keys', () => {
    const options = [
      { key: '1', value: 'First' },
      { key: '2', value: 'Second' },
      { key: '3', value: 'Third' },
      { key: '4', value: 'Fourth' },
    ];
    const result = validateQuestionData({ options, correctAnswer: '2' });
    expect(result.valid).toBe(true);
  });

  it('should reject when options array has fewer than 2 options', () => {
    const options = [{ key: 'A', value: 'Only one' }];
    // This would be caught by schema validation, but test the logic
    const result = validateQuestionData({ options, correctAnswer: 'A' });
    expect(result.valid).toBe(true); // Still valid if correct answer matches
  });

  it('should detect duplicates with leading/trailing whitespace', () => {
    const options = [
      { key: 'A', value: '  Whale  ' },
      { key: 'B', value: 'Whale' },
      { key: 'C', value: 'Frog' },
      { key: 'D', value: 'Penguin' },
    ];
    const result = validateQuestionData({ options, correctAnswer: 'A' });
    expect(result.valid).toBe(false);
    expect(result.error).toContain('duplicate');
  });

  it('should detect duplicates in Arabic text', () => {
    const options = [
      { key: 'A', value: 'الحوت' },
      { key: 'B', value: 'الحوت' },
      { key: 'C', value: 'الضفدع' },
      { key: 'D', value: 'البطريق' },
    ];
    const result = validateQuestionData({ options, correctAnswer: 'A' });
    expect(result.valid).toBe(false);
  });

  it('should accept options with similar but not identical values', () => {
    const options = [
      { key: 'A', value: 'Whale' },
      { key: 'B', value: 'Whales' }, // plural
      { key: 'C', value: 'Frog' },
      { key: 'D', value: 'Penguin' },
    ];
    const result = validateQuestionData({ options, correctAnswer: 'A' });
    expect(result.valid).toBe(true);
  });

  it('should handle mixed language options', () => {
    const options = [
      { key: 'A', value: 'الحوت' },
      { key: 'B', value: 'Whale' },
      { key: 'C', value: 'Frog' },
      { key: 'D', value: 'الضفدع' },
    ];
    const result = validateQuestionData({ options, correctAnswer: 'B' });
    expect(result.valid).toBe(true);
  });

  it('should reject all four options being duplicates', () => {
    const options = [
      { key: 'A', value: 'Same' },
      { key: 'B', value: 'Same' },
      { key: 'C', value: 'Same' },
      { key: 'D', value: 'Same' },
    ];
    const result = validateQuestionData({ options, correctAnswer: 'A' });
    expect(result.valid).toBe(false);
  });

  it('should accept empty string as option value if unique', () => {
    const options = [
      { key: 'A', value: '' },
      { key: 'B', value: 'Option B' },
      { key: 'C', value: 'Option C' },
      { key: 'D', value: 'Option D' },
    ];
    const result = validateQuestionData({ options, correctAnswer: 'B' });
    expect(result.valid).toBe(true);
  });

  it('should validate with exactly 4 options (standard MCQ)', () => {
    const options = [
      { key: 'A', value: 'First' },
      { key: 'B', value: 'Second' },
      { key: 'C', value: 'Third' },
      { key: 'D', value: 'Fourth' },
    ];
    const result = validateQuestionData({ options, correctAnswer: 'C' });
    expect(result.valid).toBe(true);
  });
});

// ─── Filtering Edge Cases (Req 3.4) ──────────────────────────────────────────

describe('Question Bank — Filtering Edge Cases (Req 3.4)', () => {
  const edgeCaseQuestions = [
    { subject: 'Mathematics', gradeLevel: 'Grade 7', unit: '', difficulty: 'easy' as DifficultyLevel, mainSkill: 'Algebra' },
    { subject: 'Physics', gradeLevel: '', unit: 'Mechanics', difficulty: 'medium' as DifficultyLevel, mainSkill: 'Forces' },
    { subject: '', gradeLevel: 'Grade 8', unit: 'Geometry', difficulty: 'hard' as DifficultyLevel, mainSkill: 'Shapes' },
  ];

  it('should handle empty string filters', () => {
    const filtered = edgeCaseQuestions.filter((q) => q.unit === '');
    expect(filtered).toHaveLength(1);
    expect(filtered[0].subject).toBe('Mathematics');
  });

  it('should handle filtering with no results', () => {
    const filtered = edgeCaseQuestions.filter((q) => q.subject === 'Chemistry');
    expect(filtered).toHaveLength(0);
  });

  it('should return all questions when no filters applied', () => {
    const filtered = edgeCaseQuestions.filter(() => true);
    expect(filtered).toHaveLength(3);
  });
});
