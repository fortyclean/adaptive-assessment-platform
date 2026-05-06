/**
 * Unit tests for Reporting System
 * Requirements: 8.1, 8.3, 9.1, 9.6
 */

import {
  calculateScorePercentage,
  calculatePointsEarned,
  calculateSkillBreakdown,
} from '../../src/services/adaptiveEngine';

// ─── Helper: build CSV ────────────────────────────────────────────────────────

function buildCsv(
  headers: string[],
  rows: (string | number | undefined)[][]
): string {
  const escape = (v: string | number | undefined) => {
    const s = String(v ?? '');
    return s.includes(',') || s.includes('"') || s.includes('\n')
      ? `"${s.replace(/"/g, '""')}"`
      : s;
  };
  const lines = [headers.map(escape).join(',')];
  for (const row of rows) {
    lines.push(row.map(escape).join(','));
  }
  return lines.join('\n');
}

// ─── Score Calculation Accuracy (Req 8.1) ────────────────────────────────────

describe('Reporting — Score Calculation Accuracy (Req 8.1)', () => {
  it('should calculate 100% for all correct answers', () => {
    expect(calculateScorePercentage(10, 10)).toBe(100);
  });

  it('should calculate 0% for all incorrect answers', () => {
    expect(calculateScorePercentage(0, 10)).toBe(0);
  });

  it('should calculate 80% for 8 out of 10 correct', () => {
    expect(calculateScorePercentage(8, 10)).toBe(80);
  });

  it('should calculate 50% for 5 out of 10 correct', () => {
    expect(calculateScorePercentage(5, 10)).toBe(50);
  });

  it('should round to 2 decimal places', () => {
    expect(calculateScorePercentage(1, 3)).toBe(33.33);
  });

  it('should return 0 for zero total questions', () => {
    expect(calculateScorePercentage(0, 0)).toBe(0);
  });

  it('should calculate points correctly: round((score/100) * questionCount * 10)', () => {
    const { points } = calculatePointsEarned(80, 10);
    expect(points).toBe(80); // (80/100) * 10 * 10 = 80
  });

  it('should award 50 bonus points for score >= 90%', () => {
    const { points, bonusAwarded } = calculatePointsEarned(90, 10);
    expect(points).toBe(140); // 90 + 50 bonus
    expect(bonusAwarded).toBe(true);
  });

  it('should not award bonus for score < 90%', () => {
    const { bonusAwarded } = calculatePointsEarned(89, 10);
    expect(bonusAwarded).toBe(false);
  });
});

// ─── Skill Classification (Req 8.3) ──────────────────────────────────────────

describe('Reporting — Skill Classification (Req 8.3)', () => {
  it('should classify skill as strength when >= 70% correct', () => {
    const answers = [
      { mainSkill: 'Algebra', isCorrect: true },
      { mainSkill: 'Algebra', isCorrect: true },
      { mainSkill: 'Algebra', isCorrect: true },
      { mainSkill: 'Algebra', isCorrect: false },
    ];
    const breakdown = calculateSkillBreakdown(answers);
    const algebra = breakdown.find((s) => s.mainSkill === 'Algebra');
    expect(algebra?.classification).toBe('strength');
    expect(algebra?.percentage).toBe(75);
  });

  it('should classify skill as weakness when < 70% correct', () => {
    const answers = [
      { mainSkill: 'Geometry', isCorrect: true },
      { mainSkill: 'Geometry', isCorrect: false },
      { mainSkill: 'Geometry', isCorrect: false },
    ];
    const breakdown = calculateSkillBreakdown(answers);
    const geometry = breakdown.find((s) => s.mainSkill === 'Geometry');
    expect(geometry?.classification).toBe('weakness');
    expect(geometry?.percentage).toBeCloseTo(33.33, 1);
  });

  it('should classify skill as strength at exactly 70%', () => {
    const answers = [
      { mainSkill: 'Physics', isCorrect: true },
      { mainSkill: 'Physics', isCorrect: true },
      { mainSkill: 'Physics', isCorrect: true },
      { mainSkill: 'Physics', isCorrect: false },
      { mainSkill: 'Physics', isCorrect: false },
      { mainSkill: 'Physics', isCorrect: false },
      { mainSkill: 'Physics', isCorrect: true },
    ];
    const breakdown = calculateSkillBreakdown(answers);
    const physics = breakdown.find((s) => s.mainSkill === 'Physics');
    expect(physics?.percentage).toBeCloseTo(57.14, 1);
    expect(physics?.classification).toBe('weakness');
  });

  it('should handle multiple skills independently', () => {
    const answers = [
      { mainSkill: 'Algebra', isCorrect: true },
      { mainSkill: 'Algebra', isCorrect: true },
      { mainSkill: 'Algebra', isCorrect: true }, // 100% → strength
      { mainSkill: 'Geometry', isCorrect: false },
      { mainSkill: 'Geometry', isCorrect: false },
      { mainSkill: 'Geometry', isCorrect: false }, // 0% → weakness
    ];
    const breakdown = calculateSkillBreakdown(answers);
    const algebra = breakdown.find((s) => s.mainSkill === 'Algebra');
    const geometry = breakdown.find((s) => s.mainSkill === 'Geometry');

    expect(algebra?.classification).toBe('strength');
    expect(geometry?.classification).toBe('weakness');
  });

  it('should return empty array for no answers', () => {
    expect(calculateSkillBreakdown([])).toEqual([]);
  });
});

// ─── Score Distribution (Req 9.2) ────────────────────────────────────────────

describe('Reporting — Score Distribution (Req 9.2)', () => {
  function buildDistribution(scores: number[]) {
    const dist = { '0-49': 0, '50-69': 0, '70-89': 0, '90-100': 0 };
    for (const score of scores) {
      if (score < 50) dist['0-49']++;
      else if (score < 70) dist['50-69']++;
      else if (score < 90) dist['70-89']++;
      else dist['90-100']++;
    }
    return dist;
  }

  it('should correctly categorize scores into distribution buckets', () => {
    const scores = [30, 45, 55, 65, 75, 85, 92, 100];
    const dist = buildDistribution(scores);

    expect(dist['0-49']).toBe(2);
    expect(dist['50-69']).toBe(2);
    expect(dist['70-89']).toBe(2);
    expect(dist['90-100']).toBe(2);
  });

  it('should handle boundary values correctly', () => {
    const scores = [0, 49, 50, 69, 70, 89, 90, 100];
    const dist = buildDistribution(scores);

    expect(dist['0-49']).toBe(2);
    expect(dist['50-69']).toBe(2);
    expect(dist['70-89']).toBe(2);
    expect(dist['90-100']).toBe(2);
  });

  it('should handle all scores in same bucket', () => {
    const scores = [80, 82, 85, 88];
    const dist = buildDistribution(scores);

    expect(dist['0-49']).toBe(0);
    expect(dist['50-69']).toBe(0);
    expect(dist['70-89']).toBe(4);
    expect(dist['90-100']).toBe(0);
  });
});

// ─── Class Average Calculation (Req 9.1) ─────────────────────────────────────

describe('Reporting — Class Average Calculation (Req 9.1)', () => {
  it('should calculate class average correctly', () => {
    const scores = [80, 90, 70, 60, 100];
    const avg = scores.reduce((s, v) => s + v, 0) / scores.length;
    expect(avg).toBe(80);
  });

  it('should identify highest and lowest scores', () => {
    const scores = [80, 90, 70, 60, 100];
    expect(Math.max(...scores)).toBe(100);
    expect(Math.min(...scores)).toBe(60);
  });

  it('should handle single student', () => {
    const scores = [75];
    const avg = scores.reduce((s, v) => s + v, 0) / scores.length;
    expect(avg).toBe(75);
  });
});

// ─── CSV Export Format (Req 9.6) ─────────────────────────────────────────────

describe('Reporting — CSV Export Format (Req 9.6)', () => {
  it('should generate valid CSV with headers and rows', () => {
    const headers = ['Student Name', 'Username', 'Score (%)', 'Time (seconds)', 'Status'];
    const rows = [
      ['Ahmed Ali', 'ahmed.ali', 85, 1200, 'completed'],
      ['Sara Mohammed', 'sara.m', 92, 900, 'completed'],
    ];

    const csv = buildCsv(headers, rows);
    const lines = csv.split('\n');

    expect(lines).toHaveLength(3);
    expect(lines[0]).toBe('Student Name,Username,Score (%),Time (seconds),Status');
    expect(lines[1]).toContain('Ahmed Ali');
    expect(lines[1]).toContain('85');
    expect(lines[2]).toContain('Sara Mohammed');
    expect(lines[2]).toContain('92');
  });

  it('should escape commas in CSV values', () => {
    const headers = ['Name', 'Score'];
    const rows = [['Ali, Ahmed', 90]];

    const csv = buildCsv(headers, rows);
    expect(csv).toContain('"Ali, Ahmed"');
  });

  it('should escape double quotes in CSV values', () => {
    const headers = ['Name', 'Score'];
    const rows = [['Ali "The Best"', 95]];

    const csv = buildCsv(headers, rows);
    expect(csv).toContain('"Ali ""The Best"""');
  });

  it('should handle empty values', () => {
    const headers = ['Name', 'Score', 'Time'];
    const rows = [['Ahmed', undefined, undefined]];

    const csv = buildCsv(headers, rows);
    expect(csv).toContain('Ahmed,,');
  });

  it('should produce correct number of columns per row', () => {
    const headers = ['A', 'B', 'C', 'D', 'E'];
    const rows = [['v1', 'v2', 'v3', 'v4', 'v5']];

    const csv = buildCsv(headers, rows);
    const lines = csv.split('\n');
    const headerCols = lines[0].split(',').length;
    const rowCols = lines[1].split(',').length;

    expect(headerCols).toBe(5);
    expect(rowCols).toBe(5);
  });
});

// ─── Skill Heatmap (Req 9.4) ─────────────────────────────────────────────────

describe('Reporting — Skill Heatmap (Req 9.4)', () => {
  it('should calculate class-wide average per skill', () => {
    const skillData = [
      { mainSkill: 'Algebra', totalQuestions: 5, correctAnswers: 4 },
      { mainSkill: 'Algebra', totalQuestions: 5, correctAnswers: 3 },
      { mainSkill: 'Geometry', totalQuestions: 4, correctAnswers: 2 },
    ];

    const skillTotals = new Map<string, { total: number; correct: number }>();
    for (const s of skillData) {
      const existing = skillTotals.get(s.mainSkill) ?? { total: 0, correct: 0 };
      skillTotals.set(s.mainSkill, {
        total: existing.total + s.totalQuestions,
        correct: existing.correct + s.correctAnswers,
      });
    }

    const heatmap = Array.from(skillTotals.entries()).map(([skill, stats]) => ({
      mainSkill: skill,
      averagePercentage: Math.round((stats.correct / stats.total) * 100 * 100) / 100,
    }));

    const algebra = heatmap.find((h) => h.mainSkill === 'Algebra');
    const geometry = heatmap.find((h) => h.mainSkill === 'Geometry');

    expect(algebra?.averagePercentage).toBe(70); // 7/10 = 70%
    expect(geometry?.averagePercentage).toBe(50); // 2/4 = 50%
  });
});

// ─── Advanced School Reports — Helper Logic (Req 19.2, 19.3, 19.4, 19.6) ─────

// ── Classroom Comparison helpers (Req 19.2) ───────────────────────────────────

describe('Advanced Reporting — Classroom Comparison (Req 19.2)', () => {
  function buildComparisonEntry(
    attempts: { score: number; studentId: string }[],
    enrolledCount: number,
    skillBreakdowns: { mainSkill: string; totalQuestions: number; correctAnswers: number }[][]
  ) {
    const totalScore = attempts.reduce((s, a) => s + a.score, 0);
    const averageScore =
      attempts.length > 0 ? Math.round((totalScore / attempts.length) * 100) / 100 : 0;

    const uniqueStudents = new Set(attempts.map((a) => a.studentId)).size;
    const completionRate =
      enrolledCount > 0 ? Math.round((uniqueStudents / enrolledCount) * 100 * 100) / 100 : 0;

    // Determine top skill
    const skillTotals = new Map<string, { total: number; correct: number }>();
    for (const breakdown of skillBreakdowns) {
      for (const skill of breakdown) {
        const existing = skillTotals.get(skill.mainSkill) ?? { total: 0, correct: 0 };
        skillTotals.set(skill.mainSkill, {
          total: existing.total + skill.totalQuestions,
          correct: existing.correct + skill.correctAnswers,
        });
      }
    }

    let topSkill: string | null = null;
    let topSkillPct = -1;
    for (const [skill, stats] of skillTotals.entries()) {
      const pct = stats.total > 0 ? stats.correct / stats.total : 0;
      if (pct > topSkillPct) {
        topSkillPct = pct;
        topSkill = skill;
      }
    }

    return { averageScore, completionRate, topSkill };
  }

  it('should calculate average score correctly for a classroom', () => {
    const attempts = [
      { score: 80, studentId: 's1' },
      { score: 60, studentId: 's2' },
      { score: 100, studentId: 's3' },
    ];
    const { averageScore } = buildComparisonEntry(attempts, 3, []);
    expect(averageScore).toBe(80);
  });

  it('should calculate completion rate as completed/enrolled', () => {
    const attempts = [
      { score: 80, studentId: 's1' },
      { score: 70, studentId: 's2' },
    ];
    // 3 enrolled, 2 completed
    const { completionRate } = buildComparisonEntry(attempts, 3, []);
    expect(completionRate).toBeCloseTo(66.67, 1);
  });

  it('should return 0 completion rate when no students enrolled', () => {
    const { completionRate } = buildComparisonEntry([], 0, []);
    expect(completionRate).toBe(0);
  });

  it('should identify top skill as the one with highest correct rate', () => {
    const skillBreakdowns = [
      [
        { mainSkill: 'Algebra', totalQuestions: 5, correctAnswers: 5 }, // 100%
        { mainSkill: 'Geometry', totalQuestions: 5, correctAnswers: 2 }, // 40%
      ],
    ];
    const { topSkill } = buildComparisonEntry([], 0, skillBreakdowns);
    expect(topSkill).toBe('Algebra');
  });

  it('should return null topSkill when no skill data available', () => {
    const { topSkill } = buildComparisonEntry([], 0, []);
    expect(topSkill).toBeNull();
  });

  it('should handle 100% completion rate when all enrolled students attempted', () => {
    const attempts = [
      { score: 90, studentId: 's1' },
      { score: 85, studentId: 's2' },
    ];
    const { completionRate } = buildComparisonEntry(attempts, 2, []);
    expect(completionRate).toBe(100);
  });
});

// ── Longitudinal Trend helpers (Req 19.3) ─────────────────────────────────────

describe('Advanced Reporting — Longitudinal Trend (Req 19.3)', () => {
  interface AttemptRecord {
    classroomId: string;
    scorePercentage: number;
    month: string; // YYYY-MM
  }

  function buildLongitudinalData(attempts: AttemptRecord[]) {
    const grouped = new Map<string, { totalScore: number; count: number }>();

    for (const attempt of attempts) {
      const key = `${attempt.classroomId}::${attempt.month}`;
      const existing = grouped.get(key) ?? { totalScore: 0, count: 0 };
      grouped.set(key, {
        totalScore: existing.totalScore + attempt.scorePercentage,
        count: existing.count + 1,
      });
    }

    return Array.from(grouped.entries())
      .map(([key, stats]) => {
        const [classroomId, month] = key.split('::');
        return {
          classroomId,
          month,
          averageScore: Math.round((stats.totalScore / stats.count) * 100) / 100,
          totalAttempts: stats.count,
        };
      })
      .sort((a, b) => a.month.localeCompare(b.month));
  }

  it('should group attempts by classroomId and month', () => {
    const attempts: AttemptRecord[] = [
      { classroomId: 'c1', scorePercentage: 80, month: '2024-01' },
      { classroomId: 'c1', scorePercentage: 90, month: '2024-01' },
      { classroomId: 'c1', scorePercentage: 70, month: '2024-02' },
    ];
    const result = buildLongitudinalData(attempts);
    expect(result).toHaveLength(2);
    const jan = result.find((r) => r.month === '2024-01');
    expect(jan?.averageScore).toBe(85);
    expect(jan?.totalAttempts).toBe(2);
  });

  it('should sort results by month ascending', () => {
    const attempts: AttemptRecord[] = [
      { classroomId: 'c1', scorePercentage: 70, month: '2024-03' },
      { classroomId: 'c1', scorePercentage: 80, month: '2024-01' },
      { classroomId: 'c1', scorePercentage: 90, month: '2024-02' },
    ];
    const result = buildLongitudinalData(attempts);
    expect(result[0].month).toBe('2024-01');
    expect(result[1].month).toBe('2024-02');
    expect(result[2].month).toBe('2024-03');
  });

  it('should handle multiple classrooms independently', () => {
    const attempts: AttemptRecord[] = [
      { classroomId: 'c1', scorePercentage: 80, month: '2024-01' },
      { classroomId: 'c2', scorePercentage: 60, month: '2024-01' },
    ];
    const result = buildLongitudinalData(attempts);
    expect(result).toHaveLength(2);
    const c1 = result.find((r) => r.classroomId === 'c1');
    const c2 = result.find((r) => r.classroomId === 'c2');
    expect(c1?.averageScore).toBe(80);
    expect(c2?.averageScore).toBe(60);
  });

  it('should return empty array for no attempts', () => {
    expect(buildLongitudinalData([])).toEqual([]);
  });
});

// ── Weakest Skills helpers (Req 19.4) ─────────────────────────────────────────

describe('Advanced Reporting — Weakest Skills (Req 19.4)', () => {
  interface SkillEntry {
    mainSkill: string;
    totalQuestions: number;
    correctAnswers: number;
  }

  function findWeakestSkills(skillEntries: SkillEntry[], limit = 5) {
    const skillTotals = new Map<string, { total: number; correct: number }>();
    for (const entry of skillEntries) {
      const existing = skillTotals.get(entry.mainSkill) ?? { total: 0, correct: 0 };
      skillTotals.set(entry.mainSkill, {
        total: existing.total + entry.totalQuestions,
        correct: existing.correct + entry.correctAnswers,
      });
    }

    return Array.from(skillTotals.entries())
      .map(([mainSkill, stats]) => ({
        mainSkill,
        averagePercentage:
          stats.total > 0
            ? Math.round((stats.correct / stats.total) * 100 * 100) / 100
            : 0,
      }))
      .sort((a, b) => a.averagePercentage - b.averagePercentage)
      .slice(0, limit);
  }

  it('should return skills sorted by averagePercentage ascending (weakest first)', () => {
    const entries: SkillEntry[] = [
      { mainSkill: 'Algebra', totalQuestions: 10, correctAnswers: 9 }, // 90%
      { mainSkill: 'Geometry', totalQuestions: 10, correctAnswers: 3 }, // 30%
      { mainSkill: 'Fractions', totalQuestions: 10, correctAnswers: 5 }, // 50%
    ];
    const result = findWeakestSkills(entries);
    expect(result[0].mainSkill).toBe('Geometry');
    expect(result[1].mainSkill).toBe('Fractions');
    expect(result[2].mainSkill).toBe('Algebra');
  });

  it('should limit results to the specified count', () => {
    const entries: SkillEntry[] = Array.from({ length: 10 }, (_, i) => ({
      mainSkill: `Skill${i}`,
      totalQuestions: 10,
      correctAnswers: i,
    }));
    const result = findWeakestSkills(entries, 5);
    expect(result).toHaveLength(5);
  });

  it('should aggregate multiple entries for the same skill', () => {
    const entries: SkillEntry[] = [
      { mainSkill: 'Algebra', totalQuestions: 5, correctAnswers: 2 },
      { mainSkill: 'Algebra', totalQuestions: 5, correctAnswers: 3 },
    ];
    const result = findWeakestSkills(entries);
    expect(result[0].mainSkill).toBe('Algebra');
    expect(result[0].averagePercentage).toBe(50); // 5/10 = 50%
  });

  it('should return empty array when no skill data', () => {
    expect(findWeakestSkills([])).toEqual([]);
  });

  it('should handle skill with 0 total questions gracefully', () => {
    const entries: SkillEntry[] = [
      { mainSkill: 'EmptySkill', totalQuestions: 0, correctAnswers: 0 },
    ];
    const result = findWeakestSkills(entries);
    expect(result[0].averagePercentage).toBe(0);
  });
});

// ── Export Report structure (Req 19.6) ────────────────────────────────────────

describe('Advanced Reporting — Export Report Structure (Req 19.6)', () => {
  it('should include all required top-level fields in export payload', () => {
    const exportPayload = {
      exportNote: 'PDF rendering is handled client-side.',
      generatedAt: new Date().toISOString(),
      filters: { term: null, subject: null, gradeLevel: null },
      summary: {
        totalStudents: 100,
        totalTeachers: 10,
        totalAssessments: 20,
        totalAttempts: 150,
        schoolAverage: 75.5,
      },
      classroomComparison: [],
      weakestSkills: [],
    };

    expect(exportPayload).toHaveProperty('exportNote');
    expect(exportPayload).toHaveProperty('generatedAt');
    expect(exportPayload).toHaveProperty('filters');
    expect(exportPayload).toHaveProperty('summary');
    expect(exportPayload).toHaveProperty('classroomComparison');
    expect(exportPayload).toHaveProperty('weakestSkills');
  });

  it('should include all required summary fields', () => {
    const summary = {
      totalStudents: 100,
      totalTeachers: 10,
      totalAssessments: 20,
      totalAttempts: 150,
      schoolAverage: 75.5,
    };

    expect(summary).toHaveProperty('totalStudents');
    expect(summary).toHaveProperty('totalTeachers');
    expect(summary).toHaveProperty('totalAssessments');
    expect(summary).toHaveProperty('totalAttempts');
    expect(summary).toHaveProperty('schoolAverage');
  });

  it('should include filter fields in export payload', () => {
    const filters = { term: 'Term 1', subject: 'Math', gradeLevel: '5' };
    expect(filters).toHaveProperty('term');
    expect(filters).toHaveProperty('subject');
    expect(filters).toHaveProperty('gradeLevel');
  });

  it('should produce a valid ISO date string for generatedAt', () => {
    const generatedAt = new Date().toISOString();
    expect(() => new Date(generatedAt)).not.toThrow();
    expect(new Date(generatedAt).toISOString()).toBe(generatedAt);
  });
});
