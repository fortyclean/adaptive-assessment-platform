import express, { NextFunction, Request, Response } from 'express';
import { zipSync, strToU8 } from 'fflate';
import request from 'supertest';
import questionsRouter from '../../src/routes/questions';
import { importQuestionsFromBuffer } from '../../src/services/excelImportService';

jest.mock('../../src/middleware/authenticate', () => ({
  authenticate: (req: Request, _res: Response, next: NextFunction) => {
    req.user = {
      userId: 'teacher-user',
      role: 'teacher',
      sessionId: 'teacher-session',
    };
    next();
  },
  authorize: () => (_req: Request, _res: Response, next: NextFunction) => next(),
}));

jest.mock('../../src/services/excelImportService', () => ({
  importQuestionsFromBuffer: jest.fn(),
}));

jest.mock('../../src/utils/logger', () => ({
  logger: {
    debug: jest.fn(),
    info: jest.fn(),
    warn: jest.fn(),
    error: jest.fn(),
  },
}));

const mockedImportQuestionsFromBuffer = importQuestionsFromBuffer as jest.MockedFunction<
  typeof importQuestionsFromBuffer
>;

const xlsxMime = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';

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

const createApp = () => {
  const app = express();
  app.use('/api/v1/questions', questionsRouter);
  app.use((error: Error, _req: Request, res: Response, _next: NextFunction) => {
    res.status(400).json({ error: error.message });
  });

  return app;
};

describe('Question import API route', () => {
  beforeEach(() => {
    mockedImportQuestionsFromBuffer.mockReset();
  });

  it('accepts an .xlsx upload and returns the import summary contract', async () => {
    mockedImportQuestionsFromBuffer.mockResolvedValue({
      totalRows: 1,
      imported: 1,
      skippedDuplicates: 0,
      failed: 0,
      errors: [],
      importedQuestionIds: ['question-001'],
    });

    const app = createApp();
    const workbook = buildXlsxFixture([
      ['subject', 'gradeLevel', 'questionText'],
      ['Mathematics', 'Grade 7', 'What is 2 + 2?'],
    ]);

    await request(app)
      .post('/api/v1/questions/import')
      .attach('file', workbook, {
        filename: 'questions.xlsx',
        contentType: xlsxMime,
      })
      .expect(200)
      .expect((response) => {
        expect(response.body).toEqual({
          message: 'Import completed',
          summary: {
            totalRows: 1,
            imported: 1,
            skippedDuplicates: 0,
            failed: 0,
          },
          errors: [],
        });
      });

    expect(mockedImportQuestionsFromBuffer).toHaveBeenCalledWith(
      expect.any(Buffer),
      'teacher-user',
    );
  });

  it('rejects legacy .xls uploads before the import service is called', async () => {
    const app = createApp();

    await request(app)
      .post('/api/v1/questions/import')
      .attach('file', Buffer.from('legacy excel payload'), {
        filename: 'questions.xls',
        contentType: 'application/vnd.ms-excel',
      })
      .expect(400)
      .expect((response) => {
        expect(response.body.error).toContain('Only .xlsx files are allowed');
      });

    expect(mockedImportQuestionsFromBuffer).not.toHaveBeenCalled();
  });
});
