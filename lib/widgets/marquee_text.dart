import 'package:flutter/material.dart';

class MarqueeWidget extends StatefulWidget {
  final String text;
  final TextStyle style;
  final double pixelsPerSecond;
  final double gap;

  const MarqueeWidget({
    super.key,
    required this.text,
    required this.style,
    this.pixelsPerSecond = 30,
    this.gap = 8,
  });

  @override
  State<MarqueeWidget> createState() => _MarqueeWidgetState();
}

class _MarqueeWidgetState extends State<MarqueeWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late double _segmentWidth;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _measureAndStart();
  }

  @override
  void didUpdateWidget(covariant MarqueeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text ||
        oldWidget.style != widget.style ||
        oldWidget.gap != widget.gap ||
        oldWidget.pixelsPerSecond != widget.pixelsPerSecond) {
      _measureAndStart();
    }
  }

  void _measureAndStart() {
    final tp = TextPainter(
      text: TextSpan(text: widget.text, style: widget.style),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    _segmentWidth = tp.width + widget.gap;
    final seconds = _segmentWidth / widget.pixelsPerSecond;
    _controller
      ..stop()
      ..duration = Duration(milliseconds: (seconds * 1000).round())
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [Colors.transparent, Colors.black, Colors.black, Colors.transparent],
        stops: [0.0, 0.05, 0.95, 1.0],
      ).createShader(bounds),
      blendMode: BlendMode.dstIn,
      child: ClipRect(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final copyCount =
                (constraints.maxWidth / _segmentWidth).ceil() + 2;
            final segment = SizedBox(
              width: _segmentWidth,
              child: Row(
                children: [
                  Text(
                    widget.text,
                    style: widget.style,
                    maxLines: 1,
                    softWrap: false,
                  ),
                ],
              ),
            );
            return AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(-_controller.value * _segmentWidth, 0),
                  child: child,
                );
              },
              child: OverflowBox(
                alignment: Alignment.centerLeft,
                maxWidth: double.infinity,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(copyCount, (_) => segment),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
