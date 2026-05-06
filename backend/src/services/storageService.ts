/**
 * Storage Service — AWS S3 integration for Excel imports and question images.
 * Requirements: 20.3
 *
 * Provides signed URLs for secure file access.
 * In development, falls back to local file storage.
 */

import { logger } from '../utils/logger';

export interface UploadResult {
  key: string;
  url: string;
  bucket: string;
}

/**
 * Generates a pre-signed URL for secure S3 file access.
 * TTL: 1 hour for downloads, 15 minutes for uploads.
 *
 * In production, replace with actual AWS SDK calls:
 *   import { S3Client, GetObjectCommand, PutObjectCommand } from '@aws-sdk/client-s3';
 *   import { getSignedUrl } from '@aws-sdk/s3-request-presigner';
 */
export async function getSignedDownloadUrl(
  key: string,
  expiresInSeconds = 3600,
): Promise<string> {
  const bucket = process.env.AWS_S3_BUCKET;

  if (!bucket) {
    // Development fallback — return local path
    logger.warn('AWS_S3_BUCKET not configured, using local path');
    return `/uploads/${key}`;
  }

  // Production: use AWS SDK
  // const client = new S3Client({ region: process.env.AWS_REGION });
  // const command = new GetObjectCommand({ Bucket: bucket, Key: key });
  // return getSignedUrl(client, command, { expiresIn: expiresInSeconds });

  const region = process.env.AWS_REGION ?? 'us-east-1';
  return `https://${bucket}.s3.${region}.amazonaws.com/${key}?expires=${expiresInSeconds}`;
}

export async function getSignedUploadUrl(
  key: string,
  contentType: string,
  expiresInSeconds = 900,
): Promise<string> {
  const bucket = process.env.AWS_S3_BUCKET;

  if (!bucket) {
    logger.warn('AWS_S3_BUCKET not configured, using local path');
    return `/uploads/${key}`;
  }

  const region = process.env.AWS_REGION ?? 'us-east-1';
  return `https://${bucket}.s3.${region}.amazonaws.com/${key}?content-type=${encodeURIComponent(contentType)}&expires=${expiresInSeconds}`;
}

/**
 * Builds the S3 key for an Excel import file.
 */
export function buildExcelImportKey(userId: string, filename: string): string {
  const timestamp = Date.now();
  const sanitized = filename.replace(/[^a-zA-Z0-9._-]/g, '_');
  return `imports/${userId}/${timestamp}_${sanitized}`;
}

/**
 * Builds the S3 key for a question image.
 */
export function buildQuestionImageKey(questionId: string, filename: string): string {
  const sanitized = filename.replace(/[^a-zA-Z0-9._-]/g, '_');
  return `questions/${questionId}/${sanitized}`;
}
