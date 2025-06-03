import 'package:flutter/material.dart';
import 'dart:math' as math;

class AnimatedFitnessBackground extends StatefulWidget {
  final Widget child;
  
  const AnimatedFitnessBackground({super.key, required this.child});

  @override
  State<AnimatedFitnessBackground> createState() => _AnimatedFitnessBackgroundState();
}

class _AnimatedFitnessBackgroundState extends State<AnimatedFitnessBackground>
    with TickerProviderStateMixin {
  late AnimationController _controller1;
  late AnimationController _controller2;

  @override
  void initState() {
    super.initState();
    _controller1 = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
    
    _controller2 = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background gradient
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF667EEA),
                Color(0xFF764BA2),
                Color(0xFF9B59B6),
              ],
            ),
          ),
        ),
        
        // Animated circles
        AnimatedBuilder(
          animation: _controller1,
          builder: (context, child) {
            return Positioned(
              top: -100 + math.sin(_controller1.value * 2 * math.pi) * 50,
              right: -50 + math.cos(_controller1.value * 2 * math.pi) * 30,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
            );
          },
        ),
        
        AnimatedBuilder(
          animation: _controller2,
          builder: (context, child) {
            return Positioned(
              bottom: -80 + math.cos(_controller2.value * 2 * math.pi) * 40,
              left: -30 + math.sin(_controller2.value * 2 * math.pi) * 20,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
            );
          },
        ),
        
        // Content
        widget.child,
      ],
    );
  }
}