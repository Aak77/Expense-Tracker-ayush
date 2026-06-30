import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_format.dart';
import '../../widgets/common/glass_card.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface.withOpacity(0.8),
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white10),
                image: const DecorationImage(
                  image: NetworkImage(
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuACj_yIUB3qNYITMe9kyCGTU-ShWCHrucBWpRbIb0sQvM7XEx-ifC58-Qn2zw8H6VkEovsJ8ZZRRjTht_S8buqifA01es_JP9y0cdmQYFbEXwVJrwZ4FfvUfKMJtqBHtNEO3XlsgHG3hdUSlkKrdTY_Xho8qcz2zFLkIfbekKYZE_75pSYMT5OetNtjfRj6Jf7QGZ5UZCBleupkGeqAtbNBtg6GMn7hXiukKvMmdYWx4wDL1SrFWtddN47Pk2gnXedKGhJy3hXecg-M',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'FinTrack',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: AppColors.primary),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 24, bottom: 100),
        child: Column(
          children: [
            _buildMonthSelector(),
            const SizedBox(height: 24),
            _buildBreakdownChart(),
            const SizedBox(height: 16),
            _buildSpendingTrendChart(),
            const SizedBox(height: 16),
            _buildCategoryComparison(),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthSelector() {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, color: AppColors.outline),
            onPressed: () {},
          ),
          Column(
            children: [
              Text(
                'June 2026',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
              Text(
                'ANALYTICS OVERVIEW',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.outline,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, color: AppColors.outline),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownChart() {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      height: 400,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Breakdown',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
                  ),
                  Text(
                    'Monthly Distribution',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.outline,
                    ),
                  ),
                ],
              ),
              const Icon(Icons.pie_chart, color: AppColors.secondary),
            ],
          ),
          Expanded(
            child: Stack(
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 0,
                    centerSpaceRadius: 70,
                    startDegreeOffset: -90,
                    sections: [
                      PieChartSectionData(
                        color: const Color(0xFF4F8EF7),
                        value: 40,
                        title: '',
                        radius: 15,
                      ),
                      PieChartSectionData(
                        color: const Color(0xFF9333ea),
                        value: 25,
                        title: '',
                        radius: 15,
                      ),
                      PieChartSectionData(
                        color: const Color(0xFF2dd4bf),
                        value: 20,
                        title: '',
                        radius: 15,
                      ),
                      PieChartSectionData(
                        color: const Color(0xFFfb923c),
                        value: 15,
                        title: '',
                        radius: 15,
                      ),
                    ],
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '₹42k',
                        style: GoogleFonts.inter(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppColors.onSurface,
                        ),
                      ),
                      Text(
                        'TOTAL',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.outline,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildLegendItem(const Color(0xFF4F8EF7), 'Housing'),
              _buildLegendItem(const Color(0xFF9333ea), 'Dining'),
              _buildLegendItem(const Color(0xFF2dd4bf), 'Transit'),
              _buildLegendItem(const Color(0xFFfb923c), 'Lifestyle'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildSpendingTrendChart() {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      height: 400,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Spending Trend',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
                  ),
                  Text(
                    'Last 6 Months Analysis',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.outline,
                    ),
                  ),
                ],
              ),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Trends',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onPrimaryContainer,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      child: Text(
                        'Net',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.outline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 40,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.white.withOpacity(0.05),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        const months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN'];
                        if (value.toInt() >= 0 && value.toInt() < months.length) {
                          final isLast = value.toInt() == 5;
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text(
                              months[value.toInt()],
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: isLast ? FontWeight.bold : FontWeight.w600,
                                color: isLast ? AppColors.primary : AppColors.outline,
                              ),
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: 5,
                minY: 0,
                maxY: 160,
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 140),
                      FlSpot(1, 145),
                      FlSpot(2, 130),
                      FlSpot(3, 110),
                      FlSpot(4, 70),
                      FlSpot(5, 75),
                    ],
                    isCurved: true,
                    color: AppColors.primary,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      checkToShowDot: (spot, barData) => spot.x == 4, // highlight May dot
                      getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                        radius: 4,
                        color: AppColors.primary,
                        strokeWidth: 0,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withOpacity(0.3),
                          AppColors.primary.withOpacity(0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
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

  Widget _buildCategoryComparison() {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Category Comparison',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
                  ),
                  Text(
                    'Budget vs. Actual Spending',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.outline,
                    ),
                  ),
                ],
              ),
              const Icon(Icons.query_stats, color: AppColors.outline),
            ],
          ),
          const SizedBox(height: 24),
          _buildCategoryProgress('Housing & Utilities', 18200, 20000, const [AppColors.primary, AppColors.secondary]),
          const SizedBox(height: 16),
          _buildCategoryProgress('Food & Dining', 12450, 10000, const [Colors.purple, Colors.pink], isOverBudget: true),
          const SizedBox(height: 16),
          _buildCategoryProgress('Transportation', 4800, 6000, const [Colors.teal, Colors.tealAccent]),
          const SizedBox(height: 16),
          _buildCategoryProgress('Shopping', 6550, 8000, const [Colors.orange, Colors.yellow]),
        ],
      ),
    );
  }

  Widget _buildCategoryProgress(String name, double spent, double budget, List<Color> colors, {bool isOverBudget = false}) {
    double percentage = spent / budget;
    if (percentage > 1.0) percentage = 1.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              name,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.onSurface,
              ),
            ),
            RichText(
              text: TextSpan(
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                children: [
                  TextSpan(
                    text: AppFormatters.formatINR(spent),
                    style: TextStyle(color: isOverBudget ? AppColors.error : AppColors.onSurface),
                  ),
                  TextSpan(
                    text: ' / ${AppFormatters.formatINR(budget)}',
                    style: const TextStyle(color: AppColors.outline),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 12,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: percentage,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: colors),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
