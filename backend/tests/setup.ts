// Jest global test setup
// This file runs before all tests

// Set test environment
process.env.NODE_ENV = 'test';
process.env.JWT_SECRET = 'test_jwt_secret_for_testing_only';
process.env.REFRESH_TOKEN_SECRET = 'test_refresh_secret_for_testing_only';
process.env.MONGODB_URI = 'mongodb://localhost:27017/adaptive_assessment_test';
process.env.REDIS_URL = 'redis://localhost:6379';

// Increase test timeout for integration tests
jest.setTimeout(30000);
