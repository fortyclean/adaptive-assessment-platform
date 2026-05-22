import {
  demoAssessments,
  demoClassrooms,
  demoQuestions,
  demoUsers,
  getDemoSeedSummary,
} from '../../src/services/demoSeedService';

describe('demoSeedService fixtures', () => {
  it('covers every demo role and core product area', () => {
    const summary = getDemoSeedSummary();

    expect(summary.users).toBeGreaterThanOrEqual(8);
    expect(summary.classrooms).toBeGreaterThanOrEqual(2);
    expect(summary.questions).toBeGreaterThanOrEqual(30);
    expect(summary.assessments).toBeGreaterThanOrEqual(3);
    expect(summary.includesAdminAssignmentFlow).toBe(true);
    expect(summary.includesTeacherAssessmentFlow).toBe(true);
    expect(summary.includesStudentMarketplaceAndProgressFlow).toBe(true);
  });

  it('assigns teachers and students to every demo classroom', () => {
    for (const classroom of demoClassrooms) {
      expect(classroom.teachers.length).toBeGreaterThan(0);
      expect(classroom.students.length).toBeGreaterThan(0);
    }
  });

  it('provides enough questions for every demo assessment', () => {
    for (const assessment of demoAssessments) {
      const matchingQuestions = demoQuestions.filter(
        (question) =>
          question.subject === assessment.subject &&
          question.gradeLevel === assessment.gradeLevel &&
          assessment.units.includes(question.unit),
      );

      expect(matchingQuestions.length).toBeGreaterThanOrEqual(assessment.questionCount);
    }
  });

  it('keeps extra fixture usernames unique and separate from primary demo logins', () => {
    const usernames = demoUsers.map((user) => user.username);
    expect(new Set(usernames).size).toBe(usernames.length);
    expect(usernames).not.toContain('admin');
    expect(usernames).not.toContain('teacher');
    expect(usernames).not.toContain('student');
  });
});
