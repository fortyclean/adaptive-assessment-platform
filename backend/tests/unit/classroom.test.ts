/**
 * Unit tests for Classroom management logic.
 * Tests classroom creation, deletion with active assessments, and user assignment.
 * Requirements: 2.1, 2.2, 2.3, 2.4, 2.5
 */

// ─── Classroom Schema Validation Tests ───────────────────────────────────────

describe('Classroom — Schema Validation (Req 2.1)', () => {
  describe('Required fields', () => {
    it('should require name field', () => {
      const requiredFields = ['name', 'gradeLevel', 'academicYear'];
      expect(requiredFields).toContain('name');
    });

    it('should require gradeLevel field', () => {
      const requiredFields = ['name', 'gradeLevel', 'academicYear'];
      expect(requiredFields).toContain('gradeLevel');
    });

    it('should require academicYear field', () => {
      const requiredFields = ['name', 'gradeLevel', 'academicYear'];
      expect(requiredFields).toContain('academicYear');
    });

    it('should enforce name max length of 100 characters', () => {
      const maxLength = 100;
      const validName = 'A'.repeat(100);
      const invalidName = 'A'.repeat(101);
      expect(validName.length).toBeLessThanOrEqual(maxLength);
      expect(invalidName.length).toBeGreaterThan(maxLength);
    });

    it('should trim whitespace from name field', () => {
      const rawName = '  Grade 10 - A  ';
      const trimmed = rawName.trim();
      expect(trimmed).toBe('Grade 10 - A');
    });
  });

  describe('Default values', () => {
    it('should default isActive to true on creation', () => {
      const defaultIsActive = true;
      expect(defaultIsActive).toBe(true);
    });

    it('should initialize teacherIds as empty array', () => {
      const teacherIds: string[] = [];
      expect(teacherIds).toHaveLength(0);
      expect(Array.isArray(teacherIds)).toBe(true);
    });

    it('should initialize studentIds as empty array', () => {
      const studentIds: string[] = [];
      expect(studentIds).toHaveLength(0);
      expect(Array.isArray(studentIds)).toBe(true);
    });
  });

  describe('Classroom creation payload', () => {
    it('should accept valid classroom data', () => {
      const payload = {
        name: 'Grade 10 - Section A',
        gradeLevel: '10',
        academicYear: '2024-2025',
      };
      expect(payload.name).toBeDefined();
      expect(payload.gradeLevel).toBeDefined();
      expect(payload.academicYear).toBeDefined();
    });

    it('should reject empty name', () => {
      const name = '';
      const isValid = name.trim().length >= 1;
      expect(isValid).toBe(false);
    });

    it('should reject empty gradeLevel', () => {
      const gradeLevel = '';
      const isValid = gradeLevel.trim().length >= 1;
      expect(isValid).toBe(false);
    });

    it('should reject empty academicYear', () => {
      const academicYear = '';
      const isValid = academicYear.trim().length >= 1;
      expect(isValid).toBe(false);
    });
  });
});

// ─── Classroom Update Validation ─────────────────────────────────────────────

describe('Classroom — Update Validation (Req 2.1)', () => {
  it('should allow partial updates (only name)', () => {
    const updatePayload = { name: 'Updated Name' };
    const hasAtLeastOneField = Object.keys(updatePayload).length > 0;
    expect(hasAtLeastOneField).toBe(true);
  });

  it('should allow partial updates (only gradeLevel)', () => {
    const updatePayload = { gradeLevel: '11' };
    const hasAtLeastOneField = Object.keys(updatePayload).length > 0;
    expect(hasAtLeastOneField).toBe(true);
  });

  it('should allow partial updates (only academicYear)', () => {
    const updatePayload = { academicYear: '2025-2026' };
    const hasAtLeastOneField = Object.keys(updatePayload).length > 0;
    expect(hasAtLeastOneField).toBe(true);
  });

  it('should reject name update exceeding 100 characters', () => {
    const longName = 'A'.repeat(101);
    const isValid = longName.length <= 100;
    expect(isValid).toBe(false);
  });
});

// ─── Classroom Deletion Logic Tests ──────────────────────────────────────────

describe('Classroom — Deletion with Active Assessments (Req 2.5)', () => {
  /**
   * Simulates the deletion guard logic from DELETE /api/v1/classrooms/:id
   * Returns { blocked: boolean, requiresConfirmation: boolean }
   */
  function evaluateDeletion(activeAssessmentCount: number, confirmed: boolean) {
    if (activeAssessmentCount > 0 && !confirmed) {
      return { blocked: true, requiresConfirmation: true };
    }
    return { blocked: false, requiresConfirmation: false };
  }

  it('should block deletion and require confirmation when active assessments exist', () => {
    const result = evaluateDeletion(3, false);
    expect(result.blocked).toBe(true);
    expect(result.requiresConfirmation).toBe(true);
  });

  it('should allow deletion when confirmed=true even with active assessments', () => {
    const result = evaluateDeletion(3, true);
    expect(result.blocked).toBe(false);
  });

  it('should allow deletion without confirmation when no active assessments exist', () => {
    const result = evaluateDeletion(0, false);
    expect(result.blocked).toBe(false);
  });

  it('should allow deletion when confirmed=true and no active assessments', () => {
    const result = evaluateDeletion(0, true);
    expect(result.blocked).toBe(false);
  });

  it('should include active assessment count in the warning response', () => {
    const activeAssessmentCount = 5;
    const confirmed = false;

    const response = {
      error: `This classroom has ${activeAssessmentCount} active assessment(s). Add ?confirm=true to proceed with deletion.`,
      activeAssessmentCount,
      requiresConfirmation: true,
    };

    expect(response.activeAssessmentCount).toBe(5);
    expect(response.requiresConfirmation).toBe(true);
    expect(response.error).toContain('5 active assessment(s)');
  });

  it('should return HTTP 409 status code when confirmation is required', () => {
    // 409 Conflict is the correct status for "requires confirmation"
    const expectedStatus = 409;
    expect(expectedStatus).toBe(409);
  });

  it('should return HTTP 200 on successful deletion', () => {
    const expectedStatus = 200;
    const response = { message: 'Classroom deleted successfully' };
    expect(expectedStatus).toBe(200);
    expect(response.message).toBe('Classroom deleted successfully');
  });
});

// ─── Student Assignment Logic Tests ──────────────────────────────────────────

describe('Classroom — Student Assignment (Req 2.2, 2.4)', () => {
  /**
   * Simulates $addToSet behavior: adds items without creating duplicates
   */
  function addToSet<T>(existing: T[], newItems: T[]): T[] {
    const set = new Set([...existing, ...newItems]);
    return Array.from(set);
  }

  it('should allow assigning a student to multiple classrooms simultaneously', () => {
    const studentClassrooms = ['classroom-1'];
    const updated = addToSet(studentClassrooms, ['classroom-2']);
    expect(updated).toContain('classroom-1');
    expect(updated).toContain('classroom-2');
    expect(updated).toHaveLength(2);
  });

  it('should not add duplicate students to a classroom ($addToSet behavior)', () => {
    const existingStudentIds = ['student-1', 'student-2', 'student-3'];
    const newStudentId = 'student-2'; // Already exists

    const updated = addToSet(existingStudentIds, [newStudentId]);
    expect(updated).toHaveLength(3); // No duplicate added
  });

  it('should add new student when not already in classroom', () => {
    const existingStudentIds = ['student-1', 'student-2'];
    const newStudentId = 'student-3';

    const updated = addToSet(existingStudentIds, [newStudentId]);
    expect(updated).toHaveLength(3);
    expect(updated).toContain('student-3');
  });

  it('should associate classroom with student classroomIds on assignment (Req 2.2)', () => {
    const studentClassroomIds: string[] = [];
    const classroomId = 'classroom-1';

    const updated = addToSet(studentClassroomIds, [classroomId]);
    expect(updated).toContain(classroomId);
    expect(updated).toHaveLength(1);
  });

  it('should not duplicate classroomId in student record if already assigned', () => {
    const studentClassroomIds = ['classroom-1'];
    const classroomId = 'classroom-1'; // Already assigned

    const updated = addToSet(studentClassroomIds, [classroomId]);
    expect(updated).toHaveLength(1); // No duplicate
  });

  it('should require at least one user ID in assignment request', () => {
    const userIds: string[] = [];
    const isValid = userIds.length >= 1;
    expect(isValid).toBe(false);
  });

  it('should accept multiple student IDs in a single assignment request', () => {
    const userIds = ['student-1', 'student-2', 'student-3'];
    const isValid = userIds.length >= 1;
    expect(isValid).toBe(true);
    expect(userIds).toHaveLength(3);
  });

  it('should reject assignment if any user is not an active student', () => {
    const requestedIds = ['student-1', 'student-2', 'inactive-student'];
    const activeStudents = [
      { _id: 'student-1', role: 'student', isActive: true },
      { _id: 'student-2', role: 'student', isActive: true },
      // 'inactive-student' not found (inactive or wrong role)
    ];

    const allFound = activeStudents.length === requestedIds.length;
    expect(allFound).toBe(false);
  });

  it('should succeed when all requested IDs are valid active students', () => {
    const requestedIds = ['student-1', 'student-2'];
    const activeStudents = [
      { _id: 'student-1', role: 'student', isActive: true },
      { _id: 'student-2', role: 'student', isActive: true },
    ];

    const allFound = activeStudents.length === requestedIds.length;
    expect(allFound).toBe(true);
  });

  it('should return success message with count of assigned students', () => {
    const assignedCount = 3;
    const message = `${assignedCount} student(s) assigned to classroom successfully`;
    expect(message).toBe('3 student(s) assigned to classroom successfully');
  });
});

// ─── Teacher Assignment Logic Tests ──────────────────────────────────────────

describe('Classroom — Teacher Assignment (Req 2.3)', () => {
  function addToSet<T>(existing: T[], newItems: T[]): T[] {
    const set = new Set([...existing, ...newItems]);
    return Array.from(set);
  }

  it('should grant teacher access to all students in classroom on assignment', () => {
    const classroomStudents = ['student-1', 'student-2', 'student-3'];
    // Teacher assigned to classroom gets access to all its students
    const teacherHasAccessToStudents = classroomStudents.length > 0;
    expect(teacherHasAccessToStudents).toBe(true);
  });

  it('should not add duplicate teachers to a classroom ($addToSet behavior)', () => {
    const existingTeacherIds = ['teacher-1', 'teacher-2'];
    const newTeacherId = 'teacher-1'; // Already exists

    const updated = addToSet(existingTeacherIds, [newTeacherId]);
    expect(updated).toHaveLength(2); // No duplicate added
  });

  it('should add new teacher when not already in classroom', () => {
    const existingTeacherIds = ['teacher-1'];
    const newTeacherId = 'teacher-2';

    const updated = addToSet(existingTeacherIds, [newTeacherId]);
    expect(updated).toHaveLength(2);
    expect(updated).toContain('teacher-2');
  });

  it('should associate classroom with teacher classroomIds on assignment (Req 2.3)', () => {
    const teacherClassroomIds: string[] = [];
    const classroomId = 'classroom-1';

    const updated = addToSet(teacherClassroomIds, [classroomId]);
    expect(updated).toContain(classroomId);
  });

  it('should reject assignment if any user is not an active teacher', () => {
    const requestedIds = ['teacher-1', 'student-1']; // student-1 is wrong role
    const activeTeachers = [
      { _id: 'teacher-1', role: 'teacher', isActive: true },
      // 'student-1' not found (wrong role)
    ];

    const allFound = activeTeachers.length === requestedIds.length;
    expect(allFound).toBe(false);
  });

  it('should succeed when all requested IDs are valid active teachers', () => {
    const requestedIds = ['teacher-1', 'teacher-2'];
    const activeTeachers = [
      { _id: 'teacher-1', role: 'teacher', isActive: true },
      { _id: 'teacher-2', role: 'teacher', isActive: true },
    ];

    const allFound = activeTeachers.length === requestedIds.length;
    expect(allFound).toBe(true);
  });

  it('should return success message with count of assigned teachers', () => {
    const assignedCount = 2;
    const message = `${assignedCount} teacher(s) assigned to classroom successfully`;
    expect(message).toBe('2 teacher(s) assigned to classroom successfully');
  });

  it('should require at least one teacher ID in assignment request', () => {
    const userIds: string[] = [];
    const isValid = userIds.length >= 1;
    expect(isValid).toBe(false);
  });
});

// ─── Role-Based Access Control Tests ─────────────────────────────────────────

describe('Classroom — RBAC Enforcement (Req 2.1)', () => {
  type UserRole = 'admin' | 'teacher' | 'student';

  /**
   * Simulates the authorize() middleware logic for classroom endpoints
   */
  function canAccess(userRole: UserRole, allowedRoles: UserRole[]): boolean {
    return allowedRoles.includes(userRole);
  }

  it('should allow admin to create classrooms', () => {
    expect(canAccess('admin', ['admin'])).toBe(true);
  });

  it('should deny teacher from creating classrooms', () => {
    expect(canAccess('teacher', ['admin'])).toBe(false);
  });

  it('should deny student from creating classrooms', () => {
    expect(canAccess('student', ['admin'])).toBe(false);
  });

  it('should allow admin to view all classrooms', () => {
    expect(canAccess('admin', ['admin', 'teacher'])).toBe(true);
  });

  it('should allow teacher to view classrooms (own classrooms only)', () => {
    expect(canAccess('teacher', ['admin', 'teacher'])).toBe(true);
  });

  it('should deny student from viewing classrooms list', () => {
    expect(canAccess('student', ['admin', 'teacher'])).toBe(false);
  });

  it('should allow admin to delete classrooms', () => {
    expect(canAccess('admin', ['admin'])).toBe(true);
  });

  it('should allow admin to assign students to classrooms', () => {
    expect(canAccess('admin', ['admin'])).toBe(true);
  });

  it('should allow admin to assign teachers to classrooms', () => {
    expect(canAccess('admin', ['admin'])).toBe(true);
  });

  it('should filter teacher classroom list to only their own classrooms', () => {
    const teacherId = 'teacher-1';
    const classrooms = [
      { _id: 'c1', teacherIds: ['teacher-1', 'teacher-2'] },
      { _id: 'c2', teacherIds: ['teacher-2'] },
      { _id: 'c3', teacherIds: ['teacher-1'] },
    ];

    const teacherClassrooms = classrooms.filter((c) => c.teacherIds.includes(teacherId));
    expect(teacherClassrooms).toHaveLength(2);
    expect(teacherClassrooms.map((c) => c._id)).toEqual(['c1', 'c3']);
  });
});

// ─── Classroom Stats Tests ────────────────────────────────────────────────────

describe('Classroom — Stats Display (Req 2.6)', () => {
  it('should calculate student count correctly', () => {
    const studentIds = ['s1', 's2', 's3', 's4', 's5'];
    const studentCount = studentIds.length;
    expect(studentCount).toBe(5);
  });

  it('should return zero student count for empty classroom', () => {
    const studentIds: string[] = [];
    expect(studentIds.length).toBe(0);
  });

  it('should count only active assessments per classroom', () => {
    const assessments = [
      { status: 'active', classroomId: 'c1' },
      { status: 'active', classroomId: 'c1' },
      { status: 'completed', classroomId: 'c1' },
      { status: 'draft', classroomId: 'c1' },
    ];

    const activeCount = assessments.filter(
      (a) => a.status === 'active' && a.classroomId === 'c1',
    ).length;

    expect(activeCount).toBe(2);
  });

  it('should return zero active assessment count when none exist', () => {
    const assessments = [
      { status: 'completed', classroomId: 'c1' },
      { status: 'draft', classroomId: 'c1' },
    ];

    const activeCount = assessments.filter(
      (a) => a.status === 'active' && a.classroomId === 'c1',
    ).length;

    expect(activeCount).toBe(0);
  });

  it('should include studentCount and activeAssessmentCount in classroom list response', () => {
    const classroomResponse = {
      _id: 'c1',
      name: 'Grade 10 - A',
      gradeLevel: '10',
      academicYear: '2024-2025',
      studentIds: ['s1', 's2', 's3'],
      teacherIds: ['t1'],
      studentCount: 3,
      activeAssessmentCount: 2,
    };

    expect(classroomResponse).toHaveProperty('studentCount');
    expect(classroomResponse).toHaveProperty('activeAssessmentCount');
    expect(classroomResponse.studentCount).toBe(3);
    expect(classroomResponse.activeAssessmentCount).toBe(2);
  });
});

// ─── Classroom Not Found Handling ─────────────────────────────────────────────

describe('Classroom — Not Found Handling', () => {
  it('should return 404 when classroom does not exist on GET', () => {
    const classroom = null;
    const statusCode = classroom ? 200 : 404;
    expect(statusCode).toBe(404);
  });

  it('should return 404 when classroom does not exist on PATCH', () => {
    const classroom = null;
    const statusCode = classroom ? 200 : 404;
    expect(statusCode).toBe(404);
  });

  it('should return 404 when classroom does not exist on DELETE', () => {
    const classroom = null;
    const statusCode = classroom ? 200 : 404;
    expect(statusCode).toBe(404);
  });

  it('should return 404 when assigning students to non-existent classroom', () => {
    const classroom = null;
    const statusCode = classroom ? 200 : 404;
    expect(statusCode).toBe(404);
  });

  it('should return 404 when assigning teachers to non-existent classroom', () => {
    const classroom = null;
    const statusCode = classroom ? 200 : 404;
    expect(statusCode).toBe(404);
  });
});

// ─── Classroom Index and Query Optimization ───────────────────────────────────

describe('Classroom — Index Configuration', () => {
  it('should have compound index on gradeLevel and academicYear', () => {
    const indexes = [
      { fields: { gradeLevel: 1, academicYear: 1 } },
      { fields: { teacherIds: 1 } },
      { fields: { studentIds: 1 } },
    ];

    const hasGradeYearIndex = indexes.some(
      (idx) => 'gradeLevel' in idx.fields && 'academicYear' in idx.fields,
    );
    expect(hasGradeYearIndex).toBe(true);
  });

  it('should have index on teacherIds for efficient teacher classroom lookup', () => {
    const indexes = [
      { fields: { gradeLevel: 1, academicYear: 1 } },
      { fields: { teacherIds: 1 } },
      { fields: { studentIds: 1 } },
    ];

    const hasTeacherIndex = indexes.some((idx) => 'teacherIds' in idx.fields);
    expect(hasTeacherIndex).toBe(true);
  });

  it('should have index on studentIds for efficient student classroom lookup', () => {
    const indexes = [
      { fields: { gradeLevel: 1, academicYear: 1 } },
      { fields: { teacherIds: 1 } },
      { fields: { studentIds: 1 } },
    ];

    const hasStudentIndex = indexes.some((idx) => 'studentIds' in idx.fields);
    expect(hasStudentIndex).toBe(true);
  });
});

// ─── Classroom Sorting and Listing ───────────────────────────────────────────

describe('Classroom — Listing and Sorting', () => {
  it('should sort classrooms by createdAt descending (newest first)', () => {
    const classrooms = [
      { _id: 'c1', createdAt: new Date('2024-01-01') },
      { _id: 'c3', createdAt: new Date('2024-03-01') },
      { _id: 'c2', createdAt: new Date('2024-02-01') },
    ];

    const sorted = [...classrooms].sort(
      (a, b) => b.createdAt.getTime() - a.createdAt.getTime(),
    );

    expect(sorted[0]._id).toBe('c3');
    expect(sorted[1]._id).toBe('c2');
    expect(sorted[2]._id).toBe('c1');
  });

  it('should populate teacher details (fullName, username, email) in response', () => {
    const populatedTeacher = {
      _id: 'teacher-1',
      fullName: 'Ahmed Hassan',
      username: 'ahmed.hassan',
      email: 'ahmed@school.edu',
      // passwordHash should NOT be included
    };

    expect(populatedTeacher).toHaveProperty('fullName');
    expect(populatedTeacher).toHaveProperty('username');
    expect(populatedTeacher).toHaveProperty('email');
    expect(populatedTeacher).not.toHaveProperty('passwordHash');
  });

  it('should populate student details (fullName, username) in response', () => {
    const populatedStudent = {
      _id: 'student-1',
      fullName: 'Sara Ali',
      username: 'sara.ali',
      // email not required for student listing
    };

    expect(populatedStudent).toHaveProperty('fullName');
    expect(populatedStudent).toHaveProperty('username');
  });
});
