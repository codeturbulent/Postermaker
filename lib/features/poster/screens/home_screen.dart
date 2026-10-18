import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/poster_template.dart';
import '../models/upcoming_occasion.dart';
import '../providers/poster_provider.dart';
import 'poster_editor_screen.dart';
import 'package:poster_maker/features/profile/screens/profile_edit_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _showProfileSwitcherSheet(BuildContext context, PosterProvider provider) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'प्रोफ़ाइल चुनें (Switch Profile)',
                      style: GoogleFonts.rozhaOne(fontSize: 18),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                Text(
                  'परिवार या अलग-अलग नेताओं के लिए प्रोफ़ाइल बदलें',
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: provider.allProfiles.length,
                    itemBuilder: (context, idx) {
                      final p = provider.allProfiles[idx];
                      final isSelected = idx == provider.activeProfileIndex;

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFFD84315),
                          backgroundImage: p.profileImagePath != null &&
                                  File(p.profileImagePath!).existsSync()
                              ? FileImage(File(p.profileImagePath!))
                              : null,
                          child: p.profileImagePath == null
                              ? const Icon(Icons.person, color: Colors.white)
                              : null,
                        ),
                        title: Text(
                          p.fullName.isNotEmpty ? p.fullName : 'अनाम सदस्य',
                          style: GoogleFonts.poppins(
                            fontWeight:
                                isSelected ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                          p.designation.isNotEmpty ? p.designation : 'पदनाम',
                          style: GoogleFonts.poppins(fontSize: 12),
                        ),
                        trailing: isSelected
                            ? const Icon(Icons.check_circle,
                                color: Color(0xFF1B5E20))
                            : (provider.allProfiles.length > 1
                                ? IconButton(
                                    icon: const Icon(Icons.delete_outline,
                                        size: 18, color: Colors.red),
                                    onPressed: () {
                                      provider.deleteProfile(idx);
                                      Navigator.pop(ctx);
                                    },
                                  )
                                : null),
                        onTap: () {
                          provider.switchProfile(idx);
                          Navigator.pop(ctx);
                        },
                      );
                    },
                  ),
                ),
                const Divider(),
                if (provider.allProfiles.length < 5)
                  ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFEEEEEE),
                      child: Icon(Icons.add, color: Color(0xFFD84315)),
                    ),
                    title: Text(
                      '+ नई प्रोफ़ाइल जोड़ें (Add New Profile)',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFD84315),
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(ctx);
                      provider.addNewProfile();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const ProfileEditScreen(),
                        ),
                      );
                    },
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
    final provider = context.watch<PosterProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6.0),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.palette_rounded,
                color: theme.colorScheme.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'देसी पोस्टर मेकर',
              style: GoogleFonts.rozhaOne(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          // Multi-Profile Switcher Chip
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: InkWell(
              borderRadius: BorderRadius.circular(24.0),
              onTap: () => _showProfileSwitcherSheet(context, provider),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10.0,
                  vertical: 4.0,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(20.0),
                  border: Border.all(
                    color: theme.colorScheme.outlineVariant,
                    width: 1.0,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildAppBarAvatar(provider),
                    const SizedBox(width: 6),
                    Text(
                      provider.profile.fullName.isNotEmpty
                          ? provider.profile.fullName.split(' ').first
                          : 'प्रोफ़ाइल',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_drop_down, size: 18),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. "Upcoming Occasions" Smart Calendar Highlight Banner
                _buildUpcomingOccasionBanner(context, provider),

                // 2. Category Filter Chips Carousel
                _buildCategoryFilters(context, provider),

                // Active category title and count
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        provider.selectedCategoryFilter == null
                            ? 'सभी पोस्टर टेम्पलेट्स'
                            : provider.selectedCategoryFilter!.label,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '${provider.filteredTemplates.length} उपलब्ध',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),

                // 3. 2-Column GridView of Templates
                Expanded(
                  child: provider.filteredTemplates.isEmpty
                      ? _buildEmptyState(context)
                      : GridView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14.0,
                            vertical: 8.0,
                          ),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.68,
                            crossAxisSpacing: 12.0,
                            mainAxisSpacing: 14.0,
                          ),
                          itemCount: provider.filteredTemplates.length,
                          itemBuilder: (context, index) {
                            final template = provider.filteredTemplates[index];
                            return _buildTemplateCard(
                                context, template, provider);
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const ProfileEditScreen(),
            ),
          );
        },
        icon: const Icon(Icons.person_outline),
        label: Text(
          'प्रोफ़ाइल सेटिंग्स',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildAppBarAvatar(PosterProvider provider) {
    if (provider.profile.profileImagePath != null &&
        provider.profile.profileImagePath!.isNotEmpty) {
      final file = File(provider.profile.profileImagePath!);
      if (file.existsSync()) {
        return CircleAvatar(
          radius: 14,
          backgroundImage: FileImage(file),
        );
      }
    }
    return const CircleAvatar(
      radius: 14,
      backgroundColor: Color(0xFFD84315),
      child: Icon(Icons.person, size: 16, color: Colors.white),
    );
  }

  /// "Upcoming Occasions" Smart Calendar Highlight Banner
  Widget _buildUpcomingOccasionBanner(
      BuildContext context, PosterProvider provider) {
    final occasion = UpcomingOccasion.occasions.first;

    return Container(
      margin: const EdgeInsets.fromLTRB(14, 8, 14, 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFBF360C), Color(0xFFD84315), Color(0xFFF57C00)],
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Text(
              occasion.icon,
              style: const TextStyle(fontSize: 24),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        occasion.badgeText,
                        style: GoogleFonts.poppins(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFFD84315),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      occasion.dateText,
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  occasion.title,
                  style: GoogleFonts.rozhaOne(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  occasion.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.gotu(
                    fontSize: 11,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          FilledButton.tonal(
            onPressed: () {
              provider.setCategoryFilter(occasion.category);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFFD84315),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            ),
            child: Text(
              'बनाएं',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilters(BuildContext context, PosterProvider provider) {
    final theme = Theme.of(context);

    return Container(
      height: 52,
      margin: const EdgeInsets.only(top: 4.0),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        children: [
          // "All" filter chip
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: FilterChip(
              label: Text(
                'सभी (All)',
                style: GoogleFonts.poppins(
                  fontWeight: provider.selectedCategoryFilter == null
                      ? FontWeight.w700
                      : FontWeight.w500,
                ),
              ),
              selected: provider.selectedCategoryFilter == null,
              onSelected: (selected) {
                if (selected) {
                  provider.setCategoryFilter(null);
                }
              },
              selectedColor: theme.colorScheme.primaryContainer,
              checkmarkColor: theme.colorScheme.primary,
            ),
          ),
          // Specific categories
          ...TemplateCategory.values.map((category) {
            final isSelected = provider.selectedCategoryFilter == category;
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: FilterChip(
                label: Text(
                  category.label,
                  style: GoogleFonts.poppins(
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
                selected: isSelected,
                onSelected: (selected) {
                  provider.setCategoryFilter(selected ? category : null);
                },
                selectedColor: theme.colorScheme.primaryContainer,
                checkmarkColor: theme.colorScheme.primary,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTemplateCard(
    BuildContext context,
    PosterTemplate template,
    PosterProvider provider,
  ) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2.0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withOpacity(0.5),
        ),
      ),
      child: InkWell(
        onTap: () {
          provider.selectTemplate(template);
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const PosterEditorScreen(),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Thumbnail preview with aspect ratio badge
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: template.gradientColors,
                      ),
                    ),
                    child: Image.network(
                      template.assetOrNetworkUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: template.gradientColors,
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.brush_rounded,
                              size: 36,
                              color: template.accentColor.withOpacity(0.8),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Aspect Ratio Tag
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.65),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        template.aspectRatio == 1.0 ? '1:1 Square' : '4:5 Banner',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  // Greeting text preview banner
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.85),
                          ],
                        ),
                      ),
                      child: Text(
                        template.defaultGreetingText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.rozhaOne(
                          color: template.accentColor,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Card Bottom info
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    template.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        template.badgeText,
                        style: GoogleFonts.gotu(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 12,
                        color: theme.colorScheme.outline,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.category_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 12),
          Text(
            'इस श्रेणी में कोई टेम्पलेट नहीं मिला',
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
