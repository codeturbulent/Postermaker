import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/poster_template.dart';
import '../providers/poster_provider.dart';
import '../utils/image_exporter.dart';
import '../utils/slogan_bank.dart';
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

  final List<String> _stickerBadges = const [
    '🪔', // Diya
    '🕉️', // Om
    '🌾', // Kisan / Wheat
    '🤝', // Namaste / Appeal
    '🇮🇳', // Tiranga
    '🗳️', // Vote / Ballot
    '🚩', // Dhwaja
    '🌺', // Kamal / Lotus
    '✨', // Star
    '🎉', // Celebration
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

  void _openSloganPickerModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return DefaultTabController(
          length: SloganBank.categories.length,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.65,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'सुझाव बैंक (Slogan Library)',
                      style: GoogleFonts.rozhaOne(fontSize: 18),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                TabBar(
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  labelColor: Theme.of(context).colorScheme.primary,
                  unselectedLabelColor: Colors.grey,
                  tabs: SloganBank.categories.map((c) {
                    return Tab(
                      child: Row(
                        children: [
                          Text(c.icon),
                          const SizedBox(width: 6),
                          Text(
                            c.title.split(' ').first,
                            style: GoogleFonts.poppins(fontSize: 13),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: TabBarView(
                    children: SloganBank.categories.map((cat) {
                      return ListView.separated(
                        itemCount: cat.slogans.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, idx) {
                          final slogan = cat.slogans[idx];
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            title: Text(
                              slogan,
                              style: GoogleFonts.gotu(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            trailing: const Icon(
                              Icons.touch_app_outlined,
                              size: 18,
                            ),
                            onTap: () {
                              final provider = context.read<PosterProvider>();
                              provider.setCustomGreeting(slogan);
                              _greetingController.text = slogan;
                              Navigator.pop(ctx);
                            },
                          );
                        },
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
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
                  // 1-Tap Aspect Ratio Selector (1:1 Post, 4:5 Banner, 9:16 WhatsApp Status)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: SegmentedButton<double>(
                      segments: const [
                        ButtonSegment(
                          value: 1.0,
                          label: Text('1:1 पोस्ट'),
                          icon: Icon(Icons.crop_square, size: 16),
                        ),
                        ButtonSegment(
                          value: 0.8,
                          label: Text('4:5 बैनर'),
                          icon: Icon(Icons.crop_portrait, size: 16),
                        ),
                        ButtonSegment(
                          value: 9 / 16,
                          label: Text('9:16 स्टेटस'),
                          icon: Icon(Icons.stay_current_portrait, size: 16),
                        ),
                      ],
                      selected: {provider.currentAspectRatio},
                      onSelectionChanged: (set) {
                        if (set.isNotEmpty) {
                          provider.setAspectRatio(set.first);
                        }
                      },
                    ),
                  ),

                  // 1. Live Interactive Canvas Preview
                  Center(
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: 420,
                        maxHeight: provider.currentAspectRatio < 0.65 ? 540 : 460,
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
                        aspectRatio: provider.currentAspectRatio,
                        showTopLeadersStrip: provider.showTopLeadersStrip,
                        badgeIcon: provider.selectedBadgeIcon,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // 2. Custom Greeting Editor on the fly + Slogan Bank 1-Tap Pick
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
                              Row(
                                children: [
                                  FilledButton.tonalIcon(
                                    onPressed: () =>
                                        _openSloganPickerModal(context),
                                    icon: const Icon(Icons.auto_stories, size: 14),
                                    label: Text(
                                      'सुझाव चुनें',
                                      style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    style: FilledButton.tonalStyleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  TextButton(
                                    onPressed: () {
                                      _greetingController.text = provider
                                          .selectedTemplate.defaultGreetingText;
                                      provider.setCustomGreeting(
                                        provider.selectedTemplate.defaultGreetingText,
                                      );
                                    },
                                    child: Text(
                                      'रीसेट',
                                      style: GoogleFonts.poppins(fontSize: 11),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
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

                  // 3. Auspicious Sticker & Badge Tray
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
                          Text(
                            'शुभ प्रतीक चिन्ह / स्टीकर (1-Tap Badges)',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 42,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: _stickerBadges.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: 8),
                              itemBuilder: (context, index) {
                                final badge = _stickerBadges[index];
                                final isSelected =
                                    provider.selectedBadgeIcon == badge;
                                return InkWell(
                                  onTap: () => provider.setBadgeIcon(
                                      isSelected ? null : badge),
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? theme.colorScheme.primaryContainer
                                          : Colors.grey.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: isSelected
                                            ? theme.colorScheme.primary
                                            : Colors.transparent,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        badge,
                                        style: const TextStyle(fontSize: 20),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 4. "Netaji / Senior Leaders" Top Photo Strip
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
                                'शीर्ष नेता / मार्गदर्शक फोटो (Top Leaders)',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Switch(
                                value: provider.showTopLeadersStrip,
                                onChanged: (val) {
                                  provider.toggleTopLeadersStrip();
                                },
                              ),
                            ],
                          ),
                          if (provider.showTopLeadersStrip) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                ...List.generate(
                                  provider.profile.topLeaderImagePaths.length,
                                  (index) {
                                    return Stack(
                                      children: [
                                        Container(
                                          margin:
                                              const EdgeInsets.only(right: 10),
                                          width: 44,
                                          height: 44,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: const Color(0xFFFFB300),
                                              width: 2,
                                            ),
                                          ),
                                          child: const CircleAvatar(
                                            backgroundColor: Color(0xFF37474F),
                                            child: Icon(Icons.person,
                                                color: Colors.white, size: 22),
                                          ),
                                        ),
                                        Positioned(
                                          top: -4,
                                          right: 6,
                                          child: InkWell(
                                            onTap: () => provider
                                                .removeTopLeaderPhoto(index),
                                            child: const CircleAvatar(
                                              radius: 9,
                                              backgroundColor: Colors.red,
                                              child: Icon(Icons.close,
                                                  size: 10, color: Colors.white),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                                if (provider.profile.topLeaderImagePaths.length < 4)
                                  InkWell(
                                    onTap: () => provider.addTopLeaderPhoto(),
                                    child: Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: theme.colorScheme.primary,
                                          width: 1.5,
                                        ),
                                        color: theme
                                            .colorScheme.primaryContainer
                                            .withOpacity(0.4),
                                      ),
                                      child: Icon(
                                        Icons.add_photo_alternate_outlined,
                                        size: 20,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 5. Customization Controls: Photo Alignment & Ribbon Color
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
                                    provider.ribbonColor.value == color.value;
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

                  // 6. Quick Template Switcher Horizontal Carousel
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
                              backgroundColor:
                                  const Color(0xFF1B5E20), // Festive Green
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
