import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fm_dictionary/core/constants/app_routes.dart';
import 'package:fm_dictionary/core/widgets/bento_grid/glass_bento_card.dart';
import 'package:fm_dictionary/data/models/word_model.dart';
import 'package:fm_dictionary/features/learning/presentation/providers/quiz_provider.dart';
import 'package:provider/provider.dart';

// --- CORE / THEMES ---
import '../../../../core/constants/constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_layout.dart';
import '../../../../core/widgets/common/smart_action_button.dart';

// --- MODELS / PROVIDERS / SERVICES ---
import '../../../../data/services/database/word_service.dart';
import '../../../../data/services/features/quiz_service.dart'; // Assumed location of QuizMode enum

class QuizConfigurationScreen extends StatefulWidget {
  final String? initialTopic;

  const QuizConfigurationScreen({super.key, this.initialTopic});

  @override
  State<QuizConfigurationScreen> createState() =>
      _QuizConfigurationScreenState();
}

class _QuizConfigurationScreenState extends State<QuizConfigurationScreen> {
  late String _selectedTopic;
  int _selectedCount = 10;
  QuizMode _selectedMode = QuizMode.viToEn; // Default mode

  final WordService _wordService = WordService();

  final List<int> _questionCounts = [10, 20, 50, -1]; // -1 represents "All"

  final List<Map<String, dynamic>> _modes = [
    {
      'mode': QuizMode.enToVi,
      'title': 'Anh -> Việt',
      'subtitle': 'Đoán nghĩa tiếng Việt',
      'icon': CupertinoIcons.arrow_right_arrow_left_square,
    },
    {
      'mode': QuizMode.viToEn,
      'title': 'Việt -> Anh',
      'subtitle': 'Dịch từ tiếng Việt',
      'icon': CupertinoIcons.arrow_left_right_square_fill,
    },
    {
      'mode': QuizMode.listening,
      'title': 'Nghe (Listening)',
      'subtitle': 'Nghe và chọn từ đúng',
      'icon': CupertinoIcons.headphones,
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedTopic = widget.initialTopic ?? 'All';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // GLOBAL DESIGN SYSTEM: Mesh Gradient Background
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.meshBlue,
            AppColors.meshPurple,
            AppColors.meshMint,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: _buildGlassHeader(context),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.all(AppLayout.defaultPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // SECTION 1: TOPIC SELECTION
                      _buildSectionTitle("Chủ đề từ vựng"),
                      const SizedBox(height: 12),
                      _buildTopicSelectionCard(),
                      const SizedBox(height: 24),

                      // SECTION 2: NUMBER OF QUESTIONS
                      _buildSectionTitle("Số lượng câu hỏi"),
                      const SizedBox(height: 12),
                      _buildQuestionCountSection(),
                      const SizedBox(height: 24),

                      // SECTION 3: MODE SELECTION
                      _buildSectionTitle("Chế độ kiểm tra"),
                      const SizedBox(height: 12),
                      _buildModeSelectionSection(),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),

              // BOTTOM ACTION
              _buildBottomAction(),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // WIDGET BUILDERS
  // ===========================================================================

  PreferredSizeWidget _buildGlassHeader(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: AppBar(
            backgroundColor: Colors.white.withValues(alpha:0.1),
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(
                CupertinoIcons.back,
                color: AppColors.textPrimary,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              "Cài đặt bài kiểm tra",
              style: AppTypography.heading2.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(color: Colors.white.withValues(alpha:0.2), height: 1),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTypography.heading3.copyWith(color: AppColors.textPrimary),
    );
  }

  Widget _buildTopicSelectionCard() {
    return GlassBentoCard(
      onTap: _showTopicPickerBottomSheet,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.meshPurple.withValues(alpha:0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              AppConstants.topicIcons[_selectedTopic] ??
                  CupertinoIcons.book_fill,
              color: AppColors.meshPurple,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Đang chọn",
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _selectedTopic == 'All' ? "Tất cả từ vựng" : _selectedTopic,
                  style: AppTypography.heading3.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(
            CupertinoIcons.chevron_down,
            color: AppColors.textSecondary,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCountSection() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: _questionCounts.map((count) {
        final bool isSelected = _selectedCount == count;
        final String label = count == -1 ? "Tất cả" : "$count Câu";

        return GestureDetector(
          onTap: () => setState(() => _selectedCount = count),
          child: Container(
            width:
                (MediaQuery.of(context).size.width -
                    (AppLayout.defaultPadding * 2) -
                    36) /
                4, // 4 items per row
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.meshBlue.withValues(alpha:0.3)
                  : Colors.white.withValues(alpha:0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? AppColors.meshBlue
                    : Colors.white.withValues(alpha:0.2),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.meshBlue.withValues(alpha:0.3),
                        blurRadius: 10,
                      ),
                    ]
                  : [],
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
            alignment: Alignment.center,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: AppTypography.bodyLarge.copyWith(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildModeSelectionSection() {
    return Column(
      children: _modes.map((modeData) {
        final mode = modeData['mode'] as QuizMode;
        final bool isSelected = _selectedMode == mode;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GestureDetector(
            onTap: () => setState(() => _selectedMode = mode),
            child: Container(
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.meshMint.withValues(alpha:0.2)
                    : Colors.white.withValues(alpha:0.1),
                borderRadius: BorderRadius.circular(
                  AppLayout.bentoBorderRadius,
                ),
                border: Border.all(
                  color: isSelected
                      ? AppColors.meshMint
                      : Colors.white.withValues(alpha:0.15),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: GlassBentoCard(
                onTap:
                    null, // Tap handled by outer GestureDetector to avoid nested tap issues
                child: Row(
                  children: [
                    Icon(
                      modeData['icon'] as IconData,
                      color: isSelected
                          ? AppColors.meshMint
                          : AppColors.textSecondary,
                      size: 28,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            modeData['title'] as String,
                            style: AppTypography.heading3.copyWith(
                              color: isSelected
                                  ? AppColors.textPrimary
                                  : AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            modeData['subtitle'] as String,
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      const Icon(
                        CupertinoIcons.checkmark_circle_fill,
                        color: AppColors.meshMint,
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBottomAction() {
    return Padding(
      padding: EdgeInsets.all(AppLayout.defaultPadding),
      child: SmartActionButton(
        text: "Bắt đầu kiểm tra 🚀",
        isGlass: false,
        isLoading: false,
        onPressed: () {
          // 1. Fetch Words Based on Topic
          List words = _selectedTopic == 'All'
              ? _wordService.getAllWords()
              : _wordService.getWordsByTopic(_selectedTopic);

          // Validation
          if (words.length < 4) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Cần ít nhất 4 từ vựng để tạo bài kiểm tra!'),
                backgroundColor: AppColors.error,
              ),
            );
            return;
          }

          // 2. Slice words based on selected count
          words.shuffle();
          if (_selectedCount != -1 && words.length > _selectedCount) {
            words = words.sublist(0, _selectedCount);
          }

          // 3. Initialize Provider State
          context.read<QuizProvider>().initQuiz(
            words.cast<Word>(),
            _selectedMode,
            isFromRoadmap: false,
          );

          // 4. Navigate to actual Quiz Screen
          // Assuming AppRoutes.quiz exists in your routes map
          Navigator.pushNamed(
            context,
            AppRoutes.quiz,
          ); // Ensure exact route matches your app_routes.dart
        },
      ),
    );
  }

  // ===========================================================================
  // INTERACTION / BOTTOM SHEET
  // ===========================================================================

  void _showTopicPickerBottomSheet() {
    // Generate topic list dynamically from WordService
    final allWords = _wordService.getAllWords();
    final Set<String> topicSet = {'All'};
    for (var w in allWords) {
      topicSet.add(w.topic);
    }
    final topics = topicSet.toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => ClipRRect(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppLayout.bentoBorderRadius),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.6,
            padding: const EdgeInsets.all(AppLayout.defaultPadding),
            decoration: BoxDecoration(
              color: AppColors.meshBlue.withValues(alpha:0.15),
              border: Border(
                top: BorderSide(
                  color: Colors.white.withValues(alpha:0.3),
                  width: 1.5,
                ),
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha:0.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  "Chọn chủ đề",
                  style: AppTypography.heading2.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    itemCount: topics.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final topic = topics[index];
                      final isSelected = _selectedTopic == topic;

                      return ListTile(
                        onTap: () {
                          setState(() => _selectedTopic = topic);
                          Navigator.pop(context);
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        tileColor: isSelected
                            ? Colors.white.withValues(alpha:0.2)
                            : Colors.transparent,
                        leading: Icon(
                          AppConstants.topicIcons[topic] ??
                              CupertinoIcons.book_fill,
                          color: isSelected
                              ? AppColors.meshMint
                              : AppColors.textSecondary,
                        ),
                        title: Text(
                          topic == 'All' ? 'Tất cả từ vựng' : topic,
                          style: AppTypography.bodyLarge.copyWith(
                            color: isSelected
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(
                                CupertinoIcons.checkmark_alt,
                                color: AppColors.meshMint,
                              )
                            : null,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
