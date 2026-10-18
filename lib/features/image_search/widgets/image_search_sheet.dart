import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/image_search_result.dart';
import '../services/image_search_service.dart';

/// Modal bottom sheet allowing users to search Google / Wikimedia / Curated images
/// and add them either as poster background or as movable canvas sticker layers.
class ImageSearchSheet extends StatefulWidget {
  final Function(String imageUrl) onSelectAsBackground;
  final Function(String imageUrl, bool isSticker) onAddAsCanvasLayer;

  const ImageSearchSheet({
    super.key,
    required this.onSelectAsBackground,
    required this.onAddAsCanvasLayer,
  });

  static Future<void> show({
    required BuildContext context,
    required Function(String imageUrl) onSelectAsBackground,
    required Function(String imageUrl, bool isSticker) onAddAsCanvasLayer,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => ImageSearchSheet(
        onSelectAsBackground: onSelectAsBackground,
        onAddAsCanvasLayer: onAddAsCanvasLayer,
      ),
    );
  }

  @override
  State<ImageSearchSheet> createState() => _ImageSearchSheetState();
}

class _ImageSearchSheetState extends State<ImageSearchSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<ImageSearchResult> _results = [];
  bool _isLoading = false;
  int _selectedFilterIndex = 0; // 0 = All, 1 = Backgrounds, 2 = Stickers

  @override
  void initState() {
    super.initState();
    _performSearch('');
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    setState(() => _isLoading = true);
    try {
      final results = await ImageSearchService.searchImages(
        query: query,
        stickersOnly: _selectedFilterIndex == 2,
      );
      if (mounted) {
        setState(() {
          _results = results;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showImageOptionsModal(ImageSearchResult image) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    image.thumbnailUrl,
                    height: 140,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 140,
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: const Icon(Icons.broken_image, size: 40),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  image.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'स्रोत: ${image.source}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.pop(context);
                    widget.onSelectAsBackground(image.fullUrl);
                  },
                  icon: const Icon(Icons.wallpaper_rounded),
                  label: Text(
                    'पोस्टर बैकग्राउंड बनाएं (Set as Background)',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                FilledButton.tonalIcon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.pop(context);
                    widget.onAddAsCanvasLayer(
                      image.fullUrl,
                      image.isTransparentSticker,
                    );
                  },
                  icon: const Icon(Icons.layers_outlined),
                  label: Text(
                    'कैनवास पर स्टीकर/लेयर जोड़ें (Add as Layer)',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);

    return Container(
      height: mediaQuery.size.height * 0.85,
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        children: [
          // Drag handle bar
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
          const SizedBox(height: 12),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.image_search_rounded,
                        color: theme.colorScheme.primary, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      'इमेज व स्टीकर खोजें (Search Images)',
                      style: GoogleFonts.rozhaOne(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Search text field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'उदा: दिवाली, तिरंगा, चुनाव, बैकग्राउंड...',
                hintStyle: GoogleFonts.poppins(fontSize: 13),
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          _performSearch('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              textInputAction: TextInputAction.search,
              onSubmitted: (query) => _performSearch(query),
              onChanged: (text) => setState(() {}),
            ),
          ),
          const SizedBox(height: 10),

          // Suggestion chips
          SizedBox(
            height: 36,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: ImageSearchService.popularSuggestions.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, idx) {
                final suggestion = ImageSearchService.popularSuggestions[idx];
                final cleanText = suggestion.split(' ').first;
                return ActionChip(
                  label: Text(
                    suggestion,
                    style: GoogleFonts.poppins(fontSize: 12),
                  ),
                  onPressed: () {
                    _searchController.text = cleanText;
                    _performSearch(cleanText);
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  backgroundColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.6),
                );
              },
            ),
          ),
          const SizedBox(height: 10),

          // Category filter segmented button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SegmentedButton<int>(
              segments: const [
                ButtonSegment(
                  value: 0,
                  label: Text('सभी (All)'),
                  icon: Icon(Icons.grid_view_rounded, size: 16),
                ),
                ButtonSegment(
                  value: 1,
                  label: Text('पृष्ठभूमि (Backdrops)'),
                  icon: Icon(Icons.wallpaper_rounded, size: 16),
                ),
                ButtonSegment(
                  value: 2,
                  label: Text('स्टीकर्स (Stickers)'),
                  icon: Icon(Icons.auto_awesome, size: 16),
                ),
              ],
              selected: {_selectedFilterIndex},
              onSelectionChanged: (set) {
                if (set.isNotEmpty) {
                  setState(() => _selectedFilterIndex = set.first);
                  _performSearch(_searchController.text);
                }
              },
            ),
          ),
          const SizedBox(height: 12),

          // Results Grid
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _results.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off_rounded,
                                size: 54, color: theme.colorScheme.outline),
                            const SizedBox(height: 12),
                            Text(
                              'कोई परिणाम नहीं मिला',
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.85,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: _results.length,
                        itemBuilder: (context, index) {
                          final item = _results[index];
                          return InkWell(
                            onTap: () => _showImageOptionsModal(item),
                            borderRadius: BorderRadius.circular(16),
                            child: Card(
                              elevation: 1.5,
                              clipBehavior: Clip.antiAlias,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(
                                  color: theme.colorScheme.outlineVariant
                                      .withOpacity(0.5),
                                ),
                              ),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  Image.network(
                                    item.thumbnailUrl,
                                    fit: BoxFit.cover,
                                    loadingBuilder:
                                        (ctx, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Container(
                                        color: theme.colorScheme
                                            .surfaceContainerHighest,
                                        child: const Center(
                                          child: SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                    errorBuilder: (ctx, _, __) {
                                      return Container(
                                        color: theme.colorScheme
                                            .surfaceContainerHighest,
                                        child: const Icon(
                                          Icons.broken_image_rounded,
                                          size: 32,
                                        ),
                                      );
                                    },
                                  ),
                                  // Bottom gradient with title
                                  Positioned(
                                    bottom: 0,
                                    left: 0,
                                    right: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.transparent,
                                            Colors.black.withOpacity(0.8),
                                          ],
                                        ),
                                      ),
                                      child: Text(
                                        item.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.poppins(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Sticker badge pill
                                  if (item.isTransparentSticker)
                                    Positioned(
                                      top: 8,
                                      left: 8,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.65),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          'स्टीकर',
                                          style: GoogleFonts.poppins(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
