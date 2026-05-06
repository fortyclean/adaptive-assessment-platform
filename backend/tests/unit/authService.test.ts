import {
  hashPassword,
  verifyPassword,
  validatePasswordStrength,
  generateTokens,
  verifyAccessToken,
  verifyRefreshToken,
} from '../../src/services/authService';

// Mock environment variables for tests
process.env.JWT_SECRET = 'test-secret-key-minimum-32-characters-long!!';
process.env.JWT_REFRESH_SECRET = 'test-refresh-secret-key-minimum-32-characters!!';
process.env.JWT_EXPIRES_IN = '8h';
process.env.JWT_REFRESH_EXPIRES_IN = '7d';
process.env.BCRYPT_ROUNDS = '4'; // Low rounds for fast tests

describe('AuthService — Password Utilities', () => {
  describe('hashPassword', () => {
    it('should hash a password and produce a different string', async () => {
      const password = 'TestPassword1';
      const hash = await hashPassword(password);
      expect(hash).not.toBe(password);
      expect(hash.length).toBeGreaterThan(20);
    });

    it('should produce different hashes for the same password (unique salts)', async () => {
      const password = 'TestPassword1';
      const hash1 = await hashPassword(password);
      const hash2 = await hashPassword(password);
      expect(hash1).not.toBe(hash2);
    });
  });

  describe('verifyPassword', () => {
    it('should return true for correct password', async () => {
      const password = 'TestPassword1';
      const hash = await hashPassword(password);
      const result = await verifyPassword(password, hash);
      expect(result).toBe(true);
    });

    it('should return false for incorrect password', async () => {
      const password = 'TestPassword1';
      const hash = await hashPassword(password);
      const result = await verifyPassword('WrongPassword1', hash);
      expect(result).toBe(false);
    });
  });

  describe('validatePasswordStrength', () => {
    it('should accept a valid strong password', () => {
      const result = validatePasswordStrength('StrongPass1');
      expect(result.valid).toBe(true);
    });

    it('should reject password shorter than 8 characters', () => {
      const result = validatePasswordStrength('Short1');
      expect(result.valid).toBe(false);
      expect(result.message).toContain('8 characters');
    });

    it('should reject password without uppercase letter', () => {
      const result = validatePasswordStrength('lowercase1');
      expect(result.valid).toBe(false);
      expect(result.message).toContain('uppercase');
    });

    it('should reject password without lowercase letter', () => {
      const result = validatePasswordStrength('UPPERCASE1');
      expect(result.valid).toBe(false);
      expect(result.message).toContain('lowercase');
    });

    it('should reject password without digit', () => {
      const result = validatePasswordStrength('NoDigitsHere');
      expect(result.valid).toBe(false);
      expect(result.message).toContain('digit');
    });
  });
});

describe('AuthService — JWT Token Utilities', () => {
  const mockPayload = {
    userId: '507f1f77bcf86cd799439011',
    role: 'teacher' as const,
    sessionId: 'session-123',
  };

  describe('generateTokens', () => {
    it('should generate both access and refresh tokens', () => {
      const tokens = generateTokens(mockPayload);
      expect(tokens.accessToken).toBeDefined();
      expect(tokens.refreshToken).toBeDefined();
      expect(typeof tokens.accessToken).toBe('string');
      expect(typeof tokens.refreshToken).toBe('string');
    });

    it('should generate different tokens for different payloads', () => {
      const tokens1 = generateTokens(mockPayload);
      const tokens2 = generateTokens({ ...mockPayload, userId: '507f1f77bcf86cd799439012' });
      expect(tokens1.accessToken).not.toBe(tokens2.accessToken);
    });
  });

  describe('verifyAccessToken', () => {
    it('should verify a valid access token and return payload', () => {
      const tokens = generateTokens(mockPayload);
      const decoded = verifyAccessToken(tokens.accessToken);
      expect(decoded.userId).toBe(mockPayload.userId);
      expect(decoded.role).toBe(mockPayload.role);
      expect(decoded.sessionId).toBe(mockPayload.sessionId);
    });

    it('should throw for an invalid access token', () => {
      expect(() => verifyAccessToken('invalid.token.here')).toThrow();
    });

    it('should throw for a tampered token', () => {
      const tokens = generateTokens(mockPayload);
      const tampered = tokens.accessToken.slice(0, -5) + 'XXXXX';
      expect(() => verifyAccessToken(tampered)).toThrow();
    });
  });

  describe('verifyRefreshToken', () => {
    it('should verify a valid refresh token and return payload', () => {
      const tokens = generateTokens(mockPayload);
      const decoded = verifyRefreshToken(tokens.refreshToken);
      expect(decoded.userId).toBe(mockPayload.userId);
      expect(decoded.role).toBe(mockPayload.role);
    });

    it('should throw for an invalid refresh token', () => {
      expect(() => verifyRefreshToken('invalid.refresh.token')).toThrow();
    });
  });

  describe('RBAC — Role Validation', () => {
    it('should encode admin role correctly in token', () => {
      const adminPayload = { ...mockPayload, role: 'admin' as const };
      const tokens = generateTokens(adminPayload);
      const decoded = verifyAccessToken(tokens.accessToken);
      expect(decoded.role).toBe('admin');
    });

    it('should encode student role correctly in token', () => {
      const studentPayload = { ...mockPayload, role: 'student' as const };
      const tokens = generateTokens(studentPayload);
      const decoded = verifyAccessToken(tokens.accessToken);
      expect(decoded.role).toBe('student');
    });

    it('should encode teacher role correctly in token', () => {
      const tokens = generateTokens(mockPayload);
      const decoded = verifyAccessToken(tokens.accessToken);
      expect(decoded.role).toBe('teacher');
    });
  });
});
