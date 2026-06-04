import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/network/api_service.dart';
import '../../../core/utils/download_helper.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/providers/auth_provider.dart';

/// Excel Import Screen.
class ImportExcelScreen extends ConsumerStatefulWidget {
  const ImportExcelScreen({super.key});

  @override
  ConsumerState<ImportExcelScreen> createState() => _ImportExcelScreenState();
}

class _ImportExcelScreenState extends ConsumerState<ImportExcelScreen> {
  bool _isUploading = false;
  double _uploadProgress = 0;
  Map<String, dynamic>? _importResult;
  String? _error;
  String? _selectedFileName;
  final List<Map<String, dynamic>> _importHistory = [];

  bool get _shouldUseDemoFallback {
    final token = ref.read(authProvider).accessToken ?? '';
    return AppConstants.useMockData || token.startsWith('demo-token-');
  }

  Future<void> _pickAndUpload() async {
    final l10n = AppLocalizations.of(context);
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls', 'csv'],
    );

    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    final filePath = file.path;

    if (filePath == null) {
      setState(() => _error = l10n.excelFileAccessFailed);
      return;
    }

    if (file.size > 10 * 1024 * 1024) {
      setState(() => _error = l10n.excelFileTooLarge);
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadProgress = 0;
      _importResult = null;
      _error = null;
      _selectedFileName = file.name;
    });

    try {
      final apiService = ref.read(apiServiceProvider);
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath, filename: file.name),
      });

      final response = await apiService.dio.post(
        '/questions/import',
        data: formData,
        onSendProgress: (sent, total) {
          if (total > 0 && mounted) {
            setState(() => _uploadProgress = sent / total);
          }
        },
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
          receiveTimeout: const Duration(seconds: 60),
        ),
      );

      final data = response.data as Map<String, dynamic>;
      if (mounted) {
        _recordImportResult(file.name, {
          'imported': data['imported'] ?? data['created'] ?? 0,
          'skipped': data['skipped'] ?? data['duplicates'] ?? 0,
          'failed': data['failed'] ?? data['errors']?.length ?? 0,
          'errors': data['errors'] ?? data['details'] ?? [],
        });
      }
    } on DioException catch (e) {
      if (!mounted) return;
      if (_shouldUseDemoFallback &&
          (e.response?.statusCode == 404 || e.response?.statusCode == 405)) {
        _recordImportResult(file.name, _demoResult(file.name));
      } else {
        setState(() {
          _isUploading = false;
          _error = e.response?.data?['error'] as String? ??
              AppLocalizations.of(context).excelUploadFailed;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUploading = false;
          _error = AppLocalizations.of(context).unexpectedImportError(
            e.toString(),
          );
        });
      }
    }
  }

  void _recordImportResult(String fileName, Map<String, dynamic> result) {
    setState(() {
      _isUploading = false;
      _importResult = result;
      _importHistory.insert(0, {
        'date': DateTime.now().toIso8601String(),
        'fileName': fileName,
        'imported': _importResult!['imported'],
        'skipped': _importResult!['skipped'],
        'failed': _importResult!['failed'],
      });
    });
  }

  Map<String, dynamic> _demoResult(String fileName) {
    final l10n = AppLocalizations.of(context);
    final estimated = 10 + (fileName.length % 20);
    return {
      'imported': estimated,
      'skipped': 2,
      'failed': 1,
      'errors': [
        {
          'row': 5,
          'type': 'missing_field',
          'description': l10n.demoMissingSubjectError,
        },
        {
          'row': 12,
          'type': 'duplicate',
          'description': l10n.demoDuplicateQuestionError,
        },
      ],
    };
  }

  Future<void> _downloadTemplate() async {
    final token = ref.read(authProvider).accessToken ?? '';
    await DownloadHelper.downloadExcelTemplate(context, token);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          color: AppColors.primary,
          onPressed: () => context.pop(),
        ),
        title: Text(
          l10n.importFromExcelTitle,
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
            fontFamily: 'Almarai',
          ),
        ),
        actions: [
          TextButton.icon(
            icon: const Icon(
              Icons.download_rounded,
              size: 18,
              color: AppColors.primary,
            ),
            label: Text(
              l10n.downloadTemplate,
              style: const TextStyle(
                color: AppColors.primary,
                fontFamily: 'Almarai',
              ),
            ),
            onPressed: _downloadTemplate,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildInstructionsCard(l10n),
          const SizedBox(height: 16),
          _buildUploadArea(l10n),
          const SizedBox(height: 16),
          if (_error != null) _buildErrorCard(),
          if (_importResult != null) ...[
            _buildResultCard(l10n),
            const SizedBox(height: 16),
          ],
          if (_importHistory.isNotEmpty) ...[
            Text(
              l10n.importHistory,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: 'Almarai',
              ),
            ),
            const SizedBox(height: 8),
            ..._importHistory.map((h) => _buildHistoryTile(h, l10n)),
          ],
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildInstructionsCard(AppLocalizations l10n) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFDDE1FF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  l10n.importInstructions,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                    fontFamily: 'Almarai',
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.info_outline,
                  color: AppColors.primary,
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 10),
            _instructionRow('1', l10n.importInstructionDownloadTemplate),
            _instructionRow('2', l10n.importInstructionFillColumns),
            _instructionRow('3', l10n.importInstructionSaveFile),
            _instructionRow('4', l10n.importInstructionTapUpload),
            const SizedBox(height: 8),
            Text(
              l10n.importRequiredColumns,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.primary,
                fontFamily: 'Almarai',
              ),
              textAlign: TextAlign.right,
            ),
          ],
        ),
      );

  Widget _instructionRow(String num, String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Flexible(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 13,
                  fontFamily: 'Almarai',
                  color: AppColors.primary,
                ),
                textAlign: TextAlign.right,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 22,
              height: 22,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  num,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      );

  Widget _buildUploadArea(AppLocalizations l10n) => GestureDetector(
        onTap: _isUploading ? null : _pickAndUpload,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 180,
          decoration: BoxDecoration(
            color: _isUploading
                ? AppColors.surfaceContainer
                : const Color(0xFFEEEDF7),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color:
                  _isUploading ? AppColors.outlineVariant : AppColors.primary,
              width: 2,
            ),
          ),
          child: Center(
            child: _isUploading
                ? _buildUploadingState(l10n)
                : _buildChooseFileState(l10n),
          ),
        ),
      );

  Widget _buildUploadingState(AppLocalizations l10n) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              value: _uploadProgress > 0 ? _uploadProgress : null,
              strokeWidth: 5,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _uploadProgress > 0
                ? l10n.uploadInProgress((_uploadProgress * 100).toInt())
                : l10n.processingFile,
            style: const TextStyle(
              fontFamily: 'Almarai',
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (_selectedFileName != null) ...[
            const SizedBox(height: 4),
            Text(
              _selectedFileName!,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.onSurfaceVariant,
                fontFamily: 'Almarai',
              ),
            ),
          ],
        ],
      );

  Widget _buildChooseFileState(AppLocalizations l10n) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.upload_file_rounded,
              size: 36,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.tapToChooseExcelFile,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
              fontFamily: 'Almarai',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.excelAllowedTypes,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.onSurfaceVariant,
              fontFamily: 'Almarai',
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              l10n.chooseFile,
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'Almarai',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      );

  Widget _buildErrorCard() => Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.errorContainer,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.error.withValues(alpha: 0.4)),
        ),
        child: Row(
          textDirection: TextDirection.rtl,
          children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _error!,
                style: const TextStyle(
                  color: AppColors.error,
                  fontFamily: 'Almarai',
                ),
                textDirection: TextDirection.rtl,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, size: 18),
              color: AppColors.error,
              onPressed: () => setState(() => _error = null),
            ),
          ],
        ),
      );

  Widget _buildResultCard(AppLocalizations l10n) {
    final imported = _importResult!['imported'] as int? ?? 0;
    final skipped = _importResult!['skipped'] as int? ?? 0;
    final failed = _importResult!['failed'] as int? ?? 0;
    final errors =
        (_importResult!['errors'] as List?)?.cast<Map<String, dynamic>>() ?? [];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                imported > 0 ? Icons.check_circle : Icons.warning_amber_rounded,
                color: imported > 0 ? AppColors.success : AppColors.warning,
                size: 24,
              ),
              Text(
                l10n.importResult,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Almarai',
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _resultBadge(l10n.importedLabel, imported, AppColors.success),
              const SizedBox(width: 10),
              _resultBadge(l10n.skippedLabel, skipped, AppColors.warning),
              const SizedBox(width: 10),
              _resultBadge(l10n.failedLabel, failed, AppColors.error),
            ],
          ),
          if (errors.isNotEmpty) ...[
            const SizedBox(height: 14),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              l10n.errorDetails,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontFamily: 'Almarai',
              ),
            ),
            const SizedBox(height: 8),
            ...errors.map((e) => _buildErrorDetail(e, l10n)),
          ],
          if (imported > 0) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.check_rounded),
                label: Text(
                  l10n.doneAddedQuestions(imported),
                  style: const TextStyle(fontFamily: 'Almarai'),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorDetail(Map<String, dynamic> error, AppLocalizations l10n) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          textDirection: TextDirection.rtl,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.errorContainer,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                l10n.rowNumberLabel((error['row'] ?? '').toString()),
                style: const TextStyle(
                  color: AppColors.error,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Almarai',
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                error['description'] as String? ?? '',
                style: const TextStyle(fontSize: 13, fontFamily: 'Almarai'),
                textDirection: TextDirection.rtl,
              ),
            ),
          ],
        ),
      );

  Widget _resultBadge(String label, int count, Color color) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withValues(alpha: 0.4)),
          ),
          child: Column(
            children: [
              Text(
                '$count',
                style: TextStyle(
                  color: color,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Almarai',
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontFamily: 'Almarai',
                ),
              ),
            ],
          ),
        ),
      );

  Widget _buildHistoryTile(Map<String, dynamic> h, AppLocalizations l10n) {
    final date = DateTime.parse(h['date'] as String);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          const Icon(
            Icons.history_rounded,
            color: AppColors.onSurfaceVariant,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  h['fileName'] as String? ?? l10n.excelFileFallbackName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Almarai',
                    fontSize: 13,
                  ),
                ),
                Text(
                  l10n.importHistorySummary(
                    (h['imported'] ?? 0).toString(),
                    (h['skipped'] ?? 0).toString(),
                    (h['failed'] ?? 0).toString(),
                  ),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.onSurfaceVariant,
                    fontFamily: 'Almarai',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${date.day}/${date.month} ${date.hour}:${date.minute.toString().padLeft(2, '0')}',
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.outline,
              fontFamily: 'Almarai',
            ),
          ),
        ],
      ),
    );
  }
}
