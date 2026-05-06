import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';

/// Excel Import Screen — Screen 24 & 25
/// Requirements: 4.1–4.6
class ImportExcelScreen extends ConsumerStatefulWidget {
  const ImportExcelScreen({super.key});

  @override
  ConsumerState<ImportExcelScreen> createState() => _ImportExcelScreenState();
}

class _ImportExcelScreenState extends ConsumerState<ImportExcelScreen> {
  bool _isUploading = false;
  Map<String, dynamic>? _importResult;
  String? _error;

  // Simulated import history
  final List<Map<String, dynamic>> _importHistory = [];

  Future<void> _downloadTemplate() async {
    try {
      // In production: open URL or use url_launcher
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('جاري تحميل القالب...')),
      );
    } catch (_) {}
  }

  Future<void> _downloadErrorReport() async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('جاري تحميل تقرير الأخطاء...')),
      );
    } catch (_) {}
  }

  // Simulate file pick and upload
  Future<void> _pickAndUpload() async {
    setState(() {
      _isUploading = true;
      _importResult = null;
      _error = null;
    });

    // Simulate upload delay
    await Future.delayed(const Duration(seconds: 2));

    // In production: use file_picker package and multipart upload
    setState(() {
      _isUploading = false;
      _importResult = {
        'imported': 45,
        'skipped': 3,
        'failed': 2,
        'errors': [
          {
            'row': 5,
            'type': 'missing_field',
            'description': 'حقل المادة مفقود'
          },
          {
            'row': 12,
            'type': 'duplicate',
            'description': 'سؤال مكرر'
          },
        ],
      };
      _importHistory.insert(0, {
        'date': DateTime.now().toIso8601String(),
        'imported': 45,
        'skipped': 3,
        'failed': 2,
      });
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: const Text('استيراد من Excel'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.download_rounded, size: 18),
            label: const Text('القالب'),
            onPressed: _downloadTemplate,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Upload area
          _UploadArea(
            isUploading: _isUploading,
            onTap: _isUploading ? null : _pickAndUpload,
          ),

          const SizedBox(height: 20),

          // Import result
          if (_importResult != null) ...[
            _ImportResultCard(
              result: _importResult!,
              onDownloadErrors: _importResult!['failed'] > 0
                  ? _downloadErrorReport
                  : null,
            ),
            const SizedBox(height: 20),
          ],

          // Import history
          if (_importHistory.isNotEmpty) ...[
            Text('سجل الاستيراد',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ..._importHistory.map((h) => _HistoryTile(history: h)),
          ],
        ],
      ),
    );
}

class _UploadArea extends StatelessWidget {
  const _UploadArea({this.isUploading = false, this.onTap});
  final bool isUploading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 160,
        decoration: BoxDecoration(
          color: isUploading
              ? AppColors.surfaceContainer
              : AppColors.onPrimaryContainer.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUploading ? AppColors.outlineVariant : AppColors.primary,
            width: 2,
          ),
        ),
        child: Center(
          child: isUploading
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 12),
                    Text('جاري الرفع...',
                        style: Theme.of(context).textTheme.bodyMedium),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.upload_file_rounded,
                        size: 48, color: AppColors.primary),
                    const SizedBox(height: 8),
                    Text('اضغط لاختيار ملف Excel',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: AppColors.primary)),
                    const SizedBox(height: 4),
                    Text('.xlsx أو .xls (حتى 10MB)',
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(color: AppColors.onSurfaceVariant)),
                  ],
                ),
        ),
      ),
    );
}

class _ImportResultCard extends StatelessWidget {
  const _ImportResultCard(
      {required this.result, this.onDownloadErrors});
  final Map<String, dynamic> result;
  final VoidCallback? onDownloadErrors;

  @override
  Widget build(BuildContext context) {
    final errors =
        (result['errors'] as List?)?.cast<Map<String, dynamic>>() ?? [];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('نتيجة الاستيراد',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Row(
              children: [
                _ResultBadge(
                    label: 'مستورد',
                    count: result['imported'] as int,
                    color: AppColors.success),
                const SizedBox(width: 12),
                _ResultBadge(
                    label: 'متخطى',
                    count: result['skipped'] as int,
                    color: AppColors.warning),
                const SizedBox(width: 12),
                _ResultBadge(
                    label: 'فاشل',
                    count: result['failed'] as int,
                    color: AppColors.error),
              ],
            ),

            // Error table
            if (errors.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text('تفاصيل الأخطاء',
                  style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              ...errors.map((e) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.errorContainer,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text('${e['row']}',
                              style: const TextStyle(
                                  color: AppColors.error,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700),
                              textAlign: TextAlign.center),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(e['description'] as String? ?? '',
                              style: Theme.of(context).textTheme.bodyMedium),
                        ),
                      ],
                    ),
                  )),
              if (onDownloadErrors != null) ...[
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: onDownloadErrors,
                  icon: const Icon(Icons.download_rounded, size: 16),
                  label: const Text('تحميل تقرير الأخطاء'),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _ResultBadge extends StatelessWidget {
  const _ResultBadge(
      {required this.label, required this.count, required this.color});
  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) => Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color),
        ),
        child: Column(
          children: [
            Text('$count',
                style: TextStyle(
                    color: color,
                    fontSize: 20,
                    fontWeight: FontWeight.w700)),
            Text(label,
                style: TextStyle(color: color, fontSize: 12)),
          ],
        ),
      ),
    );
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.history});
  final Map<String, dynamic> history;

  @override
  Widget build(BuildContext context) {
    final date = DateTime.parse(history['date'] as String);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.history_rounded,
            color: AppColors.onSurfaceVariant),
        title: Text(
            '${history['imported']} مستورد • ${history['skipped']} متخطى • ${history['failed']} فاشل'),
        subtitle: Text(
            '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}'),
      ),
    );
  }
}
