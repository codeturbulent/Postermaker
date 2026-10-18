import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// An authentic Indian digital banner styled text widget.
///
/// Uses a dual-pass [Stack] of two [Text] widgets:
/// 1. The background stroke pass with outer outline using [PaintingStyle.stroke].
/// 2. The foreground solid fill pass with rich drop shadows.
///
/// Configured with strict [StrutStyle] line height calculations to guarantee that
/// complex Devanagari matras (e.g., इकार, ईकार, एकार, ऐकार, चंद्रबिंदु, उकार, ऊकार)
/// are never clipped at the bounding boundaries.
class StrokedText extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color fillColor;
  final Color strokeColor;
  final double strokeWidth;
  final FontWeight fontWeight;
  final TextAlign textAlign;
  final String? fontFamily;
  final List<Shadow>? shadows;
  final int? maxLines;
  final TextOverflow overflow;
  final double height;

  const StrokedText(
    this.text, {
    super.key,
    this.fontSize = 28.0,
    this.fillColor = Colors.white,
    this.strokeColor = const Color(0xFF1A1A1A),
    this.strokeWidth = 4.0,
    this.fontWeight = FontWeight.w900,
    this.textAlign = TextAlign.center,
    this.fontFamily,
    this.shadows,
    this.maxLines = 2,
    this.overflow = TextOverflow.ellipsis,
    this.height = 1.3,
  });

  TextStyle _resolveBaseTextStyle({required bool isStroke}) {
    final effectiveShadows = isStroke
        ? null
        : (shadows ??
            [
              const Shadow(
                offset: Offset(2.0, 3.0),
                blurRadius: 4.0,
                color: Color(0x99000000),
              ),
              const Shadow(
                offset: Offset(-1.0, 2.0),
                blurRadius: 3.0,
                color: Color(0x66000000),
              ),
            ]);

    final foregroundPaint = isStroke
        ? (Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..color = strokeColor)
        : null;

    final color = isStroke ? null : fillColor;

    // Resolve typography from Google Fonts Devanagari family
    switch (fontFamily) {
      case 'Yatra One':
        return GoogleFonts.yatraOne(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
          foreground: foregroundPaint,
          shadows: effectiveShadows,
          height: height,
        );
      case 'Rozha One':
        return GoogleFonts.rozhaOne(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
          foreground: foregroundPaint,
          shadows: effectiveShadows,
          height: height,
        );
      case 'Gotu':
        return GoogleFonts.gotu(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
          foreground: foregroundPaint,
          shadows: effectiveShadows,
          height: height,
        );
      case 'Poppins':
      default:
        return GoogleFonts.poppins(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
          foreground: foregroundPaint,
          shadows: effectiveShadows,
          height: height,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    // StrutStyle forces line box height metric to account for high Hindi diacritics
    final strutStyle = StrutStyle(
      fontSize: fontSize,
      height: height,
      forceStrutHeight: true,
      fontWeight: fontWeight,
    );

    return Stack(
      alignment: Alignment.center,
      children: [
        // 1. Bottom Stroked Text
        Text(
          text,
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: overflow,
          strutStyle: strutStyle,
          style: _resolveBaseTextStyle(isStroke: true),
        ),

        // 2. Top Solid Filled & Shadowed Text
        Text(
          text,
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: overflow,
          strutStyle: strutStyle,
          style: _resolveBaseTextStyle(isStroke: false),
        ),
      ],
    );
  }
}
