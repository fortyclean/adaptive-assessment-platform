import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_version.dart';

/// About Screen — عن التطبيق
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded),
            color: AppColors.primary,
            onPressed: () => context.pop(),
          ),
          title: const Text(
            'عن التطبيق',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
              fontSize: 18,
              fontFamily: 'Almarai',
            ),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildAppHeader(),
            const SizedBox(height: 24),
            _buildCurrentVersion(),
            const SizedBox(height: 24),
            const Text(
              'سجل الإصدارات',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                fontFamily: 'Almarai',
              ),
            ),
            const SizedBox(height: 12),
            ...AppVersion.changelog.map(_buildVersionCard),
            const SizedBox(height: 24),
          ],
        ),
      );

  Widget _buildAppHeader() => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Color(0xFF1E40AF), Color(0xFF3B82F6)],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/app_logo.jpeg',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.school_rounded,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'EduAssess',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w800,
                fontFamily: 'Almarai',
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'منصة التقييم التكيفي الذكي',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontFamily: 'Almarai',
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                AppVersion.display,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontFamily: 'Almarai',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );

  Widget _buildCurrentVersion() {
    final latest = AppVersion.changelog.first;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.success,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'الإصدار الحالي',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontFamily: 'Almarai',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'v${latest.version} — ${latest.date}',
                  textAlign: TextAlign.right,
                  maxLines: 2,
                  softWrap: true,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                    fontFamily: 'Almarai',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            latest.title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              fontFamily: 'Almarai',
            ),
            textAlign: TextAlign.right,
          ),
          const SizedBox(height: 8),
          ...latest.changes.map(
            (c) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_circle,
                      color: AppColors.success, size: 14),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      c,
                      textAlign: TextAlign.right,
                      softWrap: true,
                      style: const TextStyle(
                        fontSize: 13,
                        fontFamily: 'Almarai',
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVersionCard(VersionEntry entry) {
    final isLatest = entry.version == AppVersion.current;
    final color = _typeColor(entry.type);
    final icon = _typeIcon(entry.type);
    final label = _typeLabel(entry.type);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isLatest
              ? AppColors.primary.withValues(alpha: 0.4)
              : AppColors.outlineVariant,
        ),
      ),
      child: Theme(
        data: ThemeData(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      'v${entry.version} — ${entry.title}',
                      textAlign: TextAlign.right,
                      maxLines: 2,
                      softWrap: true,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Almarai',
                        color:
                            isLatest ? AppColors.primary : AppColors.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    entry.date,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.onSurfaceVariant,
                      fontFamily: 'Almarai',
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 10,
                            color: color,
                            fontFamily: 'Almarai',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 3),
                        Icon(icon, size: 12, color: color),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          children: [
            const Divider(height: 1),
            const SizedBox(height: 10),
            ...entry.changes.map(
              (c) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Text(
                        c,
                        style: const TextStyle(
                          fontSize: 13,
                          fontFamily: 'Almarai',
                          color: AppColors.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.fiber_manual_record, size: 6, color: color),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _typeColor(VersionType type) {
    switch (type) {
      case VersionType.release:
        return AppColors.primary;
      case VersionType.feature:
        return AppColors.success;
      case VersionType.fix:
        return const Color(0xFFD97706);
      case VersionType.hotfix:
        return AppColors.error;
    }
  }

  IconData _typeIcon(VersionType type) {
    switch (type) {
      case VersionType.release:
        return Icons.rocket_launch_rounded;
      case VersionType.feature:
        return Icons.add_circle_outline;
      case VersionType.fix:
        return Icons.build_outlined;
      case VersionType.hotfix:
        return Icons.emergency_outlined;
    }
  }

  String _typeLabel(VersionType type) {
    switch (type) {
      case VersionType.release:
        return 'إصدار';
      case VersionType.feature:
        return 'ميزة';
      case VersionType.fix:
        return 'إصلاح';
      case VersionType.hotfix:
        return 'طارئ';
    }
  }
}
