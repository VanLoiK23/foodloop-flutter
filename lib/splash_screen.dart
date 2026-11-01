import 'dart:async';

import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
    this.nextRoute = '/virtual-fridge', // Route của màn hình bắt đầu
    this.waitAfterAnimation = const Duration(seconds: 5),
  });

  final String nextRoute;
  final Duration waitAfterAnimation;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  // ----- Màu theo Figma -----
  static const Color _bg = Color(0xFFF7F4E8);
  static const Color _ellipseColor = Color(0xFF03202A);
  static const Color _logoColor = Color(0xFF3A4A1E);
  static const Color _textColor = Color(0xFF2B3A35);

  // ----- Kích thước / vị trí -----
  static const double _logoSize = 80;
  static const double _gap = 16; // khoảng cách logo - chữ
  static const double _jumpHeight = 90; // độ cao cú nhảy (px)

  // ----- Tốc độ: tăng số này để chậm hơn nữa -----
  static const Duration _animationDuration = Duration(milliseconds: 7000);

  static const TextStyle _brandStyle = TextStyle(
    color: _textColor,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.3,
  );

  late final AnimationController _controller;
  late final Animation<double> _ellipseIn;
  late final Animation<double> _ellipseOut;
  late final Animation<double> _logoY;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _slide;
  late final Animation<double> _textOpacity;

  Timer? _navTimer;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: _animationDuration);

    // 1. Ellipse hiện ra giữa màn hình (0% -> 12%)
    _ellipseIn = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.00, 0.12, curve: Curves.easeOut),
    );

    // 2. Ellipse mờ dần + thu nhỏ khi logo đã bật lên (30% -> 48%)
    _ellipseOut = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.30, 0.48, curve: Curves.easeInOut),
    );

    // Logo: nằm yên trong ellipse -> nhảy lên -> rớt xuống (nảy nhẹ) -> nghỉ
    // Giá trị âm = lên trên, 0 = đúng tâm màn hình
    _logoY = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 18), // 0% -> 18%
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: -_jumpHeight)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 27, // 18% -> 45%: nhảy lên
      ),
      TweenSequenceItem(
        tween: Tween(begin: -_jumpHeight, end: 0.0)
            .chain(CurveTween(curve: Curves.bounceOut)),
        weight: 20, // 45% -> 65%: rớt xuống
      ),
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 35), // nghỉ
    ]).animate(_controller);

    _logoScale = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.18, 0.45, curve: Curves.easeOut),
      ),
    );

    _logoOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.18, 0.30, curve: Curves.easeIn),
    );

    // 4. Logo trượt sang trái (72% -> 88%)
    _slide = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.72, 0.88, curve: Curves.easeInOutCubic),
    );

    // 5. Chữ hiện dần (82% -> 98%)
    _textOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.82, 0.98, curve: Curves.easeIn),
    );

    _controller.forward().whenComplete(() {
      // Animation xong -> đợi 5 giây -> sang màn hình bắt đầu
      _navTimer = Timer(widget.waitAfterAnimation, _goNext);
    });
  }

  void _goNext() {
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(widget.nextRoute);
  }

  @override
  void dispose() {
    _navTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  // Đo bề rộng thật của chữ "FoodLoop" để căn giữa chính xác
  double _measureTextWidth(BuildContext context) {
    final painter = TextPainter(
      text: TextSpan(
        text: 'FoodLoop',
        style: DefaultTextStyle.of(context).style.merge(_brandStyle),
      ),
      textDirection: TextDirection.ltr,
      textScaler: MediaQuery.textScalerOf(context),
      maxLines: 1,
    )..layout();
    return painter.width;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final ellipseWidth = screenWidth * 0.6;
    final ellipseHeight = ellipseWidth * 0.32;

    // Cụm [logo + chữ] cuối cùng nằm giữa màn hình:
    //   tâm logo lệch  -(textW + gap) / 2   so với tâm màn hình
    //   tâm chữ lệch   +(logo + gap) / 2    so với tâm màn hình
    final textWidth = _measureTextWidth(context);
    final logoFinalX = -(textWidth + _gap) / 2;
    final textFinalX = (_logoSize + _gap) / 2;

    return Scaffold(
      backgroundColor: _bg,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          // Ellipse: phóng to khi hiện, thu nhỏ khi biến mất
          final ellipseVisible = _ellipseIn.value * (1 - _ellipseOut.value);
          final ellipseScale = 0.6 + 0.4 * _ellipseIn.value;
          final ellipseShrink = 1 - 0.5 * _ellipseOut.value;

          final logoX = logoFinalX * _slide.value;
          // Chữ trượt nhẹ ra từ phía sau logo
          final textX = textFinalX - 30 * (1 - _textOpacity.value);

          return Stack(
            fit: StackFit.expand,
            children: [
              // ----- ELLIPSE (đúng tâm màn hình) -----
              if (ellipseVisible > 0)
                Center(
                  child: Opacity(
                    opacity: ellipseVisible.clamp(0.0, 1.0),
                    child: Transform.scale(
                      scale: ellipseScale * ellipseShrink,
                      child: ClipOval(
                        child: SizedBox(
                          width: ellipseWidth,
                          height: ellipseHeight,
                          child: const ColoredBox(color: _ellipseColor),
                        ),
                      ),
                    ),
                  ),
                ),

              // ----- CHỮ "FoodLoop" (luôn cùng hàng với logo) -----
              Center(
                child: Transform.translate(
                  offset: Offset(textX, 0),
                  child: Opacity(
                    opacity: _textOpacity.value,
                    child: const Text(
                      'FoodLoop',
                      softWrap: false,
                      maxLines: 1,
                      style: _brandStyle,
                    ),
                  ),
                ),
              ),

              // ----- LOGO -----
              Center(
                child: Transform.translate(
                  offset: Offset(logoX, _logoY.value),
                  child: Opacity(
                    opacity: _logoOpacity.value,
                    child: Transform.scale(
                      scale: _logoScale.value,
                      child: const _FoodLoopLogo(
                        size: _logoSize,
                        background: _logoColor,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Logo FoodLoop: nền xanh rêu bo góc + chiếc lá viền trắng.
/// Nếu có file ảnh logo, thay widget này bằng:
///   Image.asset('assets/logo.png', width: size, height: size)
class _FoodLoopLogo extends StatelessWidget {
  const _FoodLoopLogo({required this.size, required this.background});

  final double size;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      child: CustomPaint(painter: _LeafPainter()),
    );
  }
}

class _LeafPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Vẽ trên hệ tọa độ 80x80 rồi scale theo kích thước thật
    canvas.save();
    canvas.scale(size.width / 80, size.height / 80);

    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final leaf = Path()
      ..moveTo(40, 18)
      ..cubicTo(44, 24, 46, 28, 46, 32)
      ..cubicTo(49, 29, 53, 28, 57, 28)
      ..cubicTo(57, 38, 52, 48, 40, 52)
      ..cubicTo(28, 48, 23, 38, 23, 28)
      ..cubicTo(27, 28, 31, 29, 34, 32)
      ..cubicTo(34, 28, 36, 24, 40, 18)
      ..close();

    canvas.drawPath(leaf, paint);

    // Cuống lá
    canvas.drawLine(const Offset(40, 34), const Offset(40, 64), paint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}