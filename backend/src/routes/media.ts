/**
 * Media Routes — Image Upload for Questions (Post-MVP)
 *
 * POST /api/v1/media/upload  — Upload question image (Req 17.1, 17.2)
 * GET  /api/v1/media/:key    — Get signed URL for image (Req 17.4)
 *
 * Requirements: 17.1, 17.2, 17.4, 17.6
 */

import { Router, Request, Response } from 'express';
import multer from 'multer';
import path from 'path';
import { authenticate, authorize } from '../middleware/authenticate';
import { buildQuestionImageKey, getSignedDownloadUrl } from '../services/storageService';
import { logger } from '../utils/logger';

const router = Router();
router.use(authenticate);

// ─── Multer config for images ─────────────────────────────────────────────────

const ALLOWED_MIME_TYPES = ['image/jpeg', 'image/png', 'image/webp'];
const MAX_IMAGE_SIZE = 2 * 1024 * 1024; // 2MB (Req 17.2)

const imageUpload = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: MAX_IMAGE_SIZE },
  fileFilter: (_req, file, cb) => {
    if (ALLOWED_MIME_TYPES.includes(file.mimetype)) {
      cb(null, true);
    } else {
      cb(new Error('Only JPEG, PNG, and WebP images are allowed'));
    }
  },
});

// ─── POST /api/v1/media/upload ────────────────────────────────────────────────

router.post(
  '/upload',
  authorize('teacher', 'admin'),
  imageUpload.single('image'),
  async (req: Request, res: Response): Promise<void> => {
    try {
      if (!req.file) {
        res.status(400).json({ error: 'No image file uploaded' });
        return;
      }

      const { questionId } = req.body;
      if (!questionId) {
        res.status(400).json({ error: 'questionId is required' });
        return;
      }

      // Validate file type (Req 17.1)
      if (!ALLOWED_MIME_TYPES.includes(req.file.mimetype)) {
        res.status(400).json({
          error: 'Invalid file type. Only JPEG, PNG, and WebP are allowed',
        });
        return;
      }

      // Validate file size (Req 17.2)
      if (req.file.size > MAX_IMAGE_SIZE) {
        res.status(400).json({
          error: `Image too large. Maximum size is 2MB, received ${(req.file.size / 1024 / 1024).toFixed(2)}MB`,
        });
        return;
      }

      const ext = path.extname(req.file.originalname) || '.jpg';
      const key = buildQuestionImageKey(questionId, `image${ext}`);

      // In production: upload to S3
      // const s3Client = new S3Client({ region: process.env.AWS_REGION });
      // await s3Client.send(new PutObjectCommand({
      //   Bucket: process.env.AWS_S3_BUCKET,
      //   Key: key,
      //   Body: req.file.buffer,
      //   ContentType: req.file.mimetype,
      // }));

      // For development: return a local URL
      const imageUrl = await getSignedDownloadUrl(key);

      logger.info('Image uploaded', {
        teacherId: req.user!.userId,
        questionId,
        key,
        size: req.file.size,
        mimeType: req.file.mimetype,
      });

      res.status(201).json({
        imageUrl,
        key,
        size: req.file.size,
        mimeType: req.file.mimetype,
      });
    } catch (error) {
      // Req 17.6: log image failures without interrupting sessions
      logger.error('Image upload error', { error });
      res.status(500).json({ error: 'Image upload failed' });
    }
  },
);

// ─── GET /api/v1/media/:key — Get signed URL ─────────────────────────────────

router.get('/:key(*)', authorize('teacher', 'admin', 'student'), async (req: Request, res: Response): Promise<void> => {
  try {
    const key = req.params.key;
    const signedUrl = await getSignedDownloadUrl(key);
    res.status(200).json({ url: signedUrl });
  } catch (error) {
    logger.warn('Image URL generation failed', { error });
    res.status(404).json({ error: 'Image not found' });
  }
});

export default router;
