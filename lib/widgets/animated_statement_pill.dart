import 'dart:async';
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import '../theme/cred_theme.dart';

class AnimatedStatementPill extends StatefulWidget {
  final String primaryText;
  final IconData primaryIcon;
  final Color primaryIconColor;
  final String alternateText;
  final IconData? alternateIcon;
  final Color? alternateIconColor;
  final Duration interval;
  final Duration slideDuration;

  const AnimatedStatementPill({
    super.key,
    required this.primaryText,
    required this.primaryIcon,
    this.primaryIconColor = const Color(0xFF4F8DFF),
    required this.alternateText,
    this.alternateIcon,
    this.alternateIconColor,
    this.interval = const Duration(seconds: 2),
    this.slideDuration = const Duration(milliseconds: 400),
  });

  @override
  State<AnimatedStatementPill> createState() => _AnimatedStatementPillState();
}

class _AnimatedStatementPillState extends State<AnimatedStatementPill>
    with SingleTickerProviderStateMixin {
  static const double _textFontSize = 12;
  static const double _leadingIconSize = 14;
  static const double _leadingGap = 6;
  static const double _trailingGap = 4;
  static const double _trailingIconSize = 16;
  static const double _horizontalPadding = 14;

  late final AnimationController _controller;
  late final Animation<double> _t;
  Timer? _timer;
  bool _showAlternate = false;
  double _primaryWidth = 0;
  double _alternateWidth = 0;
  bool _measured = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.slideDuration,
    );
    _t = CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _measure();
    if (!_measured) {
      _measured = true;
      _scheduleNext();
    }
  }

  void _measure() {
    final base = DefaultTextStyle.of(context).style.merge(
          const TextStyle(
            fontSize: _textFontSize,
            fontWeight: FontWeight.w500,
            color: CredColors.primary,
          ),
        );
    _primaryWidth = _contentWidth(
      icon: widget.primaryIcon,
      text: widget.primaryText,
      style: base,
    );
    _alternateWidth = _contentWidth(
      icon: widget.alternateIcon,
      text: widget.alternateText,
      style: base,
    );
  }

  double _contentWidth({
    required IconData? icon,
    required String text,
    required TextStyle style,
  }) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    final leading = icon != null ? _leadingIconSize + _leadingGap : 0.0;
    // +8 buffer: TextPainter rounds slightly differently than the rendered Text,
    // and the chevron icon glyph can extend a few pixels past its declared size.
    return leading + tp.width + _trailingGap + _trailingIconSize + 8;
  }

  void _scheduleNext() {
    _timer = Timer(widget.interval, _flip);
  }

  Future<void> _flip() async {
    if (!mounted) return;
    await _controller.forward(from: 0);
    if (!mounted) return;
    setState(() {
      _showAlternate = !_showAlternate;
      _controller.value = 0;
    });
    _scheduleNext();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fromWidth = _showAlternate ? _alternateWidth : _primaryWidth;
    final toWidth = _showAlternate ? _primaryWidth : _alternateWidth;

    final currentIcon =
        _showAlternate ? widget.alternateIcon : widget.primaryIcon;
    final currentIconColor = _showAlternate
        ? (widget.alternateIconColor ?? widget.primaryIconColor)
        : widget.primaryIconColor;
    final currentText =
        _showAlternate ? widget.alternateText : widget.primaryText;

    final nextIcon =
        _showAlternate ? widget.primaryIcon : widget.alternateIcon;
    final nextIconColor = _showAlternate
        ? widget.primaryIconColor
        : (widget.alternateIconColor ?? widget.primaryIconColor);
    final nextText =
        _showAlternate ? widget.primaryText : widget.alternateText;

    return AnimatedBuilder(
      animation: _t,
      builder: (context, _) {
        final width = lerpDouble(fromWidth, toWidth, _t.value)!;
        return Container(
          width: width + _horizontalPadding * 2,
          padding: const EdgeInsets.symmetric(
            horizontal: _horizontalPadding,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: CredColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: CredColors.divider, width: 0.5),
          ),
          child: ClipRect(
            child: SizedBox(
              height: 20,
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  // Current content slides up and out
                  OverflowBox(
                    alignment: Alignment.centerLeft,
                    maxWidth: double.infinity,
                    child: FractionalTranslation(
                      translation: Offset(0, -_t.value),
                      child: _buildRow(
                        icon: currentIcon,
                        iconColor: currentIconColor,
                        text: currentText,
                      ),
                    ),
                  ),
                  // Next content slides up from below
                  OverflowBox(
                    alignment: Alignment.centerLeft,
                    maxWidth: double.infinity,
                    child: FractionalTranslation(
                      translation: Offset(0, 1 - _t.value),
                      child: _buildRow(
                        icon: nextIcon,
                        iconColor: nextIconColor,
                        text: nextText,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRow({
    required IconData? icon,
    required Color iconColor,
    required String text,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, color: iconColor, size: _leadingIconSize),
          const SizedBox(width: _leadingGap),
        ],
        Text(
          text,
          style: const TextStyle(
            color: CredColors.primary,
            fontSize: _textFontSize,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: _trailingGap),
        const Icon(
          Icons.chevron_right,
          color: CredColors.secondary,
          size: _trailingIconSize,
        ),
      ],
    );
  }
}
