import 'package:flutter/material.dart';

/// Animates a number counting up from its previous value to [value]
/// whenever it changes, formatted via [formatter]. Uses Flutter's built-in
/// `TweenAnimationBuilder` — no extra package needed.
class AnimatedCounter extends StatelessWidget {
  const AnimatedCounter({
    super.key,
    required this.value,
    required this.formatter,
    this.style,
    this.duration = const Duration(milliseconds: 800),
  });

  final double value;
  final String Function(double value) formatter;
  final TextStyle? style;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, animatedValue, child) => Text(formatter(animatedValue), style: style),
    );
  }
}
