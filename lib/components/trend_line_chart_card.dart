import 'package:flutter/material.dart';
import '../theme/app_tokens.dart';

class LineChartPoint {
  final String label;
  final double value;

  const LineChartPoint({
    required this.label,
    required this.value,
  });
}

/// Component TrendLineChartCard hiển thị biểu đồ đường xu hướng tiết kiệm
class TrendLineChartCard extends StatelessWidget {
  final String title;
  final String unit;
  final String legendLabel;
  final List<LineChartPoint> points;
  final double maxY;
  final List<double> yLevels;

  const TrendLineChartCard({
    super.key,
    required this.title,
    required this.unit,
    required this.legendLabel,
    required this.points,
    this.maxY = 200.0,
    this.yLevels = const [200.0, 100.0, 0.0],
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

          // Khu vực vẽ biểu đồ đường
          SizedBox(
            height: 150,
            child: CustomPaint(
              size: const Size(double.infinity, 150),
              painter: _LineChartPainter(
                points: points,
                maxY: maxY,
                yLevels: yLevels,
              ),
            ),
          ),

          const SizedBox(height: AppTokens.space12),

          // Chú thích (Legend) phía dưới
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

class _LineChartPainter extends CustomPainter {
  final List<LineChartPoint> points;
  final double maxY;
  final List<double> yLevels;

  _LineChartPainter({
    required this.points,
    required this.maxY,
    required this.yLevels,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const leftMargin = 38.0;
    const bottomMargin = 26.0;
    const topMargin = 20.0;
    final chartWidth = size.width - leftMargin;
    final chartHeight = size.height - bottomMargin - topMargin;

    final gridPaint = Paint()
      ..color = const Color(0xFFF1F5F9)
      ..strokeWidth = 1.0;

    final linePaint = Paint()
      ..color = AppTokens.brand
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final dotPaint = Paint()
      ..color = AppTokens.brand
      ..style = PaintingStyle.fill;

    // 1. Vẽ các đường lưới ngang và nhãn trục Y
    for (final level in yLevels) {
      final yRatio = level / maxY;
      final yPos = topMargin + chartHeight * (1.0 - yRatio);

      // Đường lưới ngang
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

    if (points.isEmpty) return;

    // 2. Tính toán tọa độ các điểm
    final dx = chartWidth / (points.length);
    final offsets = <Offset>[];

    for (int i = 0; i < points.length; i++) {
      final p = points[i];
      final x = leftMargin + dx * i + dx * 0.45;
      final yRatio = (p.value / maxY).clamp(0.0, 1.0);
      final y = topMargin + chartHeight * (1.0 - yRatio);
      offsets.add(Offset(x, y));
    }

    // 3. Nối đường vẽ giữa các điểm
    final path = Path();
    path.moveTo(offsets[0].dx, offsets[0].dy);
    for (int i = 1; i < offsets.length; i++) {
      path.lineTo(offsets[i].dx, offsets[i].dy);
    }
    // Đường kéo dài nhẹ ra mép phải như Figma
    if (offsets.isNotEmpty) {
      path.lineTo(size.width, offsets.last.dy + 15);
    }
    canvas.drawPath(path, linePaint);

    // 4. Vẽ các điểm chấm và nhãn giá trị + nhãn X
    for (int i = 0; i < offsets.length; i++) {
      final offset = offsets[i];
      final pt = points[i];

      // Điểm tròn
      canvas.drawCircle(offset, 3.5, dotPaint);

      // Giá trị số phía trên điểm tròn
      final valTp = TextPainter(
        text: TextSpan(
          text: pt.value.toInt().toString(),
          style: const TextStyle(
            color: AppTokens.title,
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      valTp.paint(canvas, Offset(offset.dx - valTp.width / 2, offset.dy - 16));

      // Nhãn trục X phía dưới (Tuần 1, Tuần 2, Tuần 3)
      final xTp = TextPainter(
        text: TextSpan(
          text: pt.label,
          style: const TextStyle(
            color: AppTokens.textSecondary,
            fontSize: 11.5,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      xTp.paint(
        canvas,
        Offset(offset.dx - xTp.width / 2, size.height - bottomMargin + 8),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) {
    return oldDelegate.points != points || oldDelegate.maxY != maxY;
  }
}

