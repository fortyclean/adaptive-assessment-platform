import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../../../l10n/app_localizations.dart';
import '../../../l10n/app_localizations_ar.dart';
import '../../../shared/widgets/app_bottom_nav.dart';

/// Teacher task management screen.
///
/// Persistent task APIs are not available yet, so task creation, editing, and
/// deletion use a transparent local state model. This keeps the screen usable
/// for QA/demo flows without pretending that data was saved to the backend.
class TaskManagementScreen extends StatefulWidget {
  const TaskManagementScreen({super.key});

  @override
  State<TaskManagementScreen> createState() => _TaskManagementScreenState();
}

class _TaskManagementScreenState extends State<TaskManagementScreen> {
  int _activeTab = 0;
  int _selectedFilter = 0;
  int _createdCount = 0;

  AppLocalizations get _l10n =>
      Localizations.of<AppLocalizations>(context, AppLocalizations) ??
      AppLocalizationsAr();

  List<_LocalClassroom> get _localClassrooms => [
        _LocalClassroom(
            name: _l10n.demoTaskClassroomGradeSevenB, studentCount: 24),
        _LocalClassroom(
            name: _l10n.demoTaskClassroomGradeNineA, studentCount: 27),
        _LocalClassroom(
            name: _l10n.demoTaskClassroomGradeTenA, studentCount: 28),
        _LocalClassroom(
            name: _l10n.demoTaskClassroomGradeTenB, studentCount: 25),
        _LocalClassroom(
            name: _l10n.demoTaskClassroomGradeElevenC, studentCount: 22),
      ];

  List<_TeacherTask> _tasks = [];
  bool _seededTasks = false;

  List<_TeacherTask> get _initialTasks => [
        _TeacherTask(
          id: 'algebra-10-a',
          subject: _l10n.subjectMathematics,
          title: _l10n.demoTaskAlgebraTitle,
          className: _l10n.demoTaskClassroomGradeTenA,
          assignedStudentCount: 28,
          dueDate: _l10n.demoTaskDueOctober15,
          completionRate: 0.85,
          status: _TaskStatus.active,
          subjectColor: const Color(0xFFD0E1FB),
          subjectTextColor: const Color(0xFF1E40AF),
        ),
        _TeacherTask(
          id: 'physics-11-c',
          subject: _l10n.subjectPhysics,
          title: _l10n.demoTaskNewtonTitle,
          className: _l10n.demoTaskClassroomGradeElevenC,
          assignedStudentCount: 22,
          dueDate: _l10n.demoTaskDueTomorrow,
          completionRate: 0.42,
          status: _TaskStatus.active,
          isUrgent: true,
          subjectColor: const Color(0xFFFFDBCE),
          subjectTextColor: const Color(0xFF802A00),
        ),
        _TeacherTask(
          id: 'stats-10-b',
          subject: _l10n.subjectMathematics,
          title: _l10n.demoTaskStatisticsTitle,
          className: _l10n.demoTaskClassroomGradeTenB,
          assignedStudentCount: 25,
          dueDate: _l10n.demoTaskDueOctober20,
          completionRate: 0.12,
          status: _TaskStatus.draft,
          subjectColor: const Color(0xFFD0E1FB),
          subjectTextColor: const Color(0xFF1E40AF),
        ),
        _TeacherTask(
          id: 'arabic-review',
          subject: _l10n.subjectArabic,
          title: _l10n.demoTaskArabicReviewTitle,
          className: _l10n.demoTaskClassroomGradeNineA,
          assignedStudentCount: 27,
          dueDate: _l10n.completed,
          completionRate: 1,
          status: _TaskStatus.completed,
          subjectColor: const Color(0xFFEADDFF),
          subjectTextColor: const Color(0xFF4F378B),
        ),
      ];

  List<String> get _subjectOptions => [
        _l10n.subjectMathematics,
        _l10n.subjectPhysics,
        _l10n.subjectArabic,
      ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_seededTasks) {
      _tasks = _initialTasks;
      _seededTasks = true;
    }
  }

  List<String> get _tabs => [
        _l10n.activeTasks,
        _l10n.drafts,
        _l10n.completedTasks,
      ];

  List<String> get _filters => [
        _l10n.filterAll,
        ..._subjectOptions,
      ];

  List<_TeacherTask> get _visibleTasks {
    final status = switch (_activeTab) {
      0 => _TaskStatus.active,
      1 => _TaskStatus.draft,
      _ => _TaskStatus.completed,
    };

    return _tasks.where((task) {
      final matchesStatus = task.status == status;
      final matchesFilter =
          _selectedFilter == 0 || task.subject == _filters[_selectedFilter];
      return matchesStatus && matchesFilter;
    }).toList();
  }

  int get _activeCount =>
      _tasks.where((task) => task.status == _TaskStatus.active).length;

  int get _draftCount =>
      _tasks.where((task) => task.status == _TaskStatus.draft).length;

  int get _completedCount =>
      _tasks.where((task) => task.status == _TaskStatus.completed).length;

  @override
  Widget build(BuildContext context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          appBar: _buildAppBar(),
          body: RefreshIndicator(
            onRefresh: () async => setState(() {}),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              children: [
                _buildHeader(),
                const SizedBox(height: 16),
                _buildSummary(),
                const SizedBox(height: 16),
                _buildInfoBanner(),
                const SizedBox(height: 16),
                _buildFilterChips(),
                const SizedBox(height: 16),
                _buildTabs(),
                const SizedBox(height: 16),
                if (_visibleTasks.isEmpty)
                  _EmptyTasksState(
                    tabLabel: _tabs[_activeTab],
                    onCreate: _showTaskEditor,
                  )
                else
                  ..._visibleTasks.map(
                    (task) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _TaskCard(
                        task: task,
                        onEdit: () => _showTaskEditor(task: task),
                        onDelete: () => _confirmDelete(task),
                        onPublish: task.status == _TaskStatus.draft
                            ? () => _publishDraft(task)
                            : null,
                        onComplete: task.status == _TaskStatus.active
                            ? () => _completeTask(task)
                            : null,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _showTaskEditor,
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add),
            label: Text(_l10n.newTask),
          ),
          bottomNavigationBar:
              const AppBottomNav(currentIndex: 1, role: 'teacher'),
        ),
      );

  PreferredSizeWidget _buildAppBar() => AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 1,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surfaceContainer,
                border: Border.all(color: AppColors.outlineVariant),
              ),
              child: const Icon(Icons.assignment_outlined,
                  color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            const Text(
              'EduAssess',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: _l10n.notifications,
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.push(AppRoutes.teacherNotifications),
          ),
        ],
      );

  Widget _buildHeader() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _l10n.taskManagementTitle,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _l10n.taskManagementSubtitle,
            style: const TextStyle(
                color: AppColors.onSurfaceVariant, fontSize: 14),
          ),
        ],
      );

  Widget _buildSummary() => Row(
        children: [
          Expanded(
            child: _SummaryTile(
              icon: Icons.playlist_add_check_outlined,
              label: _l10n.activeSummaryLabel,
              value: _activeCount.toString(),
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _SummaryTile(
              icon: Icons.edit_note_outlined,
              label: _l10n.draftsSummaryLabel,
              value: _draftCount.toString(),
              color: AppColors.warning,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _SummaryTile(
              icon: Icons.verified_outlined,
              label: _l10n.completedSummaryLabel,
              value: _completedCount.toString(),
              color: AppColors.success,
            ),
          ),
        ],
      );

  Widget _buildInfoBanner() => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.18)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.info_outline, color: AppColors.primary, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _l10n.taskManagementLocalOnlyMessage,
                style: const TextStyle(
                  color: AppColors.onSurface,
                  fontSize: 13,
                  height: 1.45,
                ),
              ),
            ),
          ],
        ),
      );

  Widget _buildFilterChips() => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(_filters.length, (index) {
            final selected = _selectedFilter == index;
            return Padding(
              padding: const EdgeInsets.only(left: 8),
              child: ChoiceChip(
                selected: selected,
                label: Text(_filters[index]),
                avatar: index == 0 ? const Icon(Icons.filter_list) : null,
                onSelected: (_) => setState(() => _selectedFilter = index),
                selectedColor: AppColors.primary,
                labelStyle: TextStyle(
                  color: selected ? Colors.white : AppColors.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
                side: BorderSide(
                  color:
                      selected ? AppColors.primary : AppColors.outlineVariant,
                ),
              ),
            );
          }),
        ),
      );

  Widget _buildTabs() => Container(
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.outlineVariant)),
        ),
        child: Row(
          children: List.generate(_tabs.length, (index) {
            final active = _activeTab == index;
            return Expanded(
              child: InkWell(
                onTap: () => setState(() => _activeTab = index),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: active ? AppColors.primary : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                  child: Text(
                    _tabs[index],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: active
                          ? AppColors.primary
                          : AppColors.onSurfaceVariant,
                      fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      );

  Future<void> _showTaskEditor({_TeacherTask? task}) async {
    final result = await showModalBottomSheet<_TaskFormResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _TaskEditorSheet(
        task: task,
        classrooms: _localClassrooms,
      ),
    );

    if (result == null || !mounted) return;

    setState(() {
      if (task == null) {
        _createdCount++;
        _tasks.insert(
          0,
          result.toTask(
            id: 'local-task-$_createdCount',
            subjectColor: _subjectColor(result.subject),
            subjectTextColor: _subjectTextColor(result.subject),
          ),
        );
        _activeTab = result.status == _TaskStatus.draft ? 1 : 0;
      } else {
        final index = _tasks.indexWhere((item) => item.id == task.id);
        if (index != -1) {
          _tasks[index] = result.toTask(
            id: task.id,
            completionRate: task.completionRate,
            subjectColor: _subjectColor(result.subject),
            subjectTextColor: _subjectTextColor(result.subject),
          );
        }
      }
    });
  }

  Future<void> _confirmDelete(_TeacherTask task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(_l10n.deleteTaskTitle),
        content: Text(
          _l10n.deleteTaskConfirmation(task.title),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(_l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(_l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;
    setState(() => _tasks.removeWhere((item) => item.id == task.id));
  }

  void _publishDraft(_TeacherTask task) {
    setState(() {
      final index = _tasks.indexWhere((item) => item.id == task.id);
      if (index != -1) {
        _tasks[index] = task.copyWith(status: _TaskStatus.active);
        _activeTab = 0;
      }
    });
  }

  void _completeTask(_TeacherTask task) {
    setState(() {
      final index = _tasks.indexWhere((item) => item.id == task.id);
      if (index != -1) {
        _tasks[index] =
            task.copyWith(status: _TaskStatus.completed, completionRate: 1);
        _activeTab = 2;
      }
    });
  }

  Color _subjectColor(String subject) => switch (subject) {
        final value when value == _l10n.subjectMathematics =>
          const Color(0xFFD0E1FB),
        final value when value == _l10n.subjectPhysics =>
          const Color(0xFFFFDBCE),
        final value when value == _l10n.subjectArabic =>
          const Color(0xFFEADDFF),
        _ => AppColors.surfaceContainer,
      };

  Color _subjectTextColor(String subject) => switch (subject) {
        final value when value == _l10n.subjectMathematics =>
          const Color(0xFF1E40AF),
        final value when value == _l10n.subjectPhysics =>
          const Color(0xFF802A00),
        final value when value == _l10n.subjectArabic =>
          const Color(0xFF4F378B),
        _ => AppColors.onSurfaceVariant,
      };
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({
    required this.task,
    required this.onEdit,
    required this.onDelete,
    this.onPublish,
    this.onComplete,
  });

  final _TeacherTask task;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onPublish;
  final VoidCallback? onComplete;

  @override
  Widget build(BuildContext context) {
    final l10n = _taskManagementL10n(context);
    final progressPercent = (task.completionRate * 100).round();
    final status = task.status.localizedLabel(l10n);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _Badge(
                          label: task.subject,
                          backgroundColor: task.subjectColor,
                          textColor: task.subjectTextColor,
                        ),
                        _Badge(
                          label: status,
                          backgroundColor:
                              task.status.color.withValues(alpha: 0.12),
                          textColor: task.status.color,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      task.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<_TaskMenuAction>(
                tooltip: l10n.taskOptions,
                onSelected: (action) {
                  switch (action) {
                    case _TaskMenuAction.edit:
                      onEdit();
                    case _TaskMenuAction.publish:
                      onPublish?.call();
                    case _TaskMenuAction.complete:
                      onComplete?.call();
                    case _TaskMenuAction.delete:
                      onDelete();
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: _TaskMenuAction.edit,
                    child: Text(l10n.editTask),
                  ),
                  if (onPublish != null)
                    PopupMenuItem(
                      value: _TaskMenuAction.publish,
                      child: Text(l10n.publishDraft),
                    ),
                  if (onComplete != null)
                    PopupMenuItem(
                      value: _TaskMenuAction.complete,
                      child: Text(l10n.markAsCompleted),
                    ),
                  const PopupMenuDivider(),
                  PopupMenuItem(
                    value: _TaskMenuAction.delete,
                    child: Text(
                      l10n.deleteTask,
                      style: const TextStyle(color: AppColors.error),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _Meta(icon: Icons.groups_outlined, label: task.className),
              _Meta(
                icon: Icons.person_outline,
                label: l10n.studentCountCompact(task.assignedStudentCount),
              ),
              _Meta(
                icon: Icons.event_outlined,
                label: task.dueDate,
                color: task.isUrgent
                    ? AppColors.error
                    : AppColors.onSurfaceVariant,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.completionRate,
                style: const TextStyle(
                    color: AppColors.onSurfaceVariant, fontSize: 12),
              ),
              Text(
                '$progressPercent%',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: task.completionRate,
              backgroundColor: AppColors.surfaceContainer,
              valueColor: AlwaysStoppedAnimation<Color>(task.status.color),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskEditorSheet extends StatefulWidget {
  const _TaskEditorSheet({required this.classrooms, this.task});

  final _TeacherTask? task;
  final List<_LocalClassroom> classrooms;

  @override
  State<_TaskEditorSheet> createState() => _TaskEditorSheetState();
}

class _TaskEditorSheetState extends State<_TaskEditorSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _classController;
  late final TextEditingController _dueDateController;
  late String _subject;
  late _TaskStatus _status;

  @override
  void initState() {
    super.initState();
    final task = widget.task;
    _titleController = TextEditingController(text: task?.title ?? '');
    _classController = TextEditingController(text: task?.className ?? '');
    _dueDateController = TextEditingController(text: task?.dueDate ?? '');
    _subject = task?.subject ?? '';
    _status = task?.status ?? _TaskStatus.active;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _classController.dispose();
    _dueDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = _taskManagementL10n(context);
    if (_subject.isEmpty) {
      _subject = l10n.subjectMathematics;
    }
    if (_dueDateController.text.isEmpty) {
      _dueDateController.text = l10n.dueWithinWeek;
    }
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomPadding),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  widget.task == null ? l10n.createNewTask : l10n.editTask,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.taskEditorLocalOnlyMessage,
                  style: const TextStyle(color: AppColors.onSurfaceVariant),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(labelText: l10n.taskTitle),
                  validator: (value) => value == null || value.trim().length < 3
                      ? l10n.enterClearTaskTitle
                      : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _subject,
                  decoration: InputDecoration(labelText: l10n.subject),
                  items: [
                    l10n.subjectMathematics,
                    l10n.subjectPhysics,
                    l10n.subjectArabic,
                  ]
                      .map((subject) => DropdownMenuItem(
                            value: subject,
                            child: Text(subject),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) setState(() => _subject = value);
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _classController,
                  decoration: InputDecoration(labelText: l10n.classLabel),
                  validator: (value) {
                    final text = value?.trim() ?? '';
                    if (text.isEmpty) return l10n.selectTargetClass;
                    final isKnown =
                        widget.classrooms.any((item) => item.name == text);
                    return isKnown ? null : l10n.chooseSuggestedClass;
                  },
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: widget.classrooms
                      .map(
                        (classroom) => ActionChip(
                          avatar: const Icon(Icons.groups_outlined, size: 16),
                          label: Text(
                            '${classroom.name} · ${l10n.studentCountCompact(classroom.studentCount)}',
                          ),
                          onPressed: () => setState(
                            () => _classController.text = classroom.name,
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _dueDateController,
                  decoration: InputDecoration(labelText: l10n.dueDate),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? l10n.enterDueDate
                      : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<_TaskStatus>(
                  initialValue: _status,
                  decoration: InputDecoration(labelText: l10n.status),
                  items: [
                    DropdownMenuItem(
                      value: _TaskStatus.active,
                      child: Text(l10n.active),
                    ),
                    DropdownMenuItem(
                      value: _TaskStatus.draft,
                      child: Text(l10n.draft),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => _status = value);
                  },
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.check),
                  label:
                      Text(widget.task == null ? l10n.createTask : l10n.save),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    Navigator.pop(
      context,
      _TaskFormResult(
        title: _titleController.text.trim(),
        subject: _subject,
        className: _classController.text.trim(),
        assignedStudentCount: _studentCountFor(_classController.text.trim()),
        dueDate: _dueDateController.text.trim(),
        status: _status,
      ),
    );
  }

  int _studentCountFor(String className) => widget.classrooms
      .firstWhere(
        (classroom) => classroom.name == className,
        orElse: () => const _LocalClassroom(name: '', studentCount: 0),
      )
      .studentCount;
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.18)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
  });

  final String label;
  final Color backgroundColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: textColor,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
}

class _Meta extends StatelessWidget {
  const _Meta({
    required this.icon,
    required this.label,
    this.color = AppColors.onSurfaceVariant,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: color, fontSize: 12)),
        ],
      );
}

class _EmptyTasksState extends StatelessWidget {
  const _EmptyTasksState({required this.tabLabel, required this.onCreate});

  final String tabLabel;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final l10n = _taskManagementL10n(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        children: [
          const Icon(Icons.assignment_late_outlined,
              color: AppColors.onSurfaceVariant, size: 42),
          const SizedBox(height: 12),
          Text(
            l10n.noTasksInTab(tabLabel),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.emptyTasksMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: onCreate,
            icon: const Icon(Icons.add),
            label: Text(l10n.createTask),
          ),
        ],
      ),
    );
  }
}

class _TaskFormResult {
  const _TaskFormResult({
    required this.title,
    required this.subject,
    required this.className,
    required this.assignedStudentCount,
    required this.dueDate,
    required this.status,
  });

  final String title;
  final String subject;
  final String className;
  final int assignedStudentCount;
  final String dueDate;
  final _TaskStatus status;

  _TeacherTask toTask({
    required String id,
    required Color subjectColor,
    required Color subjectTextColor,
    double completionRate = 0,
  }) =>
      _TeacherTask(
        id: id,
        subject: subject,
        title: title,
        className: className,
        assignedStudentCount: assignedStudentCount,
        dueDate: dueDate,
        status: status,
        completionRate: completionRate,
        subjectColor: subjectColor,
        subjectTextColor: subjectTextColor,
      );
}

class _TeacherTask {
  const _TeacherTask({
    required this.id,
    required this.subject,
    required this.title,
    required this.className,
    required this.assignedStudentCount,
    required this.dueDate,
    required this.completionRate,
    required this.status,
    required this.subjectColor,
    required this.subjectTextColor,
    this.isUrgent = false,
  });

  final String id;
  final String subject;
  final String title;
  final String className;
  final int assignedStudentCount;
  final String dueDate;
  final double completionRate;
  final _TaskStatus status;
  final Color subjectColor;
  final Color subjectTextColor;
  final bool isUrgent;

  _TeacherTask copyWith({
    double? completionRate,
    _TaskStatus? status,
  }) =>
      _TeacherTask(
        id: id,
        subject: subject,
        title: title,
        className: className,
        assignedStudentCount: assignedStudentCount,
        dueDate: dueDate,
        completionRate: completionRate ?? this.completionRate,
        status: status ?? this.status,
        subjectColor: subjectColor,
        subjectTextColor: subjectTextColor,
        isUrgent: isUrgent,
      );
}

class _LocalClassroom {
  const _LocalClassroom({required this.name, required this.studentCount});

  final String name;
  final int studentCount;
}

enum _TaskStatus {
  active,
  draft,
  completed;

  String localizedLabel(AppLocalizations l10n) => switch (this) {
        _TaskStatus.active => l10n.active,
        _TaskStatus.draft => l10n.draft,
        _TaskStatus.completed => l10n.completed,
      };

  Color get color => switch (this) {
        _TaskStatus.active => AppColors.primary,
        _TaskStatus.draft => AppColors.warning,
        _TaskStatus.completed => AppColors.success,
      };
}

enum _TaskMenuAction {
  edit,
  publish,
  complete,
  delete,
}

AppLocalizations _taskManagementL10n(BuildContext context) =>
    Localizations.of<AppLocalizations>(context, AppLocalizations) ??
    AppLocalizationsAr();
