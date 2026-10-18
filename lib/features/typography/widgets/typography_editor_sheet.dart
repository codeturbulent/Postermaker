import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:poster_maker/core/widgets/stroked_text.dart';
import 'package:poster_maker/features/poster/models/canvas_element.dart';

/// Modal bottom sheet providing comprehensive typography controls, font families,
/// outline/shadow effects, color palettes, and 1-tap viral style presets.
class TypographyEditorSheet extends StatefulWidget {
  final CanvasElement initialElement;
  final ValueChanged<CanvasElement> onElementUpdated;

  const TypographyEditorSheet({
    super.key,
    required this.initialElement,
    required this.onElementUpdated,
  });

  static Future<void> show({
    required BuildContext context,
    required CanvasElement initialElement,
    required ValueChanged<CanvasElement> onElementUpdated,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => TypographyEditorSheet(
        initialElement: initialElement,
        onElementUpdated: onElementUpdated,
      ),
    );
  }

  @override
  State<TypographyEditorSheet> createState() => _TypographyEditorSheetState();
}

class _TypographyEditorSheetState extends State<TypographyEditorSheet> {
  late TextEditingController _textController;
  late CanvasElement _element;

  static const List<String> _availableFonts = [
    'Rozha One',
    'Yatra One',
    'Kalam',
    'Gotu',
    'Poppins',
    'Tiro Devanagari Hindi',
    'Cinzel',
    'Bebas Neue',
    'Montserrat',
    'Anton',
    'Playfair Display',
    'Righteous',
    'Caveat',
  ];

  static const List<Color> _paletteColors = [
    Colors.white,
    Color(0xFFFFD54F), // Gold
    Color(0xFFFF6D00), // Kesariya / Saffron
    Color(0xFFFF1744), // Crimson Red
    Color(0xFF00E676), // Bright Green
    Color(0xFF00E5FF), // Cyan
    Color(0xFFE040FB), // Magenta
    Color(0xFFFFEB3B), // Bright Yellow
    Color(0xFF212121), // Charcoal Black
  ];

  static const List<Color> _strokeColors = [
    Color(0xFF000000), // Black
    Color(0xFF3E2723), // Dark Maroon
    Color(0xFF0D47A1), // Navy
    Color(0xFF1B5E20), // Forest Green
    Color(0xFFB71C1C), // Deep Red
    Color(0xFFFFD54F), // Gold Outline
    Colors.white,
  ];

  @override
  void initState() {
    super.initState();
    _element = widget.initialElement;
    _textController = TextEditingController(text: _element.text);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _applyUpdate(CanvasElement updated) {
    setState(() => _element = updated);
    widget.onElementUpdated(updated);
  }

  void _applyPreset({
    required String fontFamily,
    required Color textColor,
    required Color strokeColor,
    required double strokeWidth,
    required bool hasShadow,
    Color? backgroundColor,
  }) {
    final updated = _element.copyWith(
      fontFamily: fontFamily,
      textColor: textColor,
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
      hasShadow: hasShadow,
      backgroundColor: backgroundColor,
      clearBackgroundColor: backgroundColor == null,
    );
    _applyUpdate(updated);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);

    return Container(
      height: mediaQuery.size.height * 0.88,
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.text_fields_rounded,
                        color: theme.colorScheme.primary, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      'टाइपोग्राफी स्टूडियो (Typography Studio)',
                      style: GoogleFonts.rozhaOne(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                FilledButton.tonal(
                  onPressed: () => Navigator.pop(context),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  ),
                  child: Text('पूर्ण (Done)', style: GoogleFonts.poppins(fontSize: 12)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Live Text Preview Card
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 80),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E1E24), Color(0xFF2C2C34)],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.colorScheme.outlineVariant.withOpacity(0.5),
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x33000000),
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: StrokedText(
                _element.text.isNotEmpty ? _element.text : 'आपका टेक्स्ट यहाँ',
                fontSize: _element.fontSize.clamp(16.0, 36.0),
                fillColor: _element.textColor,
                strokeColor: _element.strokeColor,
                strokeWidth: _element.strokeWidth,
                fontFamily: _element.fontFamily,
                fontWeight: _element.isBold ? FontWeight.w900 : FontWeight.w500,
                textAlign: _element.textAlign,
                letterSpacing: _element.letterSpacing,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Scrollable Settings Controls
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                // 1. Text input
                TextField(
                  controller: _textController,
                  decoration: InputDecoration(
                    labelText: 'टेक्स्ट लिखें / बदलें',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                  ),
                  style: GoogleFonts.poppins(fontSize: 14),
                  onChanged: (text) {
                    _applyUpdate(_element.copyWith(text: text));
                  },
                ),
                const SizedBox(height: 16),

                // 2. 1-Tap Style Presets Carousel
                Text(
                  '1-टैप स्टाइल प्रीसेट्स (Quick Presets)',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 42,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildPresetChip(
                        label: '👑 शाही स्वर्ण',
                        onTap: () => _applyPreset(
                          fontFamily: 'Rozha One',
                          textColor: const Color(0xFFFFD54F),
                          strokeColor: const Color(0xFF3E2723),
                          strokeWidth: 4.0,
                          hasShadow: true,
                        ),
                      ),
                      _buildPresetChip(
                        label: '🚩 केसरिया तेज',
                        onTap: () => _applyPreset(
                          fontFamily: 'Rozha One',
                          textColor: const Color(0xFFFF6D00),
                          strokeColor: const Color(0xFF1B0000),
                          strokeWidth: 4.5,
                          hasShadow: true,
                        ),
                      ),
                      _buildPresetChip(
                        label: '⚡ क्रांति विजय',
                        onTap: () => _applyPreset(
                          fontFamily: 'Yatra One',
                          textColor: Colors.white,
                          strokeColor: const Color(0xFF000000),
                          strokeWidth: 5.0,
                          hasShadow: true,
                        ),
                      ),
                      _buildPresetChip(
                        label: '✨ आधुनिक मिनिमल',
                        onTap: () => _applyPreset(
                          fontFamily: 'Poppins',
                          textColor: Colors.white,
                          strokeColor: Colors.transparent,
                          strokeWidth: 0.0,
                          hasShadow: true,
                        ),
                      ),
                      _buildPresetChip(
                        label: '✍️ हस्तलिखित',
                        onTap: () => _applyPreset(
                          fontFamily: 'Kalam',
                          textColor: const Color(0xFFFFEB3B),
                          strokeColor: const Color(0xFF212121),
                          strokeWidth: 2.0,
                          hasShadow: true,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 3. Font Family Selector
                Text(
                  'फ़ॉन्ट स्टाइल (Font Family)',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 48,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _availableFonts.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, idx) {
                      final font = _availableFonts[idx];
                      final isSelected = _element.fontFamily == font;
                      return ChoiceChip(
                        label: Text(
                          font,
                          style: GoogleFonts.getFont(
                            font,
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            _applyUpdate(_element.copyWith(fontFamily: font));
                          }
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // 4. Sliders: Font Size, Stroke Width, Letter Spacing
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'फ़ॉन्ट साइज (Size: ${_element.fontSize.toInt()})',
                        style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Slider(
                        value: _element.fontSize,
                        min: 14,
                        max: 64,
                        onChanged: (val) {
                          _applyUpdate(_element.copyWith(fontSize: val));
                        },
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'आउटलाइन मोटाई (${_element.strokeWidth.toInt()})',
                        style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Slider(
                        value: _element.strokeWidth,
                        min: 0,
                        max: 10,
                        onChanged: (val) {
                          _applyUpdate(_element.copyWith(strokeWidth: val));
                        },
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'अक्षरों की दूरी (${_element.letterSpacing.toStringAsFixed(1)})',
                        style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Slider(
                        value: _element.letterSpacing,
                        min: -2,
                        max: 8,
                        onChanged: (val) {
                          _applyUpdate(_element.copyWith(letterSpacing: val));
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // 5. Color Palettes: Text Fill Color
                Text(
                  'टेक्स्ट का रंग (Text Fill Color)',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _paletteColors.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, idx) {
                      final color = _paletteColors[idx];
                      final isSelected = _element.textColor.value == color.value;
                      return InkWell(
                        onTap: () => _applyUpdate(_element.copyWith(textColor: color)),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? theme.colorScheme.primary : Colors.grey,
                              width: isSelected ? 3.0 : 1.0,
                            ),
                          ),
                          child: isSelected
                              ? Icon(
                                  Icons.check,
                                  size: 18,
                                  color: color.computeLuminance() > 0.5 ? Colors.black : Colors.white,
                                )
                              : null,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 14),

                // 6. Stroke / Outline Color
                Text(
                  'आउटलाइन का रंग (Outline Color)',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _strokeColors.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, idx) {
                      final color = _strokeColors[idx];
                      final isSelected = _element.strokeColor.value == color.value;
                      return InkWell(
                        onTap: () => _applyUpdate(_element.copyWith(strokeColor: color)),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? theme.colorScheme.primary : Colors.grey,
                              width: isSelected ? 3.0 : 1.0,
                            ),
                          ),
                          child: isSelected
                              ? Icon(
                                  Icons.check,
                                  size: 18,
                                  color: color.computeLuminance() > 0.5 ? Colors.black : Colors.white,
                                )
                              : null,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // 7. Alignment & Styling Toggles
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton.filledTonal(
                      icon: Icon(
                        Icons.format_bold,
                        color: _element.isBold ? theme.colorScheme.primary : null,
                      ),
                      onPressed: () {
                        _applyUpdate(_element.copyWith(isBold: !_element.isBold));
                      },
                    ),
                    IconButton.filledTonal(
                      icon: Icon(
                        Icons.format_italic,
                        color: _element.isItalic ? theme.colorScheme.primary : null,
                      ),
                      onPressed: () {
                        _applyUpdate(_element.copyWith(isItalic: !_element.isItalic));
                      },
                    ),
                    IconButton.filledTonal(
                      icon: const Icon(Icons.format_align_left),
                      onPressed: () {
                        _applyUpdate(_element.copyWith(textAlign: TextAlign.left));
                      },
                    ),
                    IconButton.filledTonal(
                      icon: const Icon(Icons.format_align_center),
                      onPressed: () {
                        _applyUpdate(_element.copyWith(textAlign: TextAlign.center));
                      },
                    ),
                    IconButton.filledTonal(
                      icon: const Icon(Icons.format_align_right),
                      onPressed: () {
                        _applyUpdate(_element.copyWith(textAlign: TextAlign.right));
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPresetChip({
    required String label,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ActionChip(
        label: Text(label, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600)),
        onPressed: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
