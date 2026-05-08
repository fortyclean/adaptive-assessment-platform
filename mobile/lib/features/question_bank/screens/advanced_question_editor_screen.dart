import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/app_bottom_nav.dart';

/// Advanced Question Editor Screen — Design _75
/// Rich text editor, matching pairs, difficulty selector, unit assignment.
class AdvancedQuestionEditorScreen extends StatefulWidget {
  const AdvancedQuestionEditorScreen({super.key});

  @override
  State<AdvancedQuestionEditorScreen> createState() =>
      _AdvancedQuestionEditorScreenState();
}

class _AdvancedQuestionEditorScreenState
    extends State<AdvancedQuestionEditorScreen> {
  int _selectedDifficulty = 0; // 0=Easy, 1=Mid, 2=Hard
  int _selectedUnit = 0;
  final TextEditingController _questionController = TextEditingController();
  final TextEditingController _wordLimitController =
      TextEditingController(text: '500');

  final List<String> _units = const [
    'Unit 4: Advanced Quantum Mechanics',
    'Unit 5: Thermodynamics & Entropy',
    'Unit 6: Particle Physics Basics',
  ];

  final List<_MatchingPair> _pairs = [
    _MatchingPair(
      itemA: TextEditingController(text: "Schrödinger's Cat"),
      matchB: TextEditingController(text: 'Superposition State'),
    ),
    _MatchingPair(
      itemA: TextEditingController(text: 'Planck Constant'),
      matchB: TextEditingController(text: '6.626 x 10^-34 J·s'),
    ),
  ];

  @override
  void dispose() {
    _questionController.dispose();
    _wordLimitController.dispose();
    for (final p in _pairs) {
      p.itemA.dispose();
      p.matchB.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Page title
                  const Text(
                    'Create Advanced Question',
                    style: TextStyle(
                      fontFamily: 'Lexend',
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1B22),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Design complex assessment tasks with rich media and interactive elements.',
                    style: TextStyle(
                      fontFamily: 'Lexend',
                      fontSize: 14,
                      color: Color(0xFF505F76),
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Global settings bento grid
                  _buildSettingsGrid(),
                  const SizedBox(height: 32),

                  // Essay question editor
                  _buildEssaySection(),
                  const SizedBox(height: 32),

                  // Matching question interface
                  _buildMatchingSection(),
                  const SizedBox(height: 40),

                  // Save actions
                  _buildSaveActions(),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildAIFAB(),
      bottomNavigationBar: const AppBottomNav(
        currentIndex: 1,
        role: 'teacher',
      ),
    );
  }

  // ─── Header ──────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: SizedBox(
        height: 64,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Logo + avatar
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFDDE1FF),
                        width: 2,
                      ),
                      color: AppColors.surfaceContainer,
                    ),
                    child: const Icon(
                      Icons.person_outline,
                      size: 20,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'EduAssess',
                    style: TextStyle(
                      fontFamily: 'Lexend',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E40AF),
                    ),
                  ),
                ],
              ),
              // Notifications
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                color: const Color(0xFF475569),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Settings Grid ───────────────────────────────────────────────────────

  Widget _buildSettingsGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;
        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: constraints.maxWidth / 3 - 8,
                child: _buildDifficultyCard(),
              ),
              const SizedBox(width: 16),
              Expanded(child: _buildUnitCard()),
            ],
          );
        }
        return Column(
          children: [
            _buildDifficultyCard(),
            const SizedBox(height: 12),
            _buildUnitCard(),
          ],
        );
      },
    );
  }

  Widget _buildDifficultyCard() {
    final labels = ['Easy', 'Mid', 'Hard'];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Difficulty Level',
            style: TextStyle(
              fontFamily: 'Lexend',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF505F76),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: labels.asMap().entries.map((entry) {
              final i = entry.key;
              final label = entry.value;
              final isSelected = i == _selectedDifficulty;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedDifficulty = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin: EdgeInsets.only(right: i < 2 ? 6 : 0),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFEFF6FF)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.outlineVariant,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Text(
                      label,
                      style: TextStyle(
                        fontFamily: 'Lexend',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildUnitCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Unit Assignment',
            style: TextStyle(
              fontFamily: 'Lexend',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF505F76),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.outlineVariant),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: _selectedUnit,
                isExpanded: true,
                icon: const Icon(
                  Icons.expand_more,
                  color: AppColors.outline,
                ),
                style: const TextStyle(
                  fontFamily: 'Lexend',
                  fontSize: 14,
                  color: Color(0xFF1A1B22),
                ),
                items: _units.asMap().entries.map((entry) {
                  return DropdownMenuItem<int>(
                    value: entry.key,
                    child: Text(
                      entry.value,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _selectedUnit = v);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Essay Section ───────────────────────────────────────────────────────

  Widget _buildEssaySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Icon(Icons.article_outlined, color: AppColors.primary, size: 22),
            SizedBox(width: 8),
            Text(
              'Essay Question Editor',
              style: TextStyle(
                fontFamily: 'Lexend',
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1B22),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.outlineVariant),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Toolbar
              _buildEditorToolbar(),
              // Text area
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Question Prompt',
                      style: TextStyle(
                        fontFamily: 'Lexend',
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF505F76),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _questionController,
                      maxLines: 6,
                      textAlign: TextAlign.left,
                      decoration: const InputDecoration(
                        hintText:
                            "Describe the implications of Heisenberg's Uncertainty Principle in modern computing systems...",
                        hintStyle: TextStyle(
                          fontFamily: 'Lexend',
                          fontSize: 16,
                          color: Color(0xFFC4C5D5),
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: const TextStyle(
                        fontFamily: 'Lexend',
                        fontSize: 16,
                        color: Color(0xFF1A1B22),
                        height: 1.6,
                      ),
                    ),
                    const Divider(color: Color(0xFFF1F5F9), height: 24),
                    // Footer row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Word limit (LTR: right)
                        Row(
                          children: [
                            const Text(
                              'Word Limit:',
                              style: TextStyle(
                                fontFamily: 'Lexend',
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF505F76),
                              ),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 72,
                              height: 36,
                              child: TextField(
                                controller: _wordLimitController,
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(6),
                                    borderSide: const BorderSide(
                                      color: AppColors.outlineVariant,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(6),
                                    borderSide: const BorderSide(
                                      color: AppColors.outlineVariant,
                                    ),
                                  ),
                                ),
                                style: const TextStyle(
                                  fontFamily: 'Lexend',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        // Auto-grading (LTR: left)
                        Row(
                          children: const [
                            Icon(
                              Icons.spellcheck,
                              size: 18,
                              color: AppColors.outline,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Auto-grading enabled',
                              style: TextStyle(
                                fontFamily: 'Lexend',
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF505F76),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEditorToolbar() {
    final tools = [
      Icons.format_bold,
      Icons.format_italic,
      Icons.format_list_bulleted,
      Icons.image_outlined,
      Icons.link,
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(
        color: Color(0xFFF4F2FC),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
        border: Border(
          bottom: BorderSide(color: Color(0xFFC4C5D5)),
        ),
      ),
      child: Row(
        children: [
          ...tools.map(
            (icon) => _buildToolbarButton(icon),
          ),
          const Spacer(),
          _buildToolbarButton(Icons.functions),
        ],
      ),
    );
  }

  Widget _buildToolbarButton(IconData icon) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, size: 18, color: AppColors.onSurface),
        ),
      ),
    );
  }

  // ─── Matching Section ────────────────────────────────────────────────────

  Widget _buildMatchingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Icon(Icons.sync_alt, color: AppColors.primary, size: 22),
            SizedBox(width: 8),
            Text(
              'Matching Question Interface',
              style: TextStyle(
                fontFamily: 'Lexend',
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1B22),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ..._pairs.asMap().entries.map(
              (entry) => _buildMatchingPair(entry.key, entry.value),
            ),
        // Add pair button
        GestureDetector(
          onTap: () {
            setState(() {
              _pairs.add(
                _MatchingPair(
                  itemA: TextEditingController(),
                  matchB: TextEditingController(),
                ),
              );
            });
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.outlineVariant,
                width: 2,
                style: BorderStyle.solid,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(
                  Icons.add_circle_outline,
                  color: AppColors.outline,
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
                  'Add Another Pair',
                  style: TextStyle(
                    fontFamily: 'Lexend',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.outline,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMatchingPair(int index, _MatchingPair pair) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Item A
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Item A',
                  style: TextStyle(
                    fontFamily: 'Lexend',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF505F76),
                  ),
                ),
                const SizedBox(height: 4),
                TextField(
                  controller: pair.itemA,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide:
                          const BorderSide(color: AppColors.outlineVariant),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide:
                          const BorderSide(color: AppColors.outlineVariant),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  style: const TextStyle(
                    fontFamily: 'Lexend',
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          // Link icon
          Expanded(
            flex: 2,
            child: Center(
              child: Icon(
                Icons.link,
                color: AppColors.outlineVariant,
                size: 22,
              ),
            ),
          ),
          // Match B
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Match B',
                  style: TextStyle(
                    fontFamily: 'Lexend',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF505F76),
                  ),
                ),
                const SizedBox(height: 4),
                TextField(
                  controller: pair.matchB,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide:
                          const BorderSide(color: AppColors.outlineVariant),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide:
                          const BorderSide(color: AppColors.outlineVariant),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  style: const TextStyle(
                    fontFamily: 'Lexend',
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Save Actions ────────────────────────────────────────────────────────

  Widget _buildSaveActions() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary, width: 2),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Save Draft',
              style: TextStyle(
                fontFamily: 'Lexend',
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: 4,
              shadowColor: AppColors.primary.withOpacity(0.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Publish Question',
              style: TextStyle(
                fontFamily: 'Lexend',
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ─── AI FAB ──────────────────────────────────────────────────────────────

  Widget _buildAIFAB() {
    return FloatingActionButton(
      onPressed: () {},
      backgroundColor: const Color(0xFF611E00),
      foregroundColor: Colors.white,
      elevation: 6,
      child: const Icon(Icons.auto_awesome_rounded, size: 26),
    );
  }
}

// ─── Data Model ──────────────────────────────────────────────────────────────

class _MatchingPair {
  _MatchingPair({required this.itemA, required this.matchB});
  final TextEditingController itemA;
  final TextEditingController matchB;
}
