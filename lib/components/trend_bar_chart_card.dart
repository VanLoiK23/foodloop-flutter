import 'package:flutter/material.dart';
import '../theme/app_tokens.dart';

class BarChartItem {
  final String label;
  final double value;
  final String displayValue;

  const BarChartItem({
    required this.label,
    required this.value,
    required this.displayValue,
  });
}

/// Component TrendBarChartCard hiển thị biểu đồ cột rác thải ngăn chặn theo ngày
class TrendBarChartCard extends StatelessWidget {
  final String title;
  final String unit;
  final String legendLabel;
  final List<BarChartItem> items;
  final double maxY;
  final List<double> yLevels;

  const TrendBarChartCard({
    super.key,
    required this.title,
    required this.unit,
    required this.legendLabel,
    required this.items,
    this.maxY = 4.0,
    this.yLevels = const [4.0, 2.0, 0.0],
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTokens.space16),
      decoration: BoxDecoration(
        color: AppTokens.surface,
        borderRadius: AppTokens.radiusLg,
        border: Border.all(
          color: AppTokens.border,
          width: 1.0,
        ),
        boxShadow: AppTokens.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tiêu đề biểu đồ
          Text(
            title,
            style: AppTokens.headingMedium.copyWith(
              fontSize: 16.0,
              color: AppTokens.title,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            unit,
            style: AppTokens.caption.copyWith(
              color: AppTokens.textSecondary,
              fontSize: 12.0,
            ),
          ),
          const SizedBox(height: AppTokens.space16),

          // Khu vực vẽ biểu đồ cột
          SizedBox(
            height: 160,
            child: CustomPaint(
              size: const Size(double.infinity, 160),
              painter: _BarChartPainter(
                items: items,
                maxY: maxY,
                yLevels: yLevels,
              ),
            ),
          ),

          const SizedBox(height: AppTokens.space12),

          // Chú thích (Legend)
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppTokens.brand,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppTokens.space8),
              Text(
                legendLabel,
                style: AppTokens.caption.copyWith(
                  color: AppTokens.title,
                  fontSize: 12.0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BarChartPainter extends CustomPainter {
  final List<BarChartItem> items;
  final double maxY;
  final List<double> yLevels;

  _BarChartPainter({
    required this.items,
    required this.maxY,
    required this.yLevels,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const leftMargin = 32.0;
    const bottomMargin = 26.0;
    const topMargin = 22.0;
    final chartWidth = size.width - leftMargin;
    final chartHeight = size.height - bottomMargin - topMargin;

    final gridPaint = Paint()
      ..color = const Color(0xFFF1F5F9)
      ..strokeWidth = 1.0;

    final barPaint = Paint()
      ..color = AppTokens.brand
      ..style = PaintingStyle.fill;

    // 1. Vẽ các đường lưới ngang và nhãn trục Y
    for (final level in yLevels) {
      final yRatio = level / maxY;
      final yPos = topMargin + chartHeight * (1.0 - yRatio);

      // Đường lưới
      canvas.drawLine(
        Offset(leftMargin, yPos),
        Offset(size.width, yPos),
        gridPaint,
      );

      // Nhãn trục Y bên trái
      final tp = TextPainter(
        text: TextSpan(
          text: level.toInt().toString(),
          style: const TextStyle(
            color: AppTokens.textSecondary,
            fontSize: 11.0,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(leftMargin - tp.width - 8, yPos - tp.height / 2));
    }

    if (items.isEmpty) return;

    // 2. Vẽ từng cột dữ liệu
    final slotWidth = chartWidth / items.length;
    final barWidth = (slotWidth * 0.52).clamp(16.0, 24.0);

    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      final centerX = leftMargin + slotWidth * i + slotWidth / 2;
      final barHeight = (item.value / maxY).clamp(0.0, 1.0) * chartHeight;
      final topY = topMargin + chartHeight - barHeight;
      final bottomY = topMargin + chartHeight;

      // Cột bo góc trên
      final rrect = RRect.fromRectAndCorners(
        Rect.fromLTRB(
          centerX - barWidth / 2,
          topY,
          centerX + barWidth / 2,
          bottomY,
        ),
        topLeft: const Radius.circular(4.0),
        topRight: const Radius.circular(4.0),
      );
      canvas.drawRRect(rrect, barPaint);

      // Giá trị số trên đầu mỗi cột
      final valTp = TextPainter(
        text: TextSpan(
          text: item.displayValue,
          style: const TextStyle(
            color: AppTokens.title,
            fontSize: 11.0,
            fontWeight: FontWeight.w500,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      valTp.paint(canvas, Offset(centerX - valTp.width / 2, topY - 16));

      // Nhãn thứ trục X (T2, T3, T4, T5, T6, T7, CN)
      final xTp = TextPainter(
        text: TextSpan(
          text: item.label,
          style: const TextStyle(
            color: AppTokens.textSecondary,
            fontSize: 11.5,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      xTp.paint(
        canvas,
        Offset(centerX - xTp.width / 2, size.height - bottomMargin + 8),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BarChartPainter oldDelegate) {
    return oldDelegate.items != items || oldDelegate.maxY != maxY;
  }
}

