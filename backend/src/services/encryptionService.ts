/**
 * Encryption Service
 *
 * AES-256-GCM encryption for sensitive student fields stored in MongoDB.
 * Requirements: 12.3, 12.4
 *
 * Usage:
 *   - Encrypt before saving: encrypt(plaintext)
 *   - Decrypt after reading: decrypt(ciphertext)
 *
 * The ENCRYPTION_KEY env variable must be a 32-byte (256-bit) hex string.
 * If not set, encryption is disabled (development mode only).
 *
 * HTTPS/TLS enforcement is handled at the infrastructure level (AWS ALB / nginx).
 * This service handles encryption at rest for sensitive fields.
 */

import crypto from 'crypto';
import { logger } from '../utils/logger';

const ALGORITHM = 'aes-256-gcm';
const IV_LENGTH = 12;   // 96-bit IV recommended for GCM
const TAG_LENGTH = 16;  // 128-bit auth tag

function getEncryptionKey(): Buffer | null {
  const keyHex = process.env.ENCRYPTION_KEY;
  if (!keyHex) {
    if (process.env.NODE_ENV === 'production') {
      logger.error('ENCRYPTION_KEY is not set in production — sensitive data will NOT be encrypted');
    }
    return null;
  }
  const key = Buffer.from(keyHex, 'hex');
  if (key.length !== 32) {
    throw new Error('ENCRYPTION_KEY must be a 32-byte (64-character) hex string');
  }
  return key;
}

/**
 * Encrypts a plaintext string using AES-256-GCM.
 * Returns a base64-encoded string: iv:authTag:ciphertext
 * Returns the original value unchanged if encryption is disabled.
 */
export function encrypt(plaintext: string): string {
  const key = getEncryptionKey();
  if (!key) return plaintext; // encryption disabled

  const iv = crypto.randomBytes(IV_LENGTH);
  const cipher = crypto.createCipheriv(ALGORITHM, key, iv);

  const encrypted = Buffer.concat([cipher.update(plaintext, 'utf8'), cipher.final()]);
  const authTag = cipher.getAuthTag();

  // Format: base64(iv):base64(authTag):base64(ciphertext)
  return [
    iv.toString('base64'),
    authTag.toString('base64'),
    encrypted.toString('base64'),
  ].join(':');
}

/**
 * Decrypts a value produced by encrypt().
 * Returns the original value unchanged if encryption is disabled or
 * if the value does not look like an encrypted string.
 */
export function decrypt(ciphertext: string): string {
  const key = getEncryptionKey();
  if (!key) return ciphertext; // encryption disabled

  const parts = ciphertext.split(':');
  if (parts.length !== 3) {
    // Not an encrypted value — return as-is (handles legacy unencrypted data)
    return ciphertext;
  }

  try {
    const [ivB64, tagB64, dataB64] = parts;
    const iv = Buffer.from(ivB64, 'base64');
    const authTag = Buffer.from(tagB64, 'base64');
    const encryptedData = Buffer.from(dataB64, 'base64');

    const decipher = crypto.createDecipheriv(ALGORITHM, key, iv);
    decipher.setAuthTag(authTag);

    const decrypted = Buffer.concat([decipher.update(encryptedData), decipher.final()]);
    return decrypted.toString('utf8');
  } catch (error) {
    logger.error('Decryption failed', { error });
    throw new Error('Failed to decrypt value — data may be corrupted or key may have changed');
  }
}

/**
 * Returns true if the ENCRYPTION_KEY is configured and valid.
 */
export function isEncryptionEnabled(): boolean {
  try {
    return getEncryptionKey() !== null;
  } catch {
    return false;
  }
}

/**
 * Encrypts an object's specified fields in-place.
 * Useful for encrypting sensitive MongoDB document fields before save.
 */
export function encryptFields<T extends Record<string, unknown>>(
  obj: T,
  fields: (keyof T)[],
): T {
  const result = { ...obj };
  for (const field of fields) {
    if (typeof result[field] === 'string') {
      (result as Record<string, unknown>)[field as string] = encrypt(result[field] as string);
    }
  }
  return result;
}

/**
 * Decrypts an object's specified fields in-place.
 * Useful for decrypting sensitive MongoDB document fields after read.
 */
export function decryptFields<T extends Record<string, unknown>>(
  obj: T,
  fields: (keyof T)[],
): T {
  const result = { ...obj };
  for (const field of fields) {
    if (typeof result[field] === 'string') {
      (result as Record<string, unknown>)[field as string] = decrypt(result[field] as string);
    }
  }
  return result;
}
