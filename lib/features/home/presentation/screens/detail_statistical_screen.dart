import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../data/models/word_model.dart';
import '../../../../data/services/database/database_service.dart';
import '../../../../core/constants/constants.dart';

class DetailStatisticalScreen extends StatelessWidget {
  const DetailStatisticalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppConstants.darkBgColor
          : AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Phân tích Năng lực',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      // Lắng nghe cả 2 Box để lấy chính xác Tổng số từ và Tiến độ
      body: ValueListenableBuilder(
        valueListenable: Hive.box(DatabaseService.progressBoxName).listenable(),
        builder: (context, progressBox, _) {
          return ValueListenableBuilder(
            valueListenable: Hive.box<Word>(
              DatabaseService.wordBoxName,
            ).listenable(),
            builder: (context, wordBox, _) {
              int totalWords = wordBox.length;
              int masterCount = 0; // Từ đã thuộc (Step >= 4)
              int reviewCount = 0; // Cần ôn
              int mistakeCount = 0; // Tổng lỗi sai

              final now = DateTime.now().millisecondsSinceEpoch;

              for (var value in progressBox.values) {
                final map = value as Map;
                if ((map['s'] ?? 0) >= 4) masterCount++;
                if ((map['nr'] ?? 0) <= now && (map['nr'] ?? 0) > 0)
                  reviewCount++;
                mistakeCount += (map['wc'] ?? 0) as int;
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. GLOBAL PROGRESS (Tiến độ 1500 từ)
                    _buildGlobalProgressBento(
                      masterCount,
                      totalWords,
                      isDark,
                      context,
                    ),
                    const SizedBox(height: 24),

                    // 2. DỰ ĐOÁN CEFR (Phễu năng lực)
                    _buildCEFRPredictorBento(masterCount, isDark),
                    const SizedBox(height: 24),

                    // 3. QUICK STATS (3 Chỉ số nhanh)
                    _buildQuickStatsBento(
                      masterCount,
                      reviewCount,
                      mistakeCount,
                      isDark,
                    ),
                    const SizedBox(height: 32),

                    // 4. RADAR CHART (Top 5 Kỹ năng)
                    const Text(
                      'Thông thạo theo Chủ đề',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildRadarChartBento(wordBox, progressBox, isDark),
                    const SizedBox(height: 32),

                    // 5. LINE CHART (Tiến độ 7 ngày)
                    const Text(
                      'Hoạt động 7 ngày qua',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildLineChartBento(progressBox, isDark),
                    const SizedBox(height: 40), // Spacing for bottom nav
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  // =========================================================================
  // BENTO 1: GLOBAL PROGRESS (Tích hợp ProgressCard của bạn)
  // =========================================================================
  Widget _buildGlobalProgressBento(
    int learnedCount,
    int totalCount,
    bool isDark,
    BuildContext context,
  ) {
    final double progress = totalCount > 0 ? learnedCount / totalCount : 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppConstants.darkCardColor : AppConstants.accentColor,
        borderRadius: BorderRadius.circular(28),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: AppConstants.accentColor.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TIẾN ĐỘ TỔNG THỂ',
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              Icon(
                CupertinoIcons.flame_fill,
                color: isDark ? Colors.amber : Colors.white,
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '$learnedCount / $totalCount Từ',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Stack(
            children: [
              Container(
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOutQuart,
                height: 12,
                width:
                    (MediaQuery.of(context).size.width - 88) *
                    progress, // 88 = padding hai bên
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [
                    BoxShadow(color: Colors.white54, blurRadius: 8),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // BENTO 2: CEFR PREDICTOR (Phễu năng lực)
  // =========================================================================
  Widget _buildCEFRPredictorBento(int learned, bool isDark) {
    // Logic định mức CEFR
    final thresholds = [
      {
        'level': 'A1',
        'min': 0,
        'max': 200,
        'name': 'Người mới bắt đầu',
        'color': Colors.blueGrey,
      },
      {
        'level': 'A2',
        'min': 200,
        'max': 500,
        'name': 'Sơ cấp',
        'color': Colors.green,
      },
      {
        'level': 'B1',
        'min': 500,
        'max': 900,
        'name': 'Trung cấp',
        'color': Colors.orange,
      },
      {
        'level': 'B2',
        'min': 900,
        'max': 1300,
        'name': 'Trung cao cấp',
        'color': Colors.purple,
      },
      {
        'level': 'C1',
        'min': 1300,
        'max': 1562,
        'name': 'Cao cấp',
        'color': Colors.redAccent,
      },
    ];

    Map<String, dynamic> currentTier = thresholds.first;
    Map<String, dynamic>? nextTier;

    for (int i = 0; i < thresholds.length; i++) {
      if (learned >= (thresholds[i]['min'] as int) &&
          learned < (thresholds[i]['max'] as int)) {
        currentTier = thresholds[i];
        if (i + 1 < thresholds.length) nextTier = thresholds[i + 1];
        break;
      }
    }

    // Nếu vượt C1
    if (learned >= 1562) {
      currentTier = thresholds.last;
      nextTier = null;
    }

    int currentMin = currentTier['min'];
    int currentMax = currentTier['max'];
    double tierProgress = nextTier == null
        ? 1.0
        : (learned - currentMin) / (currentMax - currentMin);
    int wordsToNext = nextTier == null ? 0 : currentMax - learned;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppConstants.darkCardColor : AppConstants.cardColor,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 5),
                ),
              ],
      ),
      child: Row(
        children: [
          // Badge CEFR
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: (currentTier['color'] as Color).withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(color: currentTier['color'], width: 2),
            ),
            child: Center(
              child: Text(
                currentTier['level'],
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: currentTier['color'],
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),

          // Chi tiết tiến độ Level
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currentTier['name'],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                if (nextTier != null) ...[
                  Text(
                    'Còn $wordsToNext từ để lên ${nextTier['level']}',
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: tierProgress,
                      minHeight: 6,
                      backgroundColor: Colors.grey.withValues(alpha: 0.15),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        currentTier['color'],
                      ),
                    ),
                  ),
                ] else ...[
                  const Text(
                    'Bạn đã đạt cấp độ cao nhất!',
                    style: TextStyle(
                      color: Colors.amber,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // BENTO 3: QUICK STATS
  // =========================================================================
  Widget _buildQuickStatsBento(
    int learned,
    int review,
    int totalMistakes,
    bool isDark,
  ) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            title: 'Đã thuộc',
            value: learned.toString(),
            color: AppConstants.successColor,
            icon: CupertinoIcons.checkmark_seal_fill,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            title: 'Cần ôn',
            value: review.toString(),
            color: Colors.blueAccent,
            icon: CupertinoIcons.refresh_thick,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            title: 'Lỗi sai',
            value: totalMistakes.toString(),
            color: AppConstants.errorColor,
            icon: CupertinoIcons.xmark_circle_fill,
            isDark: isDark,
          ),
        ),
      ],
    );
  }

  // =========================================================================
  // BENTO 4: RADAR CHART (TOP 5 SKILLS)
  // =========================================================================
  Widget _buildRadarChartBento(
    Box<Word> wordBox,
    Box progressBox,
    bool isDark,
  ) {
    Map<String, int> totalPerTopic = {};
    Map<String, int> learnedPerTopic = {};

    for (var word in wordBox.values) {
      totalPerTopic[word.topic] = (totalPerTopic[word.topic] ?? 0) + 1;

      final p = progressBox.get(word.id);
      if (p != null && (p['s'] as int) >= 2) {
        learnedPerTopic[word.topic] = (learnedPerTopic[word.topic] ?? 0) + 1;
      }
    }

    var topics = totalPerTopic.keys.take(5).toList();
    if (topics.isEmpty) {
      return Container(
        height: 200,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isDark ? AppConstants.darkCardColor : AppConstants.cardColor,
          borderRadius: BorderRadius.circular(28),
        ),
        child: const Text(
          "Học thêm từ vựng để mở khóa biểu đồ",
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return Container(
      height: 320,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppConstants.darkCardColor : AppConstants.cardColor,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 5),
                ),
              ],
      ),
      child: RadarChart(
        RadarChartData(
          radarBackgroundColor: Colors.transparent,
          radarBorderData: BorderSide(
            color: isDark ? Colors.white24 : Colors.black12,
            width: 1,
          ),
          gridBorderData: BorderSide(
            color: isDark ? Colors.white12 : Colors.black12,
            width: 1,
          ),
          tickBorderData: const BorderSide(color: Colors.transparent),
          ticksTextStyle: const TextStyle(color: Colors.transparent),
          getTitle: (index, angle) {
            String title = topics[index].length > 10
                ? "${topics[index].substring(0, 10)}..."
                : topics[index];
            return RadarChartTitle(
              text: title,
              angle: angle,
              positionPercentageOffset:
                  0.1, // Chỉnh nhẹ để chữ không đè vào viền
            );
          },
          dataSets: [
            RadarDataSet(
              fillColor: AppConstants.accentColor.withValues(alpha: 0.3),
              borderColor: AppConstants.accentColor,
              entryRadius: 4,
              dataEntries: topics.map((t) {
                double total = (totalPerTopic[t] ?? 1).toDouble();
                double learned = (learnedPerTopic[t] ?? 0).toDouble();
                return RadarEntry(value: (learned / total) * 100);
              }).toList(),
            ),
          ],
        ),
        swapAnimationDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  // =========================================================================
  // BENTO 5: LINE CHART (7 DAY STREAK)
  // =========================================================================
  Widget _buildLineChartBento(Box progressBox, bool isDark) {
    final List<int> wordsPerDay = List.filled(7, 0);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    for (var value in progressBox.values) {
      final map = value as Map;
      final int lr = map['lr'] ?? 0;

      if (lr > 0) {
        final reviewDate = DateTime.fromMillisecondsSinceEpoch(lr);
        final normalizedReviewDate = DateTime(
          reviewDate.year,
          reviewDate.month,
          reviewDate.day,
        );
        final difference = today.difference(normalizedReviewDate).inDays;

        if (difference >= 0 && difference < 7) {
          wordsPerDay[6 - difference] += 1;
        }
      }
    }

    double maxY = wordsPerDay
        .reduce((curr, next) => curr > next ? curr : next)
        .toDouble();
    if (maxY == 0) maxY = 10;

    return Container(
      height: 280,
      padding: const EdgeInsets.only(top: 32, right: 24, left: 16, bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? AppConstants.darkCardColor : AppConstants.cardColor,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 5),
                ),
              ],
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) => FlLine(
              color: Colors.grey.withValues(alpha: 0.1),
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final date = today.subtract(
                    Duration(days: 6 - value.toInt()),
                  );
                  final weekday = [
                    'CN',
                    'T2',
                    'T3',
                    'T4',
                    'T5',
                    'T6',
                    'T7',
                  ][date.weekday % 7];
                  return Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: Text(
                      value.toInt() == 6 ? 'Nay' : weekday,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) => Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: 6,
          minY: 0,
          maxY: maxY + (maxY * 0.2),
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(
                7,
                (index) =>
                    FlSpot(index.toDouble(), wordsPerDay[index].toDouble()),
              ),
              isCurved: true,
              color: Colors.blueAccent,
              barWidth: 4,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) =>
                    FlDotCirclePainter(
                      radius: 4,
                      color: Colors.white,
                      strokeWidth: 2,
                      strokeColor: Colors.blueAccent,
                    ),
              ),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.blueAccent.withValues(alpha: 0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =========================================================================
// WIDGET HỖ TRỢ: STAT CARD
// =========================================================================
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;
  final bool isDark;

  const _StatCard({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.15 : 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}
