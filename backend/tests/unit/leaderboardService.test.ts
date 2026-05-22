import { buildLeaderboardResponse, LeaderboardRow } from '../../src/services/leaderboardService';

describe('Leaderboard Service', () => {
  const rows: LeaderboardRow[] = [
    {
      studentId: 'student-low',
      fullName: 'Low Points',
      totalPoints: 120,
      averageScore: 90,
      completedAttempts: 3,
    },
    {
      studentId: 'student-current',
      fullName: 'Current Student',
      totalPoints: 80,
      averageScore: 95,
      completedAttempts: 2,
    },
    {
      studentId: 'student-high',
      fullName: 'High Points',
      totalPoints: 200,
      averageScore: 70,
      completedAttempts: 4,
    },
  ];

  it('sorts students by points, score, and attempts', () => {
    const result = buildLeaderboardResponse(rows, 'student-current', 3);

    expect(result.leaderboard.map((entry) => entry.studentId)).toEqual([
      'student-high',
      'student-low',
      'student-current',
    ]);
    expect(result.leaderboard.map((entry) => entry.rank)).toEqual([1, 2, 3]);
  });

  it('includes current user even when outside the top limit', () => {
    const result = buildLeaderboardResponse(rows, 'student-current', 1);

    expect(result.leaderboard.map((entry) => entry.studentId)).toEqual([
      'student-high',
      'student-current',
    ]);
    expect(result.currentUser?.rank).toBe(3);
    expect(result.currentUser?.isCurrentUser).toBe(true);
  });

  it('rounds display metrics safely', () => {
    const result = buildLeaderboardResponse(
      [
        {
          studentId: 'student-current',
          fullName: 'Current Student',
          totalPoints: 10.4,
          averageScore: 83.36,
          completedAttempts: 1.2,
        },
      ],
      'student-current',
    );

    expect(result.currentUser?.totalPoints).toBe(10);
    expect(result.currentUser?.averageScore).toBe(83.4);
    expect(result.currentUser?.completedAttempts).toBe(1);
  });
});
