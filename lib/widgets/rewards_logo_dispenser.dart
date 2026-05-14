import 'package:flutter/material.dart';
import 'dart:async';

class RewardLogoDispenser extends StatefulWidget {
  final double size;

  const RewardLogoDispenser({
    super.key,
    this.size = 70, // Decreased outer width
  });

  @override
  State<RewardLogoDispenser> createState() => _RewardLogoDispenserState();
}

class _RewardLogoDispenserState extends State<RewardLogoDispenser> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _currentIndex = 0;

  final List<String> _logos = [
    'https://upload.wikimedia.org/wikipedia/commons/thumb/2/22/BigBasket_Logo.png/512px-BigBasket_Logo.png',
    'https://upload.wikimedia.org/wikipedia/en/thumb/1/12/Swiggy_logo.svg/512px-Swiggy_logo.svg.png',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/b/bd/Zomato_Logo.png/512px-Zomato_Logo.png',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/d/d5/Myntra_logo.png/512px-Myntra_logo.png',
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _startLoop();
  }

  void _startLoop() async {
    while (mounted) {
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      await _controller.forward();
      if (!mounted) return;
      setState(() {
        _currentIndex = (_currentIndex + 1) % _logos.length;
        _controller.reset();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.size,
      height: widget.size * 1.3,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8), // Sharper corners
        color: Colors.black.withOpacity(0.4),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Background card (static - no movement)
            Positioned(
              top: 4,
              child: _buildMiniCard(_logos[(_currentIndex + 2) % _logos.length], opacity: 0.2),
            ),
            // Next card (static - waiting to be revealed)
            Positioned(
              top: 12,
              child: _buildMiniCard(_logos[(_currentIndex + 1) % _logos.length], opacity: 0.5),
            ),
            // Current card (sliding down)
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final slide = 100.0 * _controller.value;
                final opacity = 1.0 - (_controller.value * 1.5);
                return Positioned(
                  top: 12 + slide, // Start exactly where the next card is
                  child: _buildMiniCard(
                    _logos[_currentIndex],
                    opacity: opacity.clamp(0.0, 1.0),
                  ),
                );
              },
            ),
            // Grayish "Front Wall" with Accent highlight
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 16,
              child: Column(
                children: [
                  Container(
                    height: 2,
                    width: double.infinity,
                    color: const Color(0xFFFF00FF),
                  ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E2E2E),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 8,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniCard(String url, {double opacity = 1.0}) {
    return Opacity(
      opacity: opacity,
      child: Container(
        width: widget.size * 0.75 + 20, // Increased width
        height: widget.size * 0.75 + 10,
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(4), // Sharper corners
          border: Border.all(color: Colors.white.withOpacity(0.1), width: 0.5),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(6.0),
            child: Image.network(
              url,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.card_giftcard,
                color: Colors.white24,
                size: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
