import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/app_localizations.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';

/// Central helper for download, share, and export operations.
class DownloadHelper {
  DownloadHelper._();

  static final _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 60),
    ),
  );

  static Future<void> openUrl(String url, BuildContext context) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (context.mounted) {
      _showError(context, AppLocalizations.of(context).couldNotOpenLink);
    }
  }

  static Future<void> downloadAndShare({
    required String url,
    required String fileName,
    required BuildContext context,
    String? token,
    String? subject,
  }) async {
    final l10n = AppLocalizations.of(context);
    _showProgress(context, l10n.downloadingFile(fileName));

    try {
      final dir = await getTemporaryDirectory();
      final filePath = '${dir.path}/$fileName';

      await _dio.download(
        url,
        filePath,
        options: Options(
          headers: token != null ? {'Authorization': 'Bearer $token'} : null,
        ),
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
        final mountedL10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        _showError(
          context,
          mountedL10n.downloadFailedWithReason(
            _friendlyError(e, mountedL10n),
          ),
        );
      }
    }
  }

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
        final l10n = AppLocalizations.of(context);
        _showError(
            context, l10n.exportFailedWithReason(_friendlyError(e, l10n)));
      }
    }
  }

  static Future<void> shareText({
    required String text,
    required BuildContext context,
    String? subject,
  }) async {
    try {
      await Share.share(text, subject: subject);
    } on Object {
      if (context.mounted) {
        _showError(context, AppLocalizations.of(context).shareFailed);
      }
    }
  }

  static Future<void> downloadExcelTemplate(
    BuildContext context,
    String token,
  ) async {
    final l10n = AppLocalizations.of(context);

    try {
      _showProgress(context, l10n.downloadingQuestionTemplate);
      final response = await _dio.get<Map<String, dynamic>>(
        '${AppConstants.apiBaseUrl}/questions/template/download',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      final template = response.data?['template'] as Map<String, dynamic>?;
      final columns = (template?['columns'] as List?)?.cast<String>() ?? [];
      final example = template?['example'] as Map<String, dynamic>? ?? {};

      final csvLines = [
        columns.join(','),
        columns.map((c) => example[c]?.toString() ?? '').join(','),
      ];

      if (context.mounted) {
        await shareTextAsFile(
          content: csvLines.join('\n'),
          fileName: 'questions_template.csv',
          context: context,
          subject: AppLocalizations.of(context).questionTemplateImportSubject,
        );
      }
    } on Object {
      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        const csvContent =
            'subject,gradeLevel,academicTerm,unit,mainSkill,subSkill,difficulty,questionType,questionText,optionA,optionB,optionC,optionD,correctAnswer\nMathematics,Grade 7,Term 1,Algebra,Equations,Linear Equations,medium,mcq,What is x in 2x+4=10?,2,3,4,5,B';
        await shareTextAsFile(
          content: csvContent,
          fileName: 'questions_template.csv',
          context: context,
          subject: AppLocalizations.of(context).questionTemplateSubject,
        );
      }
    }
  }

  static Future<void> downloadCertificate({
    required BuildContext context,
    required String studentName,
    required double score,
    required String grade,
    required String classroomName,
    required String token,
  }) async {
    final l10n = AppLocalizations.of(context);
    final now = DateTime.now();
    final issueDate = '${now.day}/${now.month}/${now.year}';
    final content = l10n.completionCertificateContent(
      studentName,
      classroomName,
      score.toStringAsFixed(1),
      grade,
      issueDate,
    );

    await shareTextAsFile(
      content: content,
      fileName: 'certificate_$studentName.txt',
      context: context,
      subject: l10n.completionCertificateSubject(studentName),
    );
  }

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
          'type': 'teacher_message',
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return true;
    } on Object catch (error) {
      debugPrint('sendNotification failed: $error');
      return false;
    }
  }

  static void _showProgress(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
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

  static String _friendlyError(Object e, AppLocalizations l10n) {
    if (e is DioException) {
      if (e.type == DioExceptionType.connectionTimeout) {
        return l10n.connectionTimeout;
      }
      if (e.response?.statusCode == 401) {
        return l10n.unauthorizedError;
      }
      if (e.response?.statusCode == 404) {
        return l10n.fileNotFound;
      }
    }
    return e.toString().length > 50 ? l10n.connectionError : e.toString();
  }
}
