export interface LeaderboardRow {
  studentId: string;
  fullName: string;
  avatarUrl?: string | null;
  totalPoints: number;
  averageScore: number;
  completedAttempts: number;
  latestSubmittedAt?: Date | string | null;
}

export interface RankedLeaderboardEntry extends LeaderboardRow {
  rank: number;
  isCurrentUser: boolean;
}

export interface LeaderboardResponse {
  leaderboard: RankedLeaderboardEntry[];
  currentUser: RankedLeaderboardEntry | null;
  totalStudents: number;
}

export function buildLeaderboardResponse(
  rows: LeaderboardRow[],
  currentUserId: string,
  limit = 10,
): LeaderboardResponse {
  const ranked = rows
    .map((row) => ({
      ...row,
      totalPoints: Math.max(0, Math.round(row.totalPoints || 0)),
      averageScore: Math.round((row.averageScore || 0) * 10) / 10,
      completedAttempts: Math.max(0, Math.round(row.completedAttempts || 0)),
    }))
    .sort((a, b) => {
      if (b.totalPoints !== a.totalPoints) return b.totalPoints - a.totalPoints;
      if (b.averageScore !== a.averageScore) return b.averageScore - a.averageScore;
      return b.completedAttempts - a.completedAttempts;
    })
    .map((row, index) => ({
      ...row,
      rank: index + 1,
      isCurrentUser: row.studentId === currentUserId,
    }));

  const currentUser = ranked.find((row) => row.studentId === currentUserId) ?? null;
  const top = ranked.slice(0, Math.max(1, limit));

  if (currentUser && !top.some((row) => row.studentId === currentUserId)) {
    top.push(currentUser);
  }

  return {
    leaderboard: top,
    currentUser,
    totalStudents: ranked.length,
  };
}
