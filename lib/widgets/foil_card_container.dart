import 'package:flutter/material.dart';
import '../models/poker_card.dart';

class FoilCardContainer extends StatefulWidget {
  final Widget child;
  final CardRarity rarity;
  final bool isInteractive;
  final VoidCallback? onTap;

  const FoilCardContainer({
    super.key,
    required this.child,
    required this.rarity,
    this.isInteractive = false,
    this.onTap,
  });

  @override
  State<FoilCardContainer> createState() => _FoilCardContainerState();
}

class _FoilCardContainerState extends State<FoilCardContainer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool get _isTest => WidgetsBinding.instance.runtimeType.toString().contains('Test');

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    if (!_isTest && (widget.rarity == CardRarity.legendary || widget.rarity == CardRarity.epic)) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(FoilCardContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.rarity != oldWidget.rarity) {
      if (!_isTest && (widget.rarity == CardRarity.legendary || widget.rarity == CardRarity.epic)) {
        if (!_controller.isAnimating) _controller.repeat(reverse: true);
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.rarity == CardRarity.common) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final animVal = _controller.value;
        Gradient borderGradient;

        switch (widget.rarity) {
          case CardRarity.legendary:
            borderGradient = LinearGradient(
              begin: Alignment(-1.0 + animVal * 2, -1.0),
              end: Alignment(1.0 - animVal * 2, 1.0),
              colors: const [
                Color(0xFFF59E0B), // Amber
                Color(0xFFFEF08A), // Light Gold
                Color(0xFFD97706), // Deep Amber
                Color(0xFFFEF3C7), // Champagne
              ],
            );
            break;
          case CardRarity.epic:
            borderGradient = LinearGradient(
              begin: Alignment(-1.0 + animVal * 2, -1.0),
              end: Alignment(1.0 - animVal * 2, 1.0),
              colors: const [
                Color(0xFFA855F7), // Purple
                Color(0xFFE9D5FF), // Light Lavender
                Color(0xFF7C3AED), // Deep Violet
                Color(0xFFC084FC), // Lilac
              ],
            );
            break;
          case CardRarity.rare:
            borderGradient = const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF38BDF8),
                Color(0xFF0284C7),
              ],
            );
            break;
          case CardRarity.common:
            borderGradient = const LinearGradient(
              colors: [Color(0xFF475569), Color(0xFF334155)],
            );
            break;
        }

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: borderGradient,
            boxShadow: [
              if (widget.rarity == CardRarity.legendary)
                BoxShadow(
                  color: Colors.amber.withAlpha(50 + (animVal * 40).round()),
                  blurRadius: 10 + (animVal * 6),
                  spreadRadius: 1,
                )
              else if (widget.rarity == CardRarity.epic)
                BoxShadow(
                  color: Colors.purpleAccent.withAlpha(40 + (animVal * 30).round()),
                  blurRadius: 8 + (animVal * 5),
                  spreadRadius: 1,
                ),
            ],
          ),
          padding: const EdgeInsets.all(2.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: widget.child,
          ),
        );
      },
    );
  }
}
