import 'package:flutter/material.dart';
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
      backgroundColor: isDark ? AppConstants.darkBgColor : AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('Phân tích Năng lực', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box(DatabaseService.progressBoxName).listenable(),
        builder: (context, box, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. CỤM BENTO 3 CHỈ SỐ NHANH
                _buildQuickStatsBento(box, isDark),
                const SizedBox(height: 32),

                // 2. BIỂU ĐỒ RADAR (SKILL SPIDER CHART)
                const Text('Độ thông thạo theo Chủ đề', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _buildRadarChartBento(isDark),
                const SizedBox(height: 32),
                // 3. BIỂU ĐỒ ĐƯỜNG (LINE CHART) THEO DÕI TIẾN ĐỘ HỌC TẬP
                const Text('Tiến độ học tập trong 7 ngày qua', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _buildLineChartBento(isDark),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuickStatsBento(Box box, bool isDark) {
    int learned = 0, review = 0, totalMistakes = 0;
    final now = DateTime.now().millisecondsSinceEpoch;

    for (var value in box.values) {
      final map = value as Map;
      if ((map['s'] ?? 0) >= 4) learned++;
      if ((map['nr'] ?? 0) <= now && (map['nr'] ?? 0) > 0) review++;
      totalMistakes += (map['wc'] ?? 0) as int;
    }

    return Row(
      children: [
        Expanded(child: _StatCard(title: 'Đã thuộc', value: learned.toString(), color: Colors.green, isDark: isDark)),
        const SizedBox(width: 12),
        Expanded(child: _StatCard(title: 'Cần ôn', value: review.toString(), color: Colors.blue, isDark: isDark)),
        const SizedBox(width: 12),
        Expanded(child: _StatCard(title: 'Lỗi sai', value: totalMistakes.toString(), color: Colors.red, isDark: isDark)),
      ],
    );
  }
  Widget _buildLineChartBento(bool isDark) {
    final progressBox = Hive.box(DatabaseService.progressBoxName);
    
    // 1. Tạo mảng chứa số lượng từ học trong 7 ngày qua
    final List<int> wordsPerDay = List.filled(7, 0);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // 2. Quét dữ liệu
    for (var value in progressBox.values) {
      final map = value as Map;
      final int lr = map['lr'] ?? 0; // Last review
      
      if (lr > 0) {
        final reviewDate = DateTime.fromMillisecondsSinceEpoch(lr);
        final normalizedReviewDate = DateTime(reviewDate.year, reviewDate.month, reviewDate.day);
        
        // Tính xem ngày học cách đây bao nhiêu ngày
        final difference = today.difference(normalizedReviewDate).inDays;
        
        if (difference >= 0 && difference < 7) {
          // difference = 0 (hôm nay), difference = 6 (6 ngày trước)
          // Đảo ngược index để vẽ từ trái (quá khứ) sang phải (hiện tại)
          wordsPerDay[6 - difference] += 1;
        }
      }
    }

    // 3. Tìm giá trị lớn nhất để căn chỉnh trục Y
    double maxY = wordsPerDay.reduce((curr, next) => curr > next ? curr : next).toDouble();
    if (maxY == 0) maxY = 10; // Mặc định nếu chưa học gì

    return Container(
      height: 300,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppConstants.darkCardColor : AppConstants.cardColor,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
        boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Từ vựng đã học (7 ngày qua)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 24),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.withValues(alpha: 0.1), strokeWidth: 1)),
                titlesData: FlTitlesData(
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        // Tính toán nhãn ngày (VD: T2, T3, T4)
                        final date = today.subtract(Duration(days: 6 - value.toInt()));
                        final weekday = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'][date.weekday % 7];
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(value.toInt() == 6 ? 'H.nay' : weekday, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true, reservedSize: 30, getTitlesWidget: (value, meta) => Text(value.toInt().toString(), style: const TextStyle(fontSize: 12, color: Colors.grey))),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0, maxX: 6, minY: 0, maxY: maxY + (maxY * 0.2), // Tăng đỉnh Y lên 20% cho đẹp
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(7, (index) => FlSpot(index.toDouble(), wordsPerDay[index].toDouble())),
                    isCurved: true,
                    color: AppConstants.accentColor,
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppConstants.accentColor.withValues(alpha: 0.2), // Màu mờ đổ bóng dưới đường
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
  Widget _buildRadarChartBento(bool isDark) {
    final wordBox = Hive.box<Word>(DatabaseService.wordBoxName);
    final progressBox = Hive.box(DatabaseService.progressBoxName);

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
    if (topics.isEmpty) return const Center(child: Text("Học thêm để mở khóa biểu đồ"));

    return Container(
      height: 350,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppConstants.darkCardColor : AppConstants.cardColor,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
        boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 5))],
      ),
      child: RadarChart(
        RadarChartData(
          radarBackgroundColor: Colors.transparent,
          radarBorderData: const BorderSide(color: Colors.grey, width: 0.5),
          gridBorderData: const BorderSide(color: Colors.grey, width: 0.5),
          tickBorderData: const BorderSide(color: Colors.transparent),
          ticksTextStyle: const TextStyle(color: Colors.transparent),
          // ĐÃ XÓA titlePositionMultiplier Ở ĐÂY
          getTitle: (index, angle) {
            return RadarChartTitle(
              text: topics[index].length > 10 ? "${topics[index].substring(0, 10)}..." : topics[index],
              angle: angle,
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
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final bool isDark;

  const _StatCard({required this.title, required this.value, required this.color, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.15 : 0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color.withValues(alpha: 0.8))),
        ],
      ),
    );
  }
  
}