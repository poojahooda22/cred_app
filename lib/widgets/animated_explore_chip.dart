import 'dart:async';

import 'package:flutter/material.dart';
import '../theme/cred_theme.dart';

class AnimatedExploreChip extends StatefulWidget {
  final IconData icon;
  final String label;
  final String alternateLabel;
  final Duration initialDelay;
  final Duration alternateHold;
  final Duration restBetweenCycles;
  final Duration slideDuration;

  const AnimatedExploreChip({
    super.key,
    required this.icon,
    required this.label,
    required this.alternateLabel,
    this.initialDelay = const Duration(seconds: 2),
    this.alternateHold = const Duration(seconds: 2),
    this.restBetweenCycles = const Duration(seconds: 4),
    this.slideDuration = const Duration(milliseconds: 500),
  });

  @override
  State<AnimatedExploreChip> createState() => _AnimatedExploreChipState();
}

class _AnimatedExploreChipState extends State<AnimatedExploreChip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _t;
  Timer? _kickoff;
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.slideDuration,
    );
    _t = CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic);
    _kickoff = Timer(widget.initialDelay, _runCycle);
  }

  Future<void> _runCycle() async {
    while (!_disposed && mounted) {
      await _controller.forward();
      if (_disposed || !mounted) return;
      await Future.delayed(widget.alternateHold);
      if (_disposed || !mounted) return;
      await _controller.reverse();
      if (_disposed || !mounted) return;
      await Future.delayed(widget.restBetweenCycles);
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _kickoff?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Widget _buildPrimary() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(widget.icon, color: CredColors.secondary, size: 16),
        const SizedBox(width: 8),
        Text(
          widget.label,
          style: const TextStyle(
            color: CredColors.secondary,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildAlternate() {
    return Text(
      widget.alternateLabel,
      style: const TextStyle(
        color: CredColors.secondary,
        fontSize: 13,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: CredColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: CredColors.divider, width: 0.5),
      ),
      child: ClipRect(
        child: AnimatedBuilder(
          animation: _t,
          builder: (context, _) {
            return Stack(
              alignment: Alignment.centerLeft,
              children: [
                // Width-locking ghost (transparent primary) so the chip
                // never resizes when content swaps.
                Opacity(opacity: 0, child: _buildPrimary()),
                // Primary content slides right (out)
                FractionalTranslation(
                  translation: Offset(_t.value, 0),
                  child: _buildPrimary(),
                ),
                // Alternate fills the chip and ends up centered;
                // FractionalTranslation slides the whole layer in from the left.
                Positioned.fill(
                  child: FractionalTranslation(
                    translation: Offset(_t.value - 1, 0),
                    child: Center(child: _buildAlternate()),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
