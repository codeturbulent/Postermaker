import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../services/background_remover_service.dart';

enum BackgroundRemoverMode {
  magicWand('मैजिक रंग इरेज़र', Icons.auto_fix_high),
  portraitFade('बैनर बॉटम फेड', Icons.gradient_rounded),
  greenScreen('ग्रीन स्क्रीन / स्टूडियो', Icons.crop_free_rounded);

  final String label;
  final IconData icon;
  const BackgroundRemoverMode(this.label, this.icon);
}

/// Dedicated Background Remover & Portrait Cutout Studio screen.
///
/// Enables users to easily remove backgrounds, green screens, or create seamless
/// bottom-faded leader cutouts on-device for high-impact poster composition.
class BackgroundRemoverScreen extends StatefulWidget {
  final File? initialImageFile;

  const BackgroundRemoverScreen({
    super.key,
    this.initialImageFile,
  });

  @override
  State<BackgroundRemoverScreen> createState() => _BackgroundRemoverScreenState();
}

class _BackgroundRemoverScreenState extends State<BackgroundRemoverScreen> {
  File? _sourceFile;
  File? _processedFile;
  bool _isProcessing = false;

  BackgroundRemoverMode _activeMode = BackgroundRemoverMode.magicWand;
  Color _targetColor = Colors.white;
  double _tolerance = 45.0;
  double _feather = 15.0;
  double _fadeStart = 0.65;

  final List<Color> _presetColors = const [
    Colors.white,
    Color(0xFF00FF00), // Pure Chroma Green
    Color(0xFF0000FF), // Pure Chroma Blue
    Color(0xFFE0E0E0), // Studio Light Grey
    Color(0xFF000000), // Pure Black
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialImageFile != null) {
      _sourceFile = widget.initialImageFile;
      _autoDetectCornerColor();
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _sourceFile = File(picked.path);
        _processedFile = null;
      });
      await _autoDetectCornerColor();
    }
  }

  Future<void> _autoDetectCornerColor() async {
    if (_sourceFile == null) return;
    final sampled = await BackgroundRemoverService.sampleCornerColor(_sourceFile!);
    if (sampled != null && mounted) {
      setState(() => _targetColor = sampled);
    }
  }

  Future<void> _applyRemoval() async {
    if (_sourceFile == null) return;

    setState(() => _isProcessing = true);
    File? result;

    try {
      if (_activeMode == BackgroundRemoverMode.portraitFade) {
        result = await BackgroundRemoverService.applyPortraitBottomFade(
          sourceImageFile: _processedFile ?? _sourceFile!,
          fadeStartFactor: _fadeStart,
        );
      } else {
        result = await BackgroundRemoverService.removeColorBackground(
          sourceImageFile: _sourceFile!,
          targetColor: _targetColor,
          tolerance: _tolerance,
          feather: _feather,
        );
      }

      if (mounted) {
        setState(() {
          _processedFile = result ?? _processedFile;
          _isProcessing = false;
        });

        if (result != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'कटआउट सफलतापूर्वक तैयार हुआ!',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
              backgroundColor: const Color(0xFF1B5E20),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('प्रोसेसिंग त्रुटि: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _finishAndReturn() {
    final finalFile = _processedFile ?? _sourceFile;
    if (finalFile != null) {
      Navigator.pop(context, finalFile);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayFile = _processedFile ?? _sourceFile;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'बैकग्राउंड इरेज़र स्टूडियो',
          style: GoogleFonts.rozhaOne(fontSize: 19),
        ),
        actions: [
          if (displayFile != null)
            TextButton.icon(
              onPressed: _finishAndReturn,
              icon: const Icon(Icons.check_circle_rounded, color: Colors.green),
              label: Text(
                'उपयोग करें',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  color: Colors.green,
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Preview Canvas (Transparent Checkered Backdrop)
            Expanded(
              flex: 5,
              child: Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.colorScheme.outlineVariant),
                  // Checkered background pattern to visually confirm transparency
                  gradient: const RadialGradient(
                    colors: [Color(0xFF37474F), Color(0xFF212121)],
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Transparent checkered grid pattern simulation
                      CustomPaint(
                        painter: _CheckerboardPainter(),
                      ),
                      if (displayFile != null)
                        Center(
                          child: Image.file(
                            displayFile,
                            fit: BoxFit.contain,
                          ),
                        )
                      else
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_photo_alternate_outlined,
                                size: 64,
                                color: theme.colorScheme.outline,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'फ़ोटो चुनें जिसका बैकग्राउंड हटाना है',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 12),
                              FilledButton.icon(
                                onPressed: _pickImage,
                                icon: const Icon(Icons.photo_library_outlined),
                                label: Text(
                                  'गैलरी से फ़ोटो लें',
                                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (_isProcessing)
                        Container(
                          color: Colors.black.withOpacity(0.55),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const CircularProgressIndicator(color: Colors.white),
                                const SizedBox(height: 14),
                                Text(
                                  'बैकग्राउंड प्रोसेस हो रहा है...',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            // Controls & Toolbar
            Expanded(
              flex: 4,
              child: Card(
                margin: EdgeInsets.zero,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                elevation: 4,
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  children: [
                    // Mode Selector
                    SegmentedButton<BackgroundRemoverMode>(
                      segments: BackgroundRemoverMode.values.map((mode) {
                        return ButtonSegment(
                          value: mode,
                          label: Text(
                            mode.label.split(' ').first,
                            style: GoogleFonts.poppins(fontSize: 11),
                          ),
                          icon: Icon(mode.icon, size: 16),
                        );
                      }).toList(),
                      selected: {_activeMode},
                      onSelectionChanged: (set) {
                        if (set.isNotEmpty) {
                          setState(() => _activeMode = set.first);
                        }
                      },
                    ),
                    const SizedBox(height: 12),

                    // Controls based on active mode
                    if (_activeMode == BackgroundRemoverMode.magicWand ||
                        _activeMode == BackgroundRemoverMode.greenScreen) ...[
                      // Color selection row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'हटाने का रंग (Target Key Color):',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          OutlinedButton.icon(
                            onPressed: _autoDetectCornerColor,
                            icon: const Icon(Icons.colorize_rounded, size: 14),
                            label: Text(
                              'ऑटो सैम्पल',
                              style: GoogleFonts.poppins(fontSize: 11),
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      SizedBox(
                        height: 38,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _presetColors.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (context, idx) {
                            final col = _presetColors[idx];
                            final isSel = _targetColor.value == col.value;
                            return InkWell(
                              onTap: () => setState(() => _targetColor = col),
                              borderRadius: BorderRadius.circular(19),
                              child: Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: col,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSel
                                        ? theme.colorScheme.primary
                                        : Colors.grey,
                                    width: isSel ? 3.0 : 1.0,
                                  ),
                                ),
                                child: isSel
                                    ? Icon(
                                        Icons.check,
                                        size: 16,
                                        color: col.computeLuminance() > 0.5
                                            ? Colors.black
                                            : Colors.white,
                                      )
                                    : null,
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Tolerance Slider
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'सहनशीलता (Tolerance: ${_tolerance.toInt()})',
                              style: GoogleFonts.poppins(fontSize: 12),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Slider(
                              value: _tolerance,
                              min: 10,
                              max: 120,
                              onChanged: (val) => setState(() => _tolerance = val),
                            ),
                          ),
                        ],
                      ),

                      // Feather Slider
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'किनारे स्मूथ (Feather: ${_feather.toInt()})',
                              style: GoogleFonts.poppins(fontSize: 12),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Slider(
                              value: _feather,
                              min: 0,
                              max: 30,
                              onChanged: (val) => setState(() => _feather = val),
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      // Portrait Bottom Fade Slider
                      Text(
                        'बॉटम फेड (Bottom Dissolve Fade):',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'राजनीतिक और उत्सव पोस्टरों के लिए नीचे से फ़ोटो को धीरे-धीरे पारदर्शी बनाएं ताकि वह बैकग्राउंड में घुल-मिल जाए।',
                        style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'फेड शुरुआत (${(_fadeStart * 100).toInt()}%)',
                              style: GoogleFonts.poppins(fontSize: 12),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Slider(
                              value: _fadeStart,
                              min: 0.3,
                              max: 0.9,
                              onChanged: (val) => setState(() => _fadeStart = val),
                            ),
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 10),

                    // Actions Row
                    Row(
                      children: [
                        OutlinedButton.icon(
                          onPressed: _pickImage,
                          icon: const Icon(Icons.image_outlined, size: 18),
                          label: Text(
                            'अन्य फ़ोटो',
                            style: GoogleFonts.poppins(fontSize: 12),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (_processedFile != null)
                          TextButton(
                            onPressed: () {
                              setState(() => _processedFile = null);
                            },
                            child: Text(
                              'रीसेट',
                              style: GoogleFonts.poppins(fontSize: 12, color: Colors.red),
                            ),
                          ),
                        const Spacer(),
                        FilledButton.icon(
                          onPressed: _sourceFile != null && !_isProcessing
                              ? _applyRemoval
                              : null,
                          icon: const Icon(Icons.auto_fix_high_rounded),
                          label: Text(
                            'कटआउट बनाएं',
                            style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Helper custom painter that draws a checkered transparency background pattern
class _CheckerboardPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const squareSize = 14.0;
    final paintLight = Paint()..color = const Color(0xFF2E3339);
    final paintDark = Paint()..color = const Color(0xFF22262B);

    for (double y = 0; y < size.height; y += squareSize) {
      for (double x = 0; x < size.width; x += squareSize) {
        final isEven =
            ((x / squareSize).floor() + (y / squareSize).floor()) % 2 == 0;
        canvas.drawRect(
          Rect.fromLTWH(x, y, squareSize, squareSize),
          isEven ? paintLight : paintDark,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
