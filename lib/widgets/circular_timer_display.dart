import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CircularTimerDisplay extends StatefulWidget {
  final String timeText;
  final double progress;
  final bool isRunning;
  final Color primaryColor;
  final Color backgroundColor;
  final double size;

  const CircularTimerDisplay({
    Key? key,
    required this.timeText,
    required this.progress,
    required this.isRunning,
    required this.primaryColor,
    required this.backgroundColor,
    this.size = 280,
  }) : super(key: key);

  @override
  State<CircularTimerDisplay> createState() => _CircularTimerDisplayState();
}

class _CircularTimerDisplayState extends State<CircularTimerDisplay>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Animated glow effect when running
          if (widget.isRunning)
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Container(
                  width: widget.size + (20 * _pulseController.value),
                  height: widget.size + (20 * _pulseController.value),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: widget.primaryColor.withOpacity(0.3 * (1 - _pulseController.value)),
                        blurRadius: 40 + (20 * _pulseController.value),
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                );
              },
            ),
          
          // Background circle
          Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.backgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
          ),
          
          // Progress ring
          CustomPaint(
            size: Size(widget.size, widget.size),
            painter: CircularProgressPainter(
              progress: widget.progress,
              color: widget.primaryColor,
              backgroundColor: widget.backgroundColor,
              strokeWidth: 8,
            ),
          ),
          
          // Time text
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.timeText,
                style: GoogleFonts.outfit(
                  fontSize: 56,
                  fontWeight: FontWeight.w300,
                  letterSpacing: -2,
                  color: widget.primaryColor,
                  height: 1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;
  final double strokeWidth;

  CircularProgressPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
    this.strokeWidth = 8,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - (strokeWidth / 2);
    
    // Draw background ring with subtle color
    final backgroundPaint = Paint()
      ..color = color.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    
    canvas.drawCircle(center, radius, backgroundPaint);
    
    // Draw progress arc
    if (progress > 0) {
      final progressPaint = Paint()
        ..shader = LinearGradient(
          colors: [
            color,
            color.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(Rect.fromCircle(center: center, radius: radius))
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
      
      const startAngle = -math.pi / 2; // Start from top
      final sweepAngle = 2 * math.pi * progress;
      
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}
