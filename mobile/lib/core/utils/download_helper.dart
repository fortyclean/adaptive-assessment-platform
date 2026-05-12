import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';

/// Central helper for all download, share, and export operations.
/// Replaces all fake SnackBar "جاري تحميل..." with real functionality.
class DownloadHelper {
  DownloadHelper._();

  static final _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 60),
  ));

  // ── Open URL in browser ───────────────────────────────────────────────────
  static Future<void> openUrl(String url, BuildContext context) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        _showError(context, 'تعذر فتح الرابط');
      }
    }
  }

  // ── Download file and share ───────────────────────────────────────────────
  static Future<void> downloadAndShare({
    required String url,
    required String fileName,
    required BuildContext context,
    String? token,
    String? subject,
  }) async {
    _showProgress(context, 'جاري تحميل $fileName...');
    try {
      final dir = await getTemporaryDirectory();
      final filePath = '${dir.path}/$fileName';

      await _dio.download(
        url,
        filePath,
        options: Options(
          headers: token != null ? {'Authorization': 'Bearer $token'} : null,
        ),
        onReceiveProgress: (received, total) {
          // Progress tracked internally
        },
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        await Share.shareXFiles(
          [XFile(filePath)],
          subject: subject ?? fileName,
        );
      }
    } on Object catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        _showError(context, 'فشل التحميل: ${_friendlyError(e)}');
      }
    }
  }

  // ── Save text as file and share ───────────────────────────────────────────
  static Future<void> shareTextAsFile({
    required String content,
    required String fileName,
    required BuildContext context,
    String? subject,
  }) async {
    try {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/$fileName');
      await file.writeAsString(content);
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: subject ?? fileName,
      );
    } on Object catch (e) {
      if (context.mounted) {
        _showError(context, 'فشل التصدير: ${_friendlyError(e)}');
      }
    }
  }

  // ── Share text directly ───────────────────────────────────────────────────
  static Future<void> shareText({
    required String text,
    required BuildContext context,
    String? subject,
  }) async {
    try {
      await Share.share(text, subject: subject);
    } on Object {
      if (context.mounted) {
        _showError(context, 'فشل المشاركة');
      }
    }
  }

  // ── Download Excel template ───────────────────────────────────────────────
  static Future<void> downloadExcelTemplate(
      BuildContext context, String token) async {
    // Backend returns JSON template — convert to CSV for download
    try {
      _showProgress(context, 'جاري تحميل قالب الأسئلة...');
      final response = await _dio.get<Map<String, dynamic>>(
        '${AppConstants.apiBaseUrl}/questions/template/download',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      final template = response.data?['template'] as Map<String, dynamic>?;
      final columns = (template?['columns'] as List?)?.cast<String>() ?? [];
      final example = template?['example'] as Map<String, dynamic>? ?? {};

      // Build CSV content
      final csvLines = [
        columns.join(','),
        columns.map((c) => example[c]?.toString() ?? '').join(','),
      ];

      if (context.mounted) {
        await shareTextAsFile(
          content: csvLines.join('\n'),
          fileName: 'questions_template.csv',
          context: context,
          subject: 'قالب استيراد الأسئلة - EduAssess',
        );
      }
    } on Object {
      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        // Fallback: provide a basic template
        const csvContent =
            'subject,gradeLevel,academicTerm,unit,mainSkill,subSkill,difficulty,questionType,questionText,optionA,optionB,optionC,optionD,correctAnswer\nMathematics,Grade 7,Term 1,Algebra,Equations,Linear Equations,medium,mcq,What is x in 2x+4=10?,2,3,4,5,B';
        await shareTextAsFile(
          content: csvContent,
          fileName: 'questions_template.csv',
          context: context,
          subject: 'قالب استيراد الأسئلة',
        );
      }
    }
  }

  // ── Download certificate as PDF ───────────────────────────────────────────
  static Future<void> downloadCertificate({
    required BuildContext context,
    required String studentName,
    required double score,
    required String grade,
    required String classroomName,
    required String token,
  }) async {
    // Build certificate content as text (PDF generation requires additional package)
    // For now: share as formatted text that can be printed
    final content = '''
شهادة إتمام
═══════════════════════════════

تُمنح هذه الشهادة إلى:
$studentName

لإتمامه بنجاح مادة: $classroomName

الدرجة: ${score.toStringAsFixed(1)}%
التقدير: $grade

العام الدراسي: 2024-2025
تاريخ الإصدار: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}

═══════════════════════════════
منصة EduAssess للتقييم التكيفي
''';

    await shareTextAsFile(
      content: content,
      fileName: 'certificate_$studentName.txt',
      context: context,
      subject: 'شهادة إتمام - $studentName',
    );
  }

  // ── Export report as CSV ──────────────────────────────────────────────────
  static Future<void> exportReportCsv({
    required BuildContext context,
    required List<List<String>> rows,
    required List<String> headers,
    required String fileName,
  }) async {
    final buffer = StringBuffer();
    buffer.writeln(headers.join(','));
    for (final row in rows) {
      buffer.writeln(row.map((cell) {
        final s = cell.replaceAll('"', '""');
        return s.contains(',') || s.contains('\n') ? '"$s"' : s;
      }).join(','));
    }

    await shareTextAsFile(
      content: buffer.toString(),
      fileName: fileName,
      context: context,
      subject: fileName.replaceAll('.csv', ''),
    );
  }

  // ── Send notification via backend ─────────────────────────────────────────
  static Future<bool> sendNotification({
    required String message,
    required String recipientId,
    required String token,
    BuildContext? context,
  }) async {
    try {
      await _dio.post<Map<String, dynamic>>(
        '${AppConstants.apiBaseUrl}/notifications',
        data: {
          'recipientId': recipientId,
          'message': message,
          'type': 'teacher_message'
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return true;
    } on Object catch (error) {
      debugPrint('sendNotification failed: $error');
      return false;
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  static void _showProgress(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white)),
            const SizedBox(width: 12),
            Text(message, style: const TextStyle(fontFamily: 'Almarai')),
          ],
        ),
        duration: const Duration(seconds: 30),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontFamily: 'Almarai')),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static String _friendlyError(Object e) {
    if (e is DioException) {
      if (e.type == DioExceptionType.connectionTimeout) {
        return 'انتهت مهلة الاتصال';
      }
      if (e.response?.statusCode == 401) {
        return 'غير مصرح';
      }
      if (e.response?.statusCode == 404) {
        return 'الملف غير موجود';
      }
    }
    return e.toString().length > 50 ? 'خطأ في الاتصال' : e.toString();
  }
}
