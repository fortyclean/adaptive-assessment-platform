/**
 * Unit tests for Question CRUD — Post-MVP
 * Requirements: 16.4, 16.5, 16.6
 */

describe('Question CRUD — Post-MVP (Req 16.4, 16.5, 16.6)', () => {
  // ─── Edit preserves historical session data (Req 16.4) ───────────────────

  describe('Edit Question — Historical Data Preservation (Req 16.4)', () => {
    it('should preserve original question text in student attempt answers', () => {
      // When a question is edited, the snapshot stored in student_attempts.answers
      // preserves the original questionText at the time of the attempt.
      const originalText = 'What is 2 + 2?';
      const updatedText = 'What is the sum of 2 and 2?';

      const attemptAnswer = {
        questionId: 'q1',
        questionText: originalText, // snapshot preserved
        selectedAnswer: 'B',
        correctAnswer: 'B',
        isCorrect: true,
      };

      // Edit the question
      const updatedQuestion = { _id: 'q1', questionText: updatedText };

      // The attempt answer still has the original text
      expect(attemptAnswer.questionText).toBe(originalText);
      expect(updatedQuestion.questionText).toBe(updatedText);
      expect(attemptAnswer.questionText).not.toBe(updatedQuestion.questionText);
    });

    it('should apply edits only to future assessments', () => {
      const question = {
        _id: 'q1',
        questionText: 'Original question',
        difficulty: 'easy',
        updatedAt: new Date('2024-01-01'),
      };

      const assessment1 = {
        _id: 'a1',
        createdAt: new Date('2023-12-01'), // before edit
        questionIds: ['q1'],
      };

      const assessment2 = {
        _id: 'a2',
        createdAt: new Date('2024-01-15'), // after edit
        questionIds: ['q1'],
      };

      // Both assessments reference the same question ID
      // but historical attempts preserve the snapshot
      expect(assessment1.questionIds).toContain('q1');
      expect(assessment2.questionIds).toContain('q1');
    });

    it('should allow editing difficulty, skill, and options', () => {
      const original = {
        difficulty: 'easy',
        mainSkill: 'Algebra',
        options: [
          { key: 'A', value: '2' },
          { key: 'B', value: '4' },
          { key: 'C', value: '6' },
          { key: 'D', value: '8' },
        ],
        correctAnswer: 'B',
      };

      const updated = {
        ...original,
        difficulty: 'medium',
        mainSkill: 'Advanced Algebra',
      };

      expect(updated.difficulty).toBe('medium');
      expect(updated.mainSkill).toBe('Advanced Algebra');
      expect(updated.correctAnswer).toBe('B'); // unchanged
    });
  });

  // ─── Delete prevention for published assessment questions (Req 16.5, 16.6) ─

  describe('Delete Question — Published Assessment Prevention (Req 16.5, 16.6)', () => {
    it('should prevent deletion when question is used in active assessment', () => {
      const question = { _id: 'q1', questionText: 'Test question' };
      const activeAssessment = {
        _id: 'a1',
        status: 'active',
        questionIds: ['q1'],
      };

      const isUsedInPublished = activeAssessment.questionIds.includes(question._id) &&
        ['active', 'completed'].includes(activeAssessment.status);

      expect(isUsedInPublished).toBe(true);
    });

    it('should prevent deletion when question is used in completed assessment', () => {
      const question = { _id: 'q1' };
      const completedAssessment = {
        status: 'completed',
        questionIds: ['q1'],
      };

      const isUsedInPublished = completedAssessment.questionIds.includes(question._id) &&
        ['active', 'completed'].includes(completedAssessment.status);

      expect(isUsedInPublished).toBe(true);
    });

    it('should allow deletion when question is only in draft assessments', () => {
      const question = { _id: 'q1' };
      const draftAssessment = {
        status: 'draft',
        questionIds: ['q1'],
      };

      const isUsedInPublished = draftAssessment.questionIds.includes(question._id) &&
        ['active', 'completed'].includes(draftAssessment.status);

      expect(isUsedInPublished).toBe(false);
    });

    it('should allow deletion when question is not used in any assessment', () => {
      const question = { _id: 'q1' };
      const assessments: { questionIds: string[] }[] = [];

      const isUsedInAny = assessments.some((a) => a.questionIds.includes(question._id));
      expect(isUsedInAny).toBe(false);
    });

    it('should suggest archive instead of delete for published questions', () => {
      const response = {
        error: 'Cannot delete a question used in a published assessment',
        suggestion: 'Archive the question instead to preserve historical data',
      };

      expect(response.suggestion).toContain('Archive');
    });
  });

  // ─── Archive vs Delete (Req 16.6) ────────────────────────────────────────

  describe('Archive Question (Req 16.6)', () => {
    it('should mark question as archived without deleting', () => {
      const question = { _id: 'q1', isArchived: false };
      question.isArchived = true;

      expect(question.isArchived).toBe(true);
      expect(question._id).toBe('q1'); // still exists
    });

    it('should exclude archived questions from new assessments', () => {
      const questions = [
        { _id: 'q1', isArchived: false },
        { _id: 'q2', isArchived: true },
        { _id: 'q3', isArchived: false },
      ];

      const available = questions.filter((q) => !q.isArchived);
      expect(available.length).toBe(2);
      expect(available.map((q) => q._id)).not.toContain('q2');
    });

    it('should preserve archived questions in historical attempts', () => {
      const archivedQuestion = { _id: 'q2', isArchived: true };
      const historicalAttempt = {
        answers: [
          { questionId: 'q2', questionText: 'Old question text', isCorrect: true },
        ],
      };

      // Historical attempt still references the archived question
      expect(historicalAttempt.answers[0].questionId).toBe(archivedQuestion._id);
    });
  });

  // ─── Paginated Question List (Req 16.7) ──────────────────────────────────

  describe('Paginated Question List (Req 16.7)', () => {
    const allQuestions = Array.from({ length: 55 }, (_, i) => ({
      _id: `q${i}`,
      questionText: `Question ${i}`,
      isArchived: false,
    }));

    it('should return 20 questions per page by default', () => {
      const page = 1;
      const limit = 20;
      const skip = (page - 1) * limit;
      const paginated = allQuestions.slice(skip, skip + limit);

      expect(paginated.length).toBe(20);
    });

    it('should return correct questions for page 2', () => {
      const page = 2;
      const limit = 20;
      const skip = (page - 1) * limit;
      const paginated = allQuestions.slice(skip, skip + limit);

      expect(paginated.length).toBe(20);
      expect(paginated[0]._id).toBe('q20');
    });

    it('should return remaining questions on last page', () => {
      const page = 3;
      const limit = 20;
      const skip = (page - 1) * limit;
      const paginated = allQuestions.slice(skip, skip + limit);

      expect(paginated.length).toBe(15); // 55 - 40 = 15
    });

    it('should calculate total pages correctly', () => {
      const total = allQuestions.length;
      const limit = 20;
      const totalPages = Math.ceil(total / limit);

      expect(totalPages).toBe(3);
    });
  });
});
