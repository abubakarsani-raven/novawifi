import 'package:flutter/material.dart';

class AnimatedCheckmark extends StatefulWidget {
  final Color color;
  final double size;
  final Duration duration;

  const AnimatedCheckmark({
    super.key,
    this.color = const Color(0xFF22C55E),
    this.size = 100,
    this.duration = const Duration(milliseconds: 650),
  });

  @override
  State<AnimatedCheckmark> createState() => _AnimatedCheckmarkState();
}

class _AnimatedCheckmarkState extends State<AnimatedCheckmark>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _progress;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _progress = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _progress,
      builder: (_, __) => CustomPaint(
        size: Size(widget.size, widget.size),
        painter: _CheckmarkPainter(_progress.value, widget.color),
      ),
    );
  }
}

class _CheckmarkPainter extends CustomPainter {
  final double progress;
  final Color color;

  _CheckmarkPainter(this.progress, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;

    // Filled background circle scales in with progress
    final bgPaint = Paint()
      ..color = color.withValues(alpha: 0.13 * progress)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, cy), r * progress, bgPaint);

    // Stroke ring
    final ringPaint = Paint()
      ..color = color.withValues(alpha: 0.35 * progress)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.045;
    canvas.drawCircle(Offset(cx, cy), r - size.width * 0.025, ringPaint);

    if (progress <= 0.05) return;

    // Checkmark — draw partial stroke via PathMetrics
    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = size.width * 0.085;

    final path = Path()
      ..moveTo(size.width * 0.21, size.height * 0.52)
      ..lineTo(size.width * 0.42, size.height * 0.71)
      ..lineTo(size.width * 0.79, size.height * 0.31);

    final metric = path.computeMetrics().first;
    final drawn = metric.extractPath(0, metric.length * progress);
    canvas.drawPath(drawn, strokePaint);
  }

  @override
  bool shouldRepaint(_CheckmarkPainter old) => old.progress != progress;
}
