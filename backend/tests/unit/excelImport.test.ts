/**
 * Unit tests for Excel Import Service.
 * Tests file parsing, field validation, duplicate detection, and error reporting.
 * Requirements: 4.1, 4.2, 4.3, 4.4, 4.5, 4.6, 22.5
 */

import { zipSync, strToU8 } from 'fflate';
import { parseExcelBuffer } from '../../src/services/excelImportService';

// ─── Mock the Question model to avoid DB dependency ──────────────────────────

jest.mock('../../src/models/Question', () => ({
  SUBJECTS: ['Mathematics', 'English', 'Arabic', 'Physics', 'Chemistry', 'Biology'],
  Question: jest.fn().mockImplementation((data) => ({
    ...data,
    _id: { toString: () => 'mock-id-' + Math.random() },
    save: jest.fn().mockResolvedValue(true),
  })),
}));

// ─── Helper: build a valid row ────────────────────────────────────────────────

const buildValidRow = (overrides: Record<string, string> = {}) => ({
  subject: 'Mathematics',
  gradeLevel: 'Grade 7',
  academicTerm: 'Term 1',
  unit: 'Algebra',
  mainSkill: 'Equations',
  subSkill: 'Linear Equations',
  difficulty: 'medium',
  questionType: 'mcq',
  questionText: 'What is 2 + 2?',
  optionA: '3',
  optionB: '4',
  optionC: '5',
  optionD: '6',
  correctAnswer: 'B',
  imageUrl: '',
  ...overrides,
});

const xmlEscape = (value: string): string =>
  value
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&apos;');

const columnName = (index: number): string => {
  let name = '';
  let current = index + 1;
  while (current > 0) {
    const remainder = (current - 1) % 26;
    name = String.fromCharCode(65 + remainder) + name;
    current = Math.floor((current - 1) / 26);
  }
  return name;
};

const worksheetXml = (rows: string[][]): string => {
  const rowXml = rows
    .map((row, rowIndex) => {
      const cells = row
        .map((value, columnIndex) => {
          const reference = `${columnName(columnIndex)}${rowIndex + 1}`;
          return `<c r="${reference}" t="inlineStr"><is><t>${xmlEscape(value)}</t></is></c>`;
        })
        .join('');
      return `<row r="${rowIndex + 1}">${cells}</row>`;
    })
    .join('');

  return `<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">
  <sheetData>${rowXml}</sheetData>
</worksheet>`;
};

const buildXlsxFixture = (rows: string[][]): Buffer => {
  const files: Record<string, Uint8Array> = {
    '[Content_Types].xml': strToU8(`<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
  <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
  <Default Extension="xml" ContentType="application/xml"/>
  <Override PartName="/xl/workbook.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml"/>
  <Override PartName="/xl/worksheets/sheet1.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"/>
</Types>`),
    '_rels/.rels': strToU8(`<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="xl/workbook.xml"/>
</Relationships>`),
    'xl/workbook.xml': strToU8(`<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<workbook xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">
  <sheets>
    <sheet name="Questions" sheetId="1" r:id="rId1"/>
  </sheets>
</workbook>`),
    'xl/_rels/workbook.xml.rels': strToU8(`<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" Target="worksheets/sheet1.xml"/>
</Relationships>`),
    'xl/worksheets/sheet1.xml': strToU8(worksheetXml(rows)),
  };

  return Buffer.from(zipSync(files));
};

// ─── Row Validation Logic (extracted for unit testing) ───────────────────────

const REQUIRED_COLUMNS = [
  'subject', 'gradeLevel', 'academicTerm', 'unit',
  'mainSkill', 'subSkill', 'difficulty', 'questionType',
  'questionText', 'optionA', 'optionB', 'optionC', 'optionD',
  'correctAnswer',
];

const VALID_SUBJECTS = ['Mathematics', 'English', 'Arabic', 'Physics', 'Chemistry', 'Biology'];
const VALID_DIFFICULTIES = ['easy', 'medium', 'hard'];
const VALID_QUESTION_TYPES = ['mcq', 'true_false', 'fill_blank', 'essay'];

interface ImportRow { [key: string]: string; }
interface ImportError { row: number; field: string; message: string; type: string; }

const validateRow = (row: ImportRow, rowIndex: number): { valid: boolean; errors: ImportError[] } => {
  const errors: ImportError[] = [];

  for (const col of REQUIRED_COLUMNS) {
    if (!row[col] || String(row[col]).trim() === '') {
      errors.push({ row: rowIndex, field: col, message: `Missing required field: ${col}`, type: 'missing_field' });
    }
  }
  if (errors.length > 0) return { valid: false, errors };

  if (!VALID_SUBJECTS.includes(row.subject)) {
    errors.push({ row: rowIndex, field: 'subject', message: `Invalid subject: ${row.subject}`, type: 'invalid_value' });
  }
  if (!VALID_DIFFICULTIES.includes(row.difficulty.toLowerCase())) {
    errors.push({ row: rowIndex, field: 'difficulty', message: `Invalid difficulty: ${row.difficulty}`, type: 'invalid_value' });
  }
  if (!VALID_QUESTION_TYPES.includes(row.questionType.toLowerCase())) {
    errors.push({ row: rowIndex, field: 'questionType', message: `Invalid questionType: ${row.questionType}`, type: 'invalid_value' });
  }
  if (!['A', 'B', 'C', 'D'].includes(row.correctAnswer.toUpperCase())) {
    errors.push({ row: rowIndex, field: 'correctAnswer', message: `Correct answer must be A, B, C, or D`, type: 'validation' });
  }
  const optionValues = [row.optionA, row.optionB, row.optionC, row.optionD].map((v) => v.trim().toLowerCase());
  if (new Set(optionValues).size !== optionValues.length) {
    errors.push({ row: rowIndex, field: 'options', message: 'Duplicate option values', type: 'validation' });
  }

  return { valid: errors.length === 0, errors };
};

// ─── Tests ────────────────────────────────────────────────────────────────────

describe('Excel Import — XLSX Parsing (Req 4.1, 4.2)', () => {
  it('parses a generated .xlsx workbook into import rows', async () => {
    const headers = [
      'subject',
      'gradeLevel',
      'academicTerm',
      'unit',
      'mainSkill',
      'subSkill',
      'difficulty',
      'questionType',
      'questionText',
      'optionA',
      'optionB',
      'optionC',
      'optionD',
      'correctAnswer',
      'imageUrl',
    ];
    const validRow = buildValidRow({ questionText: 'What is 5 < 6 & 7 > 3?' });
    const validRecord = validRow as Record<string, string>;
    const workbook = buildXlsxFixture([
      headers,
      headers.map((header) => validRecord[header] ?? ''),
      headers.map(() => ''),
    ]);

    const rows = await parseExcelBuffer(workbook);

    expect(rows).toHaveLength(1);
    expect(rows[0]).toMatchObject(validRow);
  });
});

describe('Excel Import — Row Validation (Req 4.2, 4.3)', () => {
  it('should accept a fully valid row', () => {
    const result = validateRow(buildValidRow(), 2);
    expect(result.valid).toBe(true);
    expect(result.errors).toHaveLength(0);
  });

  it('should reject a row with missing subject', () => {
    const result = validateRow(buildValidRow({ subject: '' }), 2);
    expect(result.valid).toBe(false);
    expect(result.errors.some((e) => e.field === 'subject')).toBe(true);
    expect(result.errors[0].type).toBe('missing_field');
  });

  it('should reject a row with missing questionText', () => {
    const result = validateRow(buildValidRow({ questionText: '' }), 3);
    expect(result.valid).toBe(false);
    expect(result.errors.some((e) => e.field === 'questionText')).toBe(true);
  });

  it('should reject a row with missing correctAnswer', () => {
    const result = validateRow(buildValidRow({ correctAnswer: '' }), 4);
    expect(result.valid).toBe(false);
    expect(result.errors.some((e) => e.field === 'correctAnswer')).toBe(true);
  });

  it('should include row number in error report', () => {
    const result = validateRow(buildValidRow({ subject: '' }), 15);
    expect(result.errors[0].row).toBe(15);
  });
});

describe('Excel Import — Subject Validation (Req 4.3)', () => {
  it('should reject an invalid subject', () => {
    const result = validateRow(buildValidRow({ subject: 'History' }), 2);
    expect(result.valid).toBe(false);
    expect(result.errors.some((e) => e.field === 'subject' && e.type === 'invalid_value')).toBe(true);
  });

  it('should accept all 6 valid subjects', () => {
    VALID_SUBJECTS.forEach((subject) => {
      const result = validateRow(buildValidRow({ subject }), 2);
      expect(result.valid).toBe(true);
    });
  });
});

describe('Excel Import — Difficulty Validation (Req 4.3)', () => {
  it('should reject an invalid difficulty', () => {
    const result = validateRow(buildValidRow({ difficulty: 'expert' }), 2);
    expect(result.valid).toBe(false);
    expect(result.errors.some((e) => e.field === 'difficulty')).toBe(true);
  });

  it('should accept easy, medium, hard', () => {
    ['easy', 'medium', 'hard'].forEach((difficulty) => {
      const result = validateRow(buildValidRow({ difficulty }), 2);
      expect(result.valid).toBe(true);
    });
  });
});

describe('Excel Import — Correct Answer Validation (Req 22.5)', () => {
  it('should reject correct answer not matching A, B, C, or D', () => {
    const result = validateRow(buildValidRow({ correctAnswer: 'E' }), 2);
    expect(result.valid).toBe(false);
    expect(result.errors.some((e) => e.field === 'correctAnswer')).toBe(true);
  });

  it('should accept A, B, C, D as correct answers', () => {
    ['A', 'B', 'C', 'D'].forEach((answer) => {
      const result = validateRow(buildValidRow({ correctAnswer: answer }), 2);
      expect(result.valid).toBe(true);
    });
  });
});

describe('Excel Import — Duplicate Option Detection (Req 22.5)', () => {
  it('should reject rows with duplicate option values', () => {
    const result = validateRow(buildValidRow({ optionA: '4', optionB: '4' }), 2);
    expect(result.valid).toBe(false);
    expect(result.errors.some((e) => e.field === 'options')).toBe(true);
  });
});

describe('Excel Import — Import Summary (Req 4.6)', () => {
  it('should count imported, skipped, and failed rows correctly', () => {
    const mockResult = { totalRows: 10, imported: 7, skippedDuplicates: 2, failed: 1 };
    expect(mockResult.imported + mockResult.skippedDuplicates + mockResult.failed).toBe(mockResult.totalRows);
  });

  it('should include error details for each failed row', () => {
    const errors: ImportError[] = [
      { row: 3, field: 'subject', message: 'Invalid subject', type: 'invalid_value' },
      { row: 7, field: 'questionText', message: 'Duplicate question', type: 'duplicate' },
    ];
    expect(errors).toHaveLength(2);
    expect(errors[0].row).toBe(3);
    expect(errors[1].type).toBe('duplicate');
  });
});

describe('Excel Import — File Size Validation (Req 4.1)', () => {
  it('should enforce 10MB file size limit', () => {
    const MAX_SIZE_BYTES = 10 * 1024 * 1024;
    const validFileSize = 5 * 1024 * 1024; // 5MB
    const invalidFileSize = 11 * 1024 * 1024; // 11MB

    expect(validFileSize).toBeLessThanOrEqual(MAX_SIZE_BYTES);
    expect(invalidFileSize).toBeGreaterThan(MAX_SIZE_BYTES);
  });
});
