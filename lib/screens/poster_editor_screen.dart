import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/poster_template.dart';
import '../providers/poster_provider.dart';
import '../utils/image_exporter.dart';
import '../widgets/poster_canvas.dart';
import 'profile_edit_screen.dart';

class PosterEditorScreen extends StatefulWidget {
  const PosterEditorScreen({super.key});

  @override
  State<PosterEditorScreen> createState() => _PosterEditorScreenState();
}

class _PosterEditorScreenState extends State<PosterEditorScreen> {
  final GlobalKey _canvasRepaintKey = GlobalKey();
  late TextEditingController _greetingController;

  final List<Color> _availableRibbonColors = const [
    Color(0xFFD84315), // Deep Kesariya / Saffron
    Color(0xFF1B5E20), // Bharat / Forest Green
    Color(0xFFC62828), // Kranti / Samajwadi Red
    Color(0xFF0D47A1), // Deep Navy Blue
    Color(0xFF4A148C), // Royal Purple
    Color(0xFF3E2723), // Deep Maroon
    Color(0xFF212121), // Slate Black
  ];

  @override
  void initState() {
    super.initState();
    final provider = context.read<PosterProvider>();
    _greetingController =
        TextEditingController(text: provider.customGreeting);
  }

  @override
  void dispose() {
    _greetingController.dispose();
    super.dispose();
  }

  Future<void> _handleSaveToGallery() async {
    final provider = context.read<PosterProvider>();
    provider.setIsExporting(true);

    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      final result = await ImageExporter.saveToGallery(
        repaintKey: _canvasRepaintKey,
        pixelRatio: 3.0,
      );

      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(
              result.message,
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            backgroundColor: result.isSuccess
                ? const Color(0xFF1B5E20)
                : const Color(0xFFC62828),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        provider.setIsExporting(false);
      }
    }
  }

  Future<void> _handleSharePoster() async {
    final provider = context.read<PosterProvider>();
    provider.setIsExporting(true);

    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      final greeting = provider.customGreeting.isNotEmpty
          ? provider.customGreeting
          : provider.selectedTemplate.defaultGreetingText;
      final shareText =
          '$greeting\n\n- ${provider.profile.fullName} (${provider.profile.designation})\n\nबनाया गया देसी पोस्टर मेकर ऐप से।';

      final result = await ImageExporter.sharePoster(
        repaintKey: _canvasRepaintKey,
        message: shareText,
        pixelRatio: 3.0,
      );

      if (!result.isSuccess && mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: const Color(0xFFC62828),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        provider.setIsExporting(false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<PosterProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          provider.selectedTemplate.title,
          style: GoogleFonts.rozhaOne(fontSize: 19),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_note_rounded),
            tooltip: 'प्रोफ़ाइल बदलें',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ProfileEditScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Scrollable Content Area: Canvas Preview & Controls
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14.0,
                  vertical: 8.0,
                ),
                children: [
                  // 1. Live Interactive Canvas Preview
                  Center(
                    child: Container(
                      constraints: const BoxConstraints(
                        maxWidth: 420,
                        maxHeight: 480,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16.0),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x33000000),
                            blurRadius: 14,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: PosterCanvas(
                        repaintKey: _canvasRepaintKey,
                        template: provider.selectedTemplate,
                        profile: provider.profile,
                        greetingText: provider.customGreeting,
                        photoAlignment: provider.photoAlignment,
                        ribbonColor: provider.ribbonColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // 2. Custom Greeting Editor on the fly
                  Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(
                        color: theme.colorScheme.outlineVariant,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'शीर्षक / मुख्य शुभकामना संदेश',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  _greetingController.text = provider
                                      .selectedTemplate.defaultGreetingText;
                                  provider.setCustomGreeting(
                                    provider.selectedTemplate.defaultGreetingText,
                                  );
                                },
                                child: Text(
                                  'रीसेट करें',
                                  style: GoogleFonts.poppins(fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          TextField(
                            controller: _greetingController,
                            decoration: InputDecoration(
                              hintText: 'उदा: हार्दिक बधाई एवं शुभकामनाएं',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                            ),
                            style: GoogleFonts.rozhaOne(fontSize: 16),
                            onChanged: (text) {
                              provider.setCustomGreeting(text);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 3. Customization Controls: Photo Alignment & Ribbon Color
                  Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(
                        color: theme.colorScheme.outlineVariant,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Photo Alignment Toggle
                          Text(
                            'फ़ोटो की स्थिति (Photo Alignment)',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SegmentedButton<PhotoAlignment>(
                            segments: const [
                              ButtonSegment(
                                value: PhotoAlignment.left,
                                label: Text('बाएं (Left)'),
                                icon: Icon(Icons.align_horizontal_left),
                              ),
                              ButtonSegment(
                                value: PhotoAlignment.right,
                                label: Text('दाएं (Right)'),
                                icon: Icon(Icons.align_horizontal_right),
                              ),
                            ],
                            selected: {provider.photoAlignment},
                            onSelectionChanged: (set) {
                              if (set.isNotEmpty) {
                                provider.setPhotoAlignment(set.first);
                              }
                            },
                          ),
                          const SizedBox(height: 16),

                          // Ribbon Theme Color Picker
                          Text(
                            'नेमप्लेट रिबन का रंग (Ribbon Color)',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 40,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: _availableRibbonColors.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: 10),
                              itemBuilder: (context, index) {
                                final color = _availableRibbonColors[index];
                                final isSelected =
                                    provider.ribbonColor.toARGB32() ==
                                        color.toARGB32();
                                return InkWell(
                                  onTap: () => provider.setRibbonColor(color),
                                  borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                    width: 38,
                                    height: 38,
                                    decoration: BoxDecoration(
                                      color: color,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.transparent,
                                        width: 2.5,
                                      ),
                                      boxShadow: [
                                        if (isSelected)
                                          const BoxShadow(
                                            color: Color(0x66000000),
                                            blurRadius: 6,
                                            spreadRadius: 1,
                                          ),
                                      ],
                                    ),
                                    child: isSelected
                                        ? const Icon(
                                            Icons.check,
                                            color: Colors.white,
                                            size: 20,
                                          )
                                        : null,
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // 4. Quick Template Switcher Horizontal Carousel
                  Text(
                    'अन्य टेम्पलेट चुनें',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 80,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: PosterTemplate.dummyTemplates.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        final tpl = PosterTemplate.dummyTemplates[index];
                        final isCurrent =
                            tpl.id == provider.selectedTemplate.id;

                        return InkWell(
                          onTap: () {
                            provider.selectTemplate(tpl);
                            _greetingController.text =
                                tpl.defaultGreetingText;
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: 120,
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isCurrent
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.outlineVariant,
                                width: isCurrent ? 2.5 : 1.0,
                              ),
                              gradient: LinearGradient(
                                colors: tpl.gradientColors,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                tpl.title,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),

            // Bottom Sticky Action Bar: Save to Gallery & Share
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1A000000),
                    blurRadius: 8,
                    offset: Offset(0, -3),
                  ),
                ],
              ),
              child: provider.isExporting
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const CircularProgressIndicator(),
                            const SizedBox(width: 16),
                            Text(
                              'एचडी पोस्टर तैयार हो रहा है...',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Row(
                      children: [
                        // Save to Gallery
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _handleSaveToGallery,
                            icon: const Icon(Icons.download_rounded),
                            label: Text(
                              'गैलरी में सेव',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Share Poster
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: _handleSharePoster,
                            icon: const Icon(Icons.share_rounded),
                            label: Text(
                              'शेयर करें',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFF1B5E20), // Festive Green
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
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
}
