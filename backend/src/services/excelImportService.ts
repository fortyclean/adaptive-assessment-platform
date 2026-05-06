import * as XLSX from 'xlsx';
import { Question, SUBJECTS, DifficultyLevel, QuestionType } from '../models/Question';
import mongoose from 'mongoose';
import { logger } from '../utils/logger';

// ─── Types ────────────────────────────────────────────────────────────────────

export interface ImportRow {
  subject: string;
  gradeLevel: string;
  academicTerm: string;
  unit: string;
  mainSkill: string;
  subSkill: string;
  difficulty: string;
  questionType: string;
  questionText: string;
  optionA: string;
  optionB: string;
  optionC: string;
  optionD: string;
  correctAnswer: string;
  imageUrl?: string;
}

export interface ImportError {
  row: number;
  field: string;
  message: string;
  type: 'missing_field' | 'invalid_value' | 'duplicate' | 'validation';
}

export interface ImportResult {
  totalRows: number;
  imported: number;
  skippedDuplicates: number;
  failed: number;
  errors: ImportError[];
  importedQuestionIds: string[];
}

// ─── Required columns ─────────────────────────────────────────────────────────

const REQUIRED_COLUMNS = [
  'subject', 'gradeLevel', 'academicTerm', 'unit',
  'mainSkill', 'subSkill', 'difficulty', 'questionType',
  'questionText', 'optionA', 'optionB', 'optionC', 'optionD',
  'correctAnswer',
];

const VALID_DIFFICULTIES: DifficultyLevel[] = ['easy', 'medium', 'hard'];
const VALID_QUESTION_TYPES: QuestionType[] = ['mcq', 'true_false', 'fill_blank', 'essay'];

// ─── Parse Excel Buffer ───────────────────────────────────────────────────────

export const parseExcelBuffer = (buffer: Buffer): ImportRow[] => {
  const workbook = XLSX.read(buffer, { type: 'buffer' });
  const sheetName = workbook.SheetNames[0];
  const worksheet = workbook.Sheets[sheetName];
  const rows = XLSX.utils.sheet_to_json<ImportRow>(worksheet, { defval: '' });
  return rows;
};

// ─── Validate a Single Row ────────────────────────────────────────────────────

const validateRow = (
  row: ImportRow,
  rowIndex: number,
): { valid: boolean; errors: ImportError[] } => {
  const errors: ImportError[] = [];

  // Check required fields
  for (const col of REQUIRED_COLUMNS) {
    const value = (row as any)[col];
    if (!value || String(value).trim() === '') {
      errors.push({
        row: rowIndex,
        field: col,
        message: `Missing required field: ${col}`,
        type: 'missing_field',
      });
    }
  }

  if (errors.length > 0) return { valid: false, errors };

  // Validate subject
  if (!SUBJECTS.includes(row.subject as typeof SUBJECTS[number])) {
    errors.push({
      row: rowIndex,
      field: 'subject',
      message: `Invalid subject "${row.subject}". Valid: ${SUBJECTS.join(', ')}`,
      type: 'invalid_value',
    });
  }

  // Validate difficulty
  if (!VALID_DIFFICULTIES.includes(row.difficulty.toLowerCase() as DifficultyLevel)) {
    errors.push({
      row: rowIndex,
      field: 'difficulty',
      message: `Invalid difficulty "${row.difficulty}". Valid: easy, medium, hard`,
      type: 'invalid_value',
    });
  }

  // Validate question type
  if (!VALID_QUESTION_TYPES.includes(row.questionType.toLowerCase() as QuestionType)) {
    errors.push({
      row: rowIndex,
      field: 'questionType',
      message: `Invalid questionType "${row.questionType}". Valid: mcq, true_false, fill_blank, essay`,
      type: 'invalid_value',
    });
  }

  // Req 22.5: correct answer must match one of the option keys
  const optionKeys = ['A', 'B', 'C', 'D'];
  if (!optionKeys.includes(row.correctAnswer.toUpperCase())) {
    errors.push({
      row: rowIndex,
      field: 'correctAnswer',
      message: `Correct answer "${row.correctAnswer}" must be A, B, C, or D`,
      type: 'validation',
    });
  }

  // Validate no duplicate option values
  const optionValues = [row.optionA, row.optionB, row.optionC, row.optionD]
    .map((v) => v.trim().toLowerCase());
  const uniqueValues = new Set(optionValues);
  if (uniqueValues.size !== optionValues.length) {
    errors.push({
      row: rowIndex,
      field: 'options',
      message: 'Answer options contain duplicate values',
      type: 'validation',
    });
  }

  return { valid: errors.length === 0, errors };
};

// ─── Main Import Function ─────────────────────────────────────────────────────

export const importQuestionsFromBuffer = async (
  buffer: Buffer,
  createdBy: string,
): Promise<ImportResult> => {
  const result: ImportResult = {
    totalRows: 0,
    imported: 0,
    skippedDuplicates: 0,
    failed: 0,
    errors: [],
    importedQuestionIds: [],
  };

  let rows: ImportRow[];
  try {
    rows = parseExcelBuffer(buffer);
  } catch (error) {
    logger.error('Excel parse error', { error });
    throw new Error('Failed to parse Excel file. Please ensure it is a valid .xlsx or .xls file.');
  }

  result.totalRows = rows.length;

  for (let i = 0; i < rows.length; i++) {
    const rowIndex = i + 2; // Excel rows start at 2 (row 1 is header)
    const row = rows[i];

    // Validate row
    const validation = validateRow(row, rowIndex);
    if (!validation.valid) {
      result.errors.push(...validation.errors);
      result.failed++;
      continue;
    }

    // Build options array
    const options = [
      { key: 'A', value: row.optionA.trim() },
      { key: 'B', value: row.optionB.trim() },
      { key: 'C', value: row.optionC.trim() },
      { key: 'D', value: row.optionD.trim() },
    ];

    try {
      const question = new Question({
        subject: row.subject,
        gradeLevel: row.gradeLevel.trim(),
        academicTerm: row.academicTerm.trim(),
        unit: row.unit.trim(),
        mainSkill: row.mainSkill.trim(),
        subSkill: row.subSkill.trim(),
        difficulty: row.difficulty.toLowerCase() as DifficultyLevel,
        questionType: (row.questionType.toLowerCase() || 'mcq') as QuestionType,
        questionText: row.questionText.trim(),
        options,
        correctAnswer: row.correctAnswer.toUpperCase(),
        imageUrl: row.imageUrl?.trim() || null,
        createdBy: new mongoose.Types.ObjectId(createdBy),
      });

      await question.save();
      result.imported++;
      result.importedQuestionIds.push(question._id.toString());
    } catch (error: unknown) {
      // Req 4.4: skip duplicates, flag in error report
      if ((error as { code?: number }).code === 11000) {
        result.skippedDuplicates++;
        result.errors.push({
          row: rowIndex,
          field: 'questionText',
          message: `Duplicate question skipped: "${row.questionText.substring(0, 50)}..."`,
          type: 'duplicate',
        });
      } else {
        result.failed++;
        result.errors.push({
          row: rowIndex,
          field: 'unknown',
          message: `Failed to save question: ${(error as Error).message}`,
          type: 'validation',
        });
        logger.error('Question save error during import', { error, rowIndex });
      }
    }
  }

  logger.info('Excel import completed', {
    totalRows: result.totalRows,
    imported: result.imported,
    skippedDuplicates: result.skippedDuplicates,
    failed: result.failed,
  });

  return result;
};
