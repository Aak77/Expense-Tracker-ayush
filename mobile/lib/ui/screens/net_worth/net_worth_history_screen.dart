import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_format.dart';
import '../../widgets/common/glass_card.dart';

class NetWorthHistoryScreen extends StatelessWidget {
  const NetWorthHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface.withOpacity(0.8),
        elevation: 0,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ColorFilter.mode(Colors.transparent, BlendMode.src),
          ),
        ),
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
              ),
              child: const Icon(Icons.person, color: AppColors.onSurface, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              'FinTrack',
              style: GoogleFonts.inter(
                color: AppColors.primary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: AppColors.primary),
            onPressed: () {},
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: Colors.white.withOpacity(0.1),
            height: 1.0,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeadline(),
            const SizedBox(height: 32),
            _buildChartSection(),
            const SizedBox(height: 32),
            _buildSummaryTable(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeadline() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'TOTAL NET WORTH',
          style: GoogleFonts.inter(
            color: AppColors.onSurfaceVariant,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              AppFormatters.formatINR(12450000),
              style: GoogleFonts.inter(
                color: AppColors.secondary,
                fontSize: 40,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.8,
              ),
            ),
            const SizedBox(width: 12),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.greenAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.trending_up, color: Colors.greenAccent, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '14.2%',
                      style: GoogleFonts.inter(
                        color: Colors.greenAccent,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChartSection() {
    return GlassCard(
      height: 300,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '12-Month Growth',
                style: GoogleFonts.inter(
                  color: AppColors.onSurface,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.secondary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Net Worth',
                    style: GoogleFonts.inter(
                      color: AppColors.outline,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Stack(
              children: [
                // Horizontal grid lines
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                    5,
                    (index) => Container(
                      height: 1,
                      color: Colors.white.withOpacity(0.05),
                    ),
                  ),
                ),
                // Mock Chart Painter
                Positioned.fill(
                  child: CustomPaint(
                    painter: _MockChartPainter(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMonthLabel('JAN'),
              _buildMonthLabel('MAR'),
              _buildMonthLabel('MAY'),
              _buildMonthLabel('JUL'),
              _buildMonthLabel('SEP'),
              _buildMonthLabel('NOV'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMonthLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        color: AppColors.outlineVariant,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildSummaryTable() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Monthly breakdown',
              style: GoogleFonts.inter(
                color: AppColors.onSurface,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.ios_share, size: 16, color: AppColors.primary),
              label: Text(
                'Export',
                style: GoogleFonts.inter(
                  color: AppColors.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GlassCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _buildTableHeader(),
              _buildTableRow('Nov 2023', 14500000, 2050000, 12450000),
              _buildTableRow('Oct 2023', 13800000, 2100000, 11700000),
              _buildTableRow('Sep 2023', 13000000, 2200000, 10800000),
              _buildTableRow('Aug 2023', 12500000, 2450000, 10050000),
              _buildTableRow('Jul 2023', 11800000, 2500000, 9300000, isLast: true),
            ],
          ),
        ),
        const SizedBox(height: 24),
        TextButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.keyboard_arrow_down, size: 16, color: AppColors.outlineVariant),
          label: Text(
            'Show older records',
            style: GoogleFonts.inter(
              color: AppColors.outlineVariant,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.05)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              'MONTH',
              style: GoogleFonts.inter(
                color: AppColors.onSurfaceVariant,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.0,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'ASSETS',
              textAlign: TextAlign.right,
              style: GoogleFonts.inter(
                color: AppColors.onSurfaceVariant,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.0,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'LIABILITIES',
              textAlign: TextAlign.right,
              style: GoogleFonts.inter(
                color: AppColors.onSurfaceVariant,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.0,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'NET WORTH',
              textAlign: TextAlign.right,
              style: GoogleFonts.inter(
                color: AppColors.onSurfaceVariant,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableRow(String month, double assets, double liabilities, double netWorth, {bool isLast = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(color: Colors.white.withOpacity(0.05)),
              ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              month,
              style: GoogleFonts.inter(
                color: AppColors.onSurface,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              AppFormatters.formatINR(assets),
              textAlign: TextAlign.right,
              style: GoogleFonts.inter(
                color: AppColors.onSurface,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              AppFormatters.formatINR(liabilities),
              textAlign: TextAlign.right,
              style: GoogleFonts.inter(
                color: AppColors.error,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              AppFormatters.formatINR(netWorth),
              textAlign: TextAlign.right,
              style: GoogleFonts.inter(
                color: AppColors.secondary,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MockChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.secondary
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    
    // Mock data points mirroring the SVG path
    final points = [
      Offset(0, size.height * 0.9),
      Offset(size.width * 0.05, size.height * 0.85),
      Offset(size.width * 0.1, size.height * 0.8),
      Offset(size.width * 0.2, size.height * 0.75),
      Offset(size.width * 0.3, size.height * 0.78),
      Offset(size.width * 0.4, size.height * 0.65),
      Offset(size.width * 0.5, size.height * 0.68),
      Offset(size.width * 0.6, size.height * 0.55),
      Offset(size.width * 0.7, size.height * 0.45),
      Offset(size.width * 0.8, size.height * 0.35),
      Offset(size.width * 0.9, size.height * 0.3),
      Offset(size.width, size.height * 0.2),
    ];

    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    // Draw area gradient
    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.secondary.withOpacity(0.3),
          AppColors.secondary.withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);

    // Draw last point indicator
    final dotPaint = Paint()
      ..color = AppColors.secondary
      ..style = PaintingStyle.fill;
    canvas.drawCircle(points.last, 4, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
