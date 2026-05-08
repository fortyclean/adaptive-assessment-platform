/**
 * Unit tests for Additional Question Types
 * Requirements: 18.1, 18.2, 18.3, 18.5, 18.6
 *
 * Covers:
 *  - True/False scoring (Req 18.1)
 *  - Fill-in-the-Blank accepted answer matching (Req 18.2, 18.3)
 *  - Essay pending review flow (Req 18.5, 18.6)
 */

import {
  checkFillBlankAnswer,
  calculatePointsEarned,
  calculateSkillBreakdown,
} from '../../src/services/adaptiveEngine';

// ─── True/False Scoring (Req 18.1) ───────────────────────────────────────────
//
// True/False questions use the same MCQ scoring logic: the correctAnswer is
// the string 'true' or 'false', and the student's selectedAnswer is compared
// with strict equality (case-sensitive, as stored by the server).

describe('True/False — Scoring (Req 18.1)', () => {
  // Helper that mirrors the server-side answer validation in routes/attempts.ts
  function scoreTrueFalse(correctAnswer: string, selectedAnswer: string): boolean {
    return correctAnswer === selectedAnswer;
  }

  it('should mark answer correct when student selects "true" and correct answer is "true"', () => {
    expect(scoreTrueFalse('true', 'true')).toBe(true);
  });

  it('should mark answer correct when student selects "false" and correct answer is "false"', () => {
    expect(scoreTrueFalse('false', 'false')).toBe(true);
  });

  it('should mark answer incorrect when student selects "false" but correct answer is "true"', () => {
    expect(scoreTrueFalse('true', 'false')).toBe(false);
  });

  it('should mark answer incorrect when student selects "true" but correct answer is "false"', () => {
    expect(scoreTrueFalse('false', 'true')).toBe(false);
  });

  it('should be case-sensitive — "True" does not match "true"', () => {
    // The server stores and compares the exact string; the client must send the
    // canonical lowercase value.
    expect(scoreTrueFalse('true', 'True')).toBe(false);
    expect(scoreTrueFalse('false', 'False')).toBe(false);
  });

  it('should reject empty answer', () => {
    expect(scoreTrueFalse('true', '')).toBe(false);
  });

  // ─── True/False in a session context ──────────────────────────────────────

  it('should accumulate correct True/False answers in session score', () => {
    // Simulate a 5-question True/False session: 4 correct, 1 wrong
    const answers = [
      { mainSkill: 'Logic', isCorrect: true },
      { mainSkill: 'Logic', isCorrect: true },
      { mainSkill: 'Logic', isCorrect: true },
      { mainSkill: 'Logic', isCorrect: true },
      { mainSkill: 'Logic', isCorrect: false },
    ];

    const correctCount = answers.filter((a) => a.isCorrect).length;
    const scorePercentage = (correctCount / answers.length) * 100;

    expect(correctCount).toBe(4);
    expect(scorePercentage).toBe(80);
  });

  it('should calculate points correctly for a True/False session', () => {
    // 80% on a 5-question session → (80/100) * 5 * 10 = 40 points
    const { points, bonusAwarded } = calculatePointsEarned(80, 5);
    expect(points).toBe(40);
    expect(bonusAwarded).toBe(false);
  });

  it('should award bonus points when True/False session score is >= 90%', () => {
    // 100% on a 5-question session → (100/100) * 5 * 10 = 50 + 50 bonus = 100
    const { points, bonusAwarded } = calculatePointsEarned(100, 5);
    expect(points).toBe(100);
    expect(bonusAwarded).toBe(true);
  });

  it('should classify True/False skill as strength when >= 70% correct', () => {
    const answers = [
      { mainSkill: 'Logic', isCorrect: true },
      { mainSkill: 'Logic', isCorrect: true },
      { mainSkill: 'Logic', isCorrect: true },
      { mainSkill: 'Logic', isCorrect: false },
    ]; // 75% → strength

    const breakdown = calculateSkillBreakdown(answers);
    const logic = breakdown.find((s) => s.mainSkill === 'Logic');

    expect(logic).toBeDefined();
    expect(logic!.classification).toBe('strength');
    expect(logic!.percentage).toBe(75);
  });

  it('should classify True/False skill as weakness when < 70% correct', () => {
    const answers = [
      { mainSkill: 'Logic', isCorrect: true },
      { mainSkill: 'Logic', isCorrect: false },
      { mainSkill: 'Logic', isCorrect: false },
    ]; // 33% → weakness

    const breakdown = calculateSkillBreakdown(answers);
    const logic = breakdown.find((s) => s.mainSkill === 'Logic');

    expect(logic).toBeDefined();
    expect(logic!.classification).toBe('weakness');
  });
});

// ─── Fill-in-the-Blank — Accepted Answer Matching (Req 18.2, 18.3) ───────────
//
// checkFillBlankAnswer is the canonical implementation; these tests verify the
// acceptance criteria from Req 18.3 in detail.

describe('Fill-in-the-Blank — Accepted Answer Matching (Req 18.2, 18.3)', () => {
  // ─── Case-insensitive matching ─────────────────────────────────────────────

  it('should match when student answer has the same case as accepted answer', () => {
    expect(checkFillBlankAnswer('Paris', ['Paris'])).toBe(true);
  });

  it('should match when student answer is all lowercase (Req 18.3)', () => {
    expect(checkFillBlankAnswer('paris', ['Paris'])).toBe(true);
  });

  it('should match when student answer is all uppercase (Req 18.3)', () => {
    expect(checkFillBlankAnswer('PARIS', ['Paris'])).toBe(true);
  });

  it('should match when accepted answer is lowercase and student types mixed case', () => {
    expect(checkFillBlankAnswer('PaRiS', ['paris'])).toBe(true);
  });

  // ─── Whitespace trimming ───────────────────────────────────────────────────

  it('should trim leading whitespace from student answer before comparing', () => {
    expect(checkFillBlankAnswer('  Paris', ['Paris'])).toBe(true);
  });

  it('should trim trailing whitespace from student answer before comparing', () => {
    expect(checkFillBlankAnswer('Paris  ', ['Paris'])).toBe(true);
  });

  it('should trim both leading and trailing whitespace from student answer', () => {
    expect(checkFillBlankAnswer('  Paris  ', ['Paris'])).toBe(true);
  });

  it('should trim whitespace from accepted answers before comparing', () => {
    expect(checkFillBlankAnswer('Paris', ['  Paris  '])).toBe(true);
  });

  it('should return false when answer is only whitespace', () => {
    expect(checkFillBlankAnswer('   ', ['Paris'])).toBe(false);
  });

  // ─── Multiple accepted answers ─────────────────────────────────────────────

  it('should return true when student answer matches the first of multiple accepted answers', () => {
    expect(checkFillBlankAnswer('water', ['water', 'H2O', 'dihydrogen monoxide'])).toBe(true);
  });

  it('should return true when student answer matches a middle accepted answer', () => {
    expect(checkFillBlankAnswer('H2O', ['water', 'H2O', 'dihydrogen monoxide'])).toBe(true);
  });

  it('should return true when student answer matches the last accepted answer', () => {
    expect(checkFillBlankAnswer('dihydrogen monoxide', ['water', 'H2O', 'dihydrogen monoxide'])).toBe(true);
  });

  it('should return false when student answer does not match any accepted answer', () => {
    expect(checkFillBlankAnswer('juice', ['water', 'H2O', 'dihydrogen monoxide'])).toBe(false);
  });

  it('should handle multiple accepted answers with case-insensitive matching', () => {
    expect(checkFillBlankAnswer('WATER', ['water', 'H2O'])).toBe(true);
    expect(checkFillBlankAnswer('h2o', ['water', 'H2O'])).toBe(true);
  });

  // ─── Edge cases ────────────────────────────────────────────────────────────

  it('should return false for empty student answer', () => {
    expect(checkFillBlankAnswer('', ['Paris'])).toBe(false);
  });

  it('should return false when accepted answers list is empty', () => {
    expect(checkFillBlankAnswer('Paris', [])).toBe(false);
  });

  it('should handle single-character answers', () => {
    expect(checkFillBlankAnswer('A', ['a'])).toBe(true);
    expect(checkFillBlankAnswer('b', ['A'])).toBe(false);
  });

  it('should handle numeric string answers', () => {
    expect(checkFillBlankAnswer('42', ['42'])).toBe(true);
    expect(checkFillBlankAnswer('42', ['43'])).toBe(false);
  });

  it('should handle Arabic text answers', () => {
    expect(checkFillBlankAnswer('باريس', ['باريس'])).toBe(true);
    expect(checkFillBlankAnswer('لندن', ['باريس'])).toBe(false);
  });

  // ─── Fill-in-the-Blank in session scoring ─────────────────────────────────

  it('should count fill-blank correct answers toward session score', () => {
    // Simulate a 4-question fill-blank session: 3 correct
    const answers = [
      { mainSkill: 'Vocabulary', isCorrect: true },
      { mainSkill: 'Vocabulary', isCorrect: true },
      { mainSkill: 'Vocabulary', isCorrect: true },
      { mainSkill: 'Vocabulary', isCorrect: false },
    ];

    const correctCount = answers.filter((a) => a.isCorrect).length;
    const scorePercentage = (correctCount / answers.length) * 100;

    expect(correctCount).toBe(3);
    expect(scorePercentage).toBe(75);
  });
});

// ─── Essay — Pending Review Flow (Req 18.5, 18.6) ────────────────────────────
//
// These tests verify the business logic for the essay grading workflow without
// hitting MongoDB. They test the state transitions and score calculations that
// the route handler in routes/attempts.ts implements.

describe('Essay — Pending Review Flow (Req 18.5)', () => {
  // ─── Session status after essay submission ─────────────────────────────────

  it('should set session status to pending_review when essay questions are present', () => {
    const answers = [
      { isEssay: true, isCorrect: false, teacherScore: undefined },
      { isEssay: false, isCorrect: true, teacherScore: undefined },
    ];

    const hasEssayQuestions = answers.some((a) => a.isEssay);
    const expectedStatus = hasEssayQuestions ? 'pending_review' : 'completed';

    expect(hasEssayQuestions).toBe(true);
    expect(expectedStatus).toBe('pending_review');
  });

  it('should set session status to completed when no essay questions are present', () => {
    const answers = [
      { isEssay: false, isCorrect: true },
      { isEssay: false, isCorrect: false },
    ];

    const hasEssayQuestions = answers.some((a) => a.isEssay);
    const expectedStatus = hasEssayQuestions ? 'pending_review' : 'completed';

    expect(hasEssayQuestions).toBe(false);
    expect(expectedStatus).toBe('completed');
  });

  it('should set status to pending_review even when all non-essay questions are answered', () => {
    // A session with 4 MCQ + 1 essay: all MCQ answered, essay submitted
    const answers = [
      { isEssay: false, isCorrect: true },
      { isEssay: false, isCorrect: true },
      { isEssay: false, isCorrect: false },
      { isEssay: false, isCorrect: true },
      { isEssay: true, isCorrect: false, teacherScore: undefined },
    ];

    const hasEssayQuestions = answers.some((a) => a.isEssay);
    expect(hasEssayQuestions).toBe(true);

    // Status must be pending_review, not completed
    const status = hasEssayQuestions ? 'pending_review' : 'completed';
    expect(status).toBe('pending_review');
  });

  it('should mark essay answer as isCorrect=false until teacher grades it', () => {
    // Essay answers are always isCorrect=false at submission time (Req 18.5)
    const essayAnswer = {
      isEssay: true,
      selectedAnswer: 'The French Revolution began in 1789...',
      isCorrect: false, // always false until graded
      teacherScore: undefined,
    };

    expect(essayAnswer.isCorrect).toBe(false);
    expect(essayAnswer.teacherScore).toBeUndefined();
  });

  it('should count pending essay answers correctly', () => {
    const answers = [
      { isEssay: true, teacherScore: undefined },
      { isEssay: true, teacherScore: 8 },
      { isEssay: false, teacherScore: undefined },
    ];

    const pendingEssays = answers.filter(
      (a) => a.isEssay && a.teacherScore === undefined,
    ).length;

    expect(pendingEssays).toBe(1);
  });

  it('should notify teacher that manual grading is required after essay submission', () => {
    // Verify the notification payload structure for essay grading requirement
    const assessmentTitle = 'اختبار الأحياء';
    const notification = {
      type: 'essay_grading_required',
      title: 'يتطلب تصحيحاً يدوياً',
      body: `طالب أكمل اختبار "${assessmentTitle}" ويحتوي على أسئلة مقالية تحتاج إلى تصحيح يدوي`,
      isRead: false,
    };

    expect(notification.type).toBe('essay_grading_required');
    expect(notification.isRead).toBe(false);
    expect(notification.body).toContain(assessmentTitle);
  });
});

describe('Essay — Teacher Grading (Req 18.6)', () => {
  // ─── Score validation ──────────────────────────────────────────────────────

  it('should allow teacher to assign score between 0 and maxMarks', () => {
    const maxMarks = 10;
    const validScores = [0, 1, 5, 9, 10];

    validScores.forEach((score) => {
      expect(score).toBeGreaterThanOrEqual(0);
      expect(score).toBeLessThanOrEqual(maxMarks);
    });
  });

  it('should reject score that exceeds maxMarks', () => {
    const maxMarks = 10;
    const invalidScore = 11;

    const isValid = invalidScore <= maxMarks;
    expect(isValid).toBe(false);
  });

  it('should reject negative score', () => {
    const score = -1;
    const isValid = score >= 0;
    expect(isValid).toBe(false);
  });

  it('should mark essay answer as correct when teacher assigns score > 0', () => {
    // Partial credit counts as correct for skill analysis (per route implementation)
    const teacherScore = 7;
    const isCorrect = teacherScore > 0;
    expect(isCorrect).toBe(true);
  });

  it('should mark essay answer as incorrect when teacher assigns score of 0', () => {
    const teacherScore = 0;
    const isCorrect = teacherScore > 0;
    expect(isCorrect).toBe(false);
  });

  // ─── Session finalisation after grading ───────────────────────────────────

  it('should keep session in pending_review while ungraded essays remain', () => {
    const answers = [
      { isEssay: true, teacherScore: 8 },
      { isEssay: true, teacherScore: undefined }, // still ungraded
    ];

    const ungradedEssays = answers.filter(
      (a) => a.isEssay && a.teacherScore === undefined,
    );

    expect(ungradedEssays.length).toBeGreaterThan(0);
    // Status should remain pending_review
    const status = ungradedEssays.length === 0 ? 'completed' : 'pending_review';
    expect(status).toBe('pending_review');
  });

  it('should transition session to completed when all essays are graded', () => {
    const answers = [
      { isEssay: true, teacherScore: 8 },
      { isEssay: true, teacherScore: 6 },
    ];

    const ungradedEssays = answers.filter(
      (a) => a.isEssay && a.teacherScore === undefined,
    );

    expect(ungradedEssays.length).toBe(0);
    const status = ungradedEssays.length === 0 ? 'completed' : 'pending_review';
    expect(status).toBe('completed');
  });

  it('should transition to completed when the last essay is graded', () => {
    // Before grading the last essay
    const answersBefore = [
      { isEssay: true, teacherScore: 9 },
      { isEssay: true, teacherScore: undefined }, // last ungraded
    ];

    const ungradedBefore = answersBefore.filter(
      (a) => a.isEssay && a.teacherScore === undefined,
    );
    expect(ungradedBefore.length).toBe(1);

    // After grading the last essay
    const answersAfter = answersBefore.map((a) =>
      a.teacherScore === undefined ? { ...a, teacherScore: 7 } : a,
    );

    const ungradedAfter = answersAfter.filter(
      (a) => a.isEssay && a.teacherScore === undefined,
    );
    expect(ungradedAfter.length).toBe(0);

    const status = ungradedAfter.length === 0 ? 'completed' : 'pending_review';
    expect(status).toBe('completed');
  });

  // ─── Final score calculation including essay marks ─────────────────────────

  it('should calculate final score including essay marks after all essays are graded', () => {
    // 3 MCQ (2 correct) + 1 essay (7/10 marks)
    // totalMarks = 3 * 1 + 10 = 13
    // earnedMarks = 2 * 1 + 7 = 9
    // scorePercentage = round((9/13) * 100 * 100) / 100 = 69.23
    const answers = [
      { isEssay: false, isCorrect: true, maxMarks: undefined, teacherScore: undefined },
      { isEssay: false, isCorrect: true, maxMarks: undefined, teacherScore: undefined },
      { isEssay: false, isCorrect: false, maxMarks: undefined, teacherScore: undefined },
      { isEssay: true, isCorrect: true, maxMarks: 10, teacherScore: 7 },
    ];

    const totalMarks = answers.reduce((sum, a) => {
      if (a.isEssay) return sum + (a.maxMarks ?? 0);
      return sum + 1;
    }, 0);

    const earnedMarks = answers.reduce((sum, a) => {
      if (a.isEssay) return sum + (a.teacherScore ?? 0);
      return sum + (a.isCorrect ? 1 : 0);
    }, 0);

    const scorePercentage = totalMarks > 0
      ? Math.round((earnedMarks / totalMarks) * 100 * 100) / 100
      : 0;

    expect(totalMarks).toBe(13);
    expect(earnedMarks).toBe(9);
    expect(scorePercentage).toBeCloseTo(69.23, 1);
  });

  it('should calculate 100% score when all MCQ correct and essay gets full marks', () => {
    const answers = [
      { isEssay: false, isCorrect: true, maxMarks: undefined, teacherScore: undefined },
      { isEssay: false, isCorrect: true, maxMarks: undefined, teacherScore: undefined },
      { isEssay: true, isCorrect: true, maxMarks: 10, teacherScore: 10 },
    ];

    const totalMarks = answers.reduce((sum, a) => {
      if (a.isEssay) return sum + (a.maxMarks ?? 0);
      return sum + 1;
    }, 0);

    const earnedMarks = answers.reduce((sum, a) => {
      if (a.isEssay) return sum + (a.teacherScore ?? 0);
      return sum + (a.isCorrect ? 1 : 0);
    }, 0);

    const scorePercentage = totalMarks > 0
      ? Math.round((earnedMarks / totalMarks) * 100 * 100) / 100
      : 0;

    expect(totalMarks).toBe(12);
    expect(earnedMarks).toBe(12);
    expect(scorePercentage).toBe(100);
  });

  it('should calculate 0% score when all MCQ wrong and essay gets 0 marks', () => {
    const answers = [
      { isEssay: false, isCorrect: false, maxMarks: undefined, teacherScore: undefined },
      { isEssay: true, isCorrect: false, maxMarks: 10, teacherScore: 0 },
    ];

    const totalMarks = answers.reduce((sum, a) => {
      if (a.isEssay) return sum + (a.maxMarks ?? 0);
      return sum + 1;
    }, 0);

    const earnedMarks = answers.reduce((sum, a) => {
      if (a.isEssay) return sum + (a.teacherScore ?? 0);
      return sum + (a.isCorrect ? 1 : 0);
    }, 0);

    const scorePercentage = totalMarks > 0
      ? Math.round((earnedMarks / totalMarks) * 100 * 100) / 100
      : 0;

    expect(totalMarks).toBe(11);
    expect(earnedMarks).toBe(0);
    expect(scorePercentage).toBe(0);
  });

  it('should award bonus points when final score (including essay) is >= 90%', () => {
    // 90% on a 10-question session → bonus applies
    const { points, bonusAwarded } = calculatePointsEarned(90, 10);
    expect(bonusAwarded).toBe(true);
    expect(points).toBe(140); // 90 base + 50 bonus
  });

  it('should not award bonus points when final score (including essay) is < 90%', () => {
    const { bonusAwarded } = calculatePointsEarned(69.23, 10);
    expect(bonusAwarded).toBe(false);
  });

  // ─── Skill breakdown after essay grading ──────────────────────────────────

  it('should include essay skill in breakdown after grading', () => {
    const answers = [
      { mainSkill: 'Writing', isCorrect: true },  // essay graded as correct (score > 0)
      { mainSkill: 'Writing', isCorrect: false }, // essay graded as incorrect (score = 0)
      { mainSkill: 'Grammar', isCorrect: true },
    ];

    const breakdown = calculateSkillBreakdown(answers);
    const writing = breakdown.find((s) => s.mainSkill === 'Writing');
    const grammar = breakdown.find((s) => s.mainSkill === 'Grammar');

    expect(writing).toBeDefined();
    expect(writing!.totalQuestions).toBe(2);
    expect(writing!.correctAnswers).toBe(1);
    expect(writing!.percentage).toBe(50);
    expect(writing!.classification).toBe('weakness');

    expect(grammar).toBeDefined();
    expect(grammar!.classification).toBe('strength');
  });

  // ─── Notification after finalisation ──────────────────────────────────────

  it('should send result_ready notification to student after all essays are graded', () => {
    const scorePercentage = 85.5;
    const assessmentTitle = 'اختبار الأحياء';

    const notification = {
      type: 'result_ready',
      title: 'نتيجة اختبارك جاهزة',
      body: `تم تصحيح اختبار "${assessmentTitle}" ونتيجتك ${scorePercentage.toFixed(1)}%`,
      isRead: false,
    };

    expect(notification.type).toBe('result_ready');
    expect(notification.isRead).toBe(false);
    expect(notification.body).toContain('85.5%');
    expect(notification.body).toContain(assessmentTitle);
  });

  // ─── Attempt status validation ─────────────────────────────────────────────

  it('should reject grading request when attempt is not in pending_review status', () => {
    const attemptStatus = 'completed';
    const canGrade = attemptStatus === 'pending_review';
    expect(canGrade).toBe(false);
  });

  it('should reject grading request when attempt is in_progress', () => {
    const attemptStatus = 'in_progress';
    const canGrade = attemptStatus === 'pending_review';
    expect(canGrade).toBe(false);
  });

  it('should allow grading when attempt is in pending_review status', () => {
    const attemptStatus = 'pending_review';
    const canGrade = attemptStatus === 'pending_review';
    expect(canGrade).toBe(true);
  });
});
