import 'package:flutter/material.dart';

/// Supported types of movable canvas elements.
enum CanvasElementType {
  text,
  image,
  sticker,
}

/// Represents an interactive, draggable, resizable, and rotatable element on the poster canvas.
///
/// Uses normalized coordinates [dx] and [dy] (0.0 to 1.0) relative to canvas dimensions
/// so that elements maintain exact positioning and scaling across different screen sizes
/// and high-resolution export renders.
class CanvasElement {
  final String id;
  final CanvasElementType type;

  // Normalized position on canvas (0.0 to 1.0)
  final double dx;
  final double dy;

  // Scaling factor and rotation in radians
  final double scale;
  final double rotation;
  final int zIndex;

  // ---------------------------------------------------------------------------
  // Text Specific Properties
  // ---------------------------------------------------------------------------
  final String text;
  final String fontFamily;
  final double fontSize;
  final Color textColor;
  final Color strokeColor;
  final double strokeWidth;
  final bool hasShadow;
  final Color shadowColor;
  final bool isBold;
  final bool isItalic;
  final TextAlign textAlign;
  final Color? backgroundColor;
  final double letterSpacing;

  // ---------------------------------------------------------------------------
  // Image / Sticker / Cutout Specific Properties
  // ---------------------------------------------------------------------------
  final String? imagePath; // Local file path or network URL
  final String? stickerEmoji; // Optional emoji string if sticker
  final double width; // Normalized width (e.g. 0.3 = 30% of canvas width)
  final double height; // Normalized height
  final bool isCutout;

  const CanvasElement({
    required this.id,
    required this.type,
    this.dx = 0.5,
    this.dy = 0.5,
    this.scale = 1.0,
    this.rotation = 0.0,
    this.zIndex = 0,
    // Text defaults
    this.text = '',
    this.fontFamily = 'Rozha One',
    this.fontSize = 24.0,
    this.textColor = Colors.white,
    this.strokeColor = const Color(0xFF1E1E1E),
    this.strokeWidth = 3.5,
    this.hasShadow = true,
    this.shadowColor = const Color(0x99000000),
    this.isBold = true,
    this.isItalic = false,
    this.textAlign = TextAlign.center,
    this.backgroundColor,
    this.letterSpacing = 0.0,
    // Image defaults
    this.imagePath,
    this.stickerEmoji,
    this.width = 0.35,
    this.height = 0.35,
    this.isCutout = false,
  });

  /// Creates a copy of this element with updated fields.
  CanvasElement copyWith({
    String? id,
    CanvasElementType? type,
    double? dx,
    double? dy,
    double? scale,
    double? rotation,
    int? zIndex,
    String? text,
    String? fontFamily,
    double? fontSize,
    Color? textColor,
    Color? strokeColor,
    double? strokeWidth,
    bool? hasShadow,
    Color? shadowColor,
    bool? isBold,
    bool? isItalic,
    TextAlign? textAlign,
    Color? backgroundColor,
    bool clearBackgroundColor = false,
    double? letterSpacing,
    String? imagePath,
    String? stickerEmoji,
    double? width,
    double? height,
    bool? isCutout,
  }) {
    return CanvasElement(
      id: id ?? this.id,
      type: type ?? this.type,
      dx: dx ?? this.dx,
      dy: dy ?? this.dy,
      scale: scale ?? this.scale,
      rotation: rotation ?? this.rotation,
      zIndex: zIndex ?? this.zIndex,
      text: text ?? this.text,
      fontFamily: fontFamily ?? this.fontFamily,
      fontSize: fontSize ?? this.fontSize,
      textColor: textColor ?? this.textColor,
      strokeColor: strokeColor ?? this.strokeColor,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      hasShadow: hasShadow ?? this.hasShadow,
      shadowColor: shadowColor ?? this.shadowColor,
      isBold: isBold ?? this.isBold,
      isItalic: isItalic ?? this.isItalic,
      textAlign: textAlign ?? this.textAlign,
      backgroundColor: clearBackgroundColor
          ? null
          : (backgroundColor ?? this.backgroundColor),
      letterSpacing: letterSpacing ?? this.letterSpacing,
      imagePath: imagePath ?? this.imagePath,
      stickerEmoji: stickerEmoji ?? this.stickerEmoji,
      width: width ?? this.width,
      height: height ?? this.height,
      isCutout: isCutout ?? this.isCutout,
    );
  }

  /// Converts element to JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'dx': dx,
      'dy': dy,
      'scale': scale,
      'rotation': rotation,
      'zIndex': zIndex,
      'text': text,
      'fontFamily': fontFamily,
      'fontSize': fontSize,
      'textColor': textColor.value,
      'strokeColor': strokeColor.value,
      'strokeWidth': strokeWidth,
      'hasShadow': hasShadow,
      'shadowColor': shadowColor.value,
      'isBold': isBold,
      'isItalic': isItalic,
      'textAlign': textAlign.index,
      'backgroundColor': backgroundColor?.value,
      'letterSpacing': letterSpacing,
      'imagePath': imagePath,
      'stickerEmoji': stickerEmoji,
      'width': width,
      'height': height,
      'isCutout': isCutout,
    };
  }

  /// Factory constructor to restore element from JSON map.
  factory CanvasElement.fromJson(Map<String, dynamic> json) {
    return CanvasElement(
      id: json['id'] as String? ?? 'elem_${DateTime.now().millisecondsSinceEpoch}',
      type: CanvasElementType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => CanvasElementType.text,
      ),
      dx: (json['dx'] as num?)?.toDouble() ?? 0.5,
      dy: (json['dy'] as num?)?.toDouble() ?? 0.5,
      scale: (json['scale'] as num?)?.toDouble() ?? 1.0,
      rotation: (json['rotation'] as num?)?.toDouble() ?? 0.0,
      zIndex: json['zIndex'] as int? ?? 0,
      text: json['text'] as String? ?? '',
      fontFamily: json['fontFamily'] as String? ?? 'Rozha One',
      fontSize: (json['fontSize'] as num?)?.toDouble() ?? 24.0,
      textColor: Color(json['textColor'] as int? ?? 0xFFFFFFFF),
      strokeColor: Color(json['strokeColor'] as int? ?? 0xFF1E1E1E),
      strokeWidth: (json['strokeWidth'] as num?)?.toDouble() ?? 3.5,
      hasShadow: json['hasShadow'] as bool? ?? true,
      shadowColor: Color(json['shadowColor'] as int? ?? 0x99000000),
      isBold: json['isBold'] as bool? ?? true,
      isItalic: json['isItalic'] as bool? ?? false,
      textAlign: TextAlign.values[
          (json['textAlign'] as int? ?? TextAlign.center.index)
              .clamp(0, TextAlign.values.length - 1)],
      backgroundColor: json['backgroundColor'] != null
          ? Color(json['backgroundColor'] as int)
          : null,
      letterSpacing: (json['letterSpacing'] as num?)?.toDouble() ?? 0.0,
      imagePath: json['imagePath'] as String?,
      stickerEmoji: json['stickerEmoji'] as String?,
      width: (json['width'] as num?)?.toDouble() ?? 0.35,
      height: (json['height'] as num?)?.toDouble() ?? 0.35,
      isCutout: json['isCutout'] as bool? ?? false,
    );
  }
}
