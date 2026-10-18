import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:poster_maker/core/widgets/stroked_text.dart';
import 'package:poster_maker/features/poster/providers/poster_provider.dart';
import '../models/user_profile.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _designationController;
  late TextEditingController _taglineController;
  late TextEditingController _phoneController;
  late TextEditingController _socialController;

  @override
  void initState() {
    super.initState();
    final profile = context.read<PosterProvider>().profile;
    _nameController = TextEditingController(text: profile.fullName);
    _designationController = TextEditingController(text: profile.designation);
    _taglineController = TextEditingController(text: profile.tagline);
    _phoneController = TextEditingController(text: profile.phoneNumber);
    _socialController = TextEditingController(text: profile.socialHandle);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _designationController.dispose();
    _taglineController.dispose();
    _phoneController.dispose();
    _socialController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<PosterProvider>();
    final updatedProfile = provider.profile.copyWith(
      fullName: _nameController.text.trim(),
      designation: _designationController.text.trim(),
      tagline: _taglineController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      socialHandle: _socialController.text.trim(),
    );

    await provider.updateProfile(updatedProfile);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'आपकी प्रोफ़ाइल सफलतापूर्वक सहेज ली गई है!',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          backgroundColor: const Color(0xFF1B5E20),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<PosterProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'मेरी प्रोफ़ाइल / फ़ोटो',
          style: GoogleFonts.rozhaOne(fontSize: 20),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            children: [
              // 1. Live Nameplate Preview Header Card
              _buildLivePreviewCard(context, provider),
              const SizedBox(height: 20),

              // 2. Photo & Symbol Upload Section
              Text(
                'फ़ोटो और चुनाव/संस्था प्रतीक चिन्ह',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 12),
              _buildImagePickerRow(context, provider),
              const SizedBox(height: 24),

              // 3. Text Form Fields
              Text(
                'व्यक्तिगत एवं पद विवरण',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 12),

              // Full Name
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'पूरा नाम (Full Name) *',
                  hintText: 'उदा: राजेश कुमार यादव',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                style: GoogleFonts.poppins(),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'कृपया अपना पूरा नाम दर्ज करें';
                  }
                  return null;
                },
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 14),

              // Designation
              TextFormField(
                controller: _designationController,
                decoration: InputDecoration(
                  labelText: 'पद / दायित्व (Designation / Role) *',
                  hintText: 'उदा: ग्राम प्रधान - बलीपुर / जिला अध्यक्ष',
                  prefixIcon: const Icon(Icons.badge_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                style: GoogleFonts.poppins(),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'कृपया अपना पद अथवा दायित्व दर्ज करें';
                  }
                  return null;
                },
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 14),

              // Tagline
              TextFormField(
                controller: _taglineController,
                decoration: InputDecoration(
                  labelText: 'नारा / स्लोगन (Tagline / Slogan)',
                  hintText: 'उदा: आपकी सेवा में सदैव तत्पर',
                  prefixIcon: const Icon(Icons.format_quote_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                style: GoogleFonts.poppins(),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 14),

              // Phone Number
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'मोबाइल / व्हाट्सएप नंबर (Phone / WhatsApp)',
                  hintText: 'उदा: +91 98765 43210',
                  prefixIcon: const Icon(Icons.phone_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                style: GoogleFonts.poppins(),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 14),

              // Social Handle
              TextFormField(
                controller: _socialController,
                decoration: InputDecoration(
                  labelText: 'सोशल मीडिया आईडी (Social Handle)',
                  hintText: 'उदा: @RajeshYadavOfficial',
                  prefixIcon: const Icon(Icons.alternate_email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                style: GoogleFonts.poppins(),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 28),

              // Save Button
              FilledButton.icon(
                onPressed: _handleSave,
                icon: const Icon(Icons.check_circle_outline),
                label: Text(
                  'प्रोफ़ाइल सहेजें (Save Profile)',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  /// Live preview card demonstrating what the nameplate ribbon will look like on posters
  Widget _buildLivePreviewCard(BuildContext context, PosterProvider provider) {
    final displayName = _nameController.text.trim().isNotEmpty
        ? _nameController.text.trim()
        : (provider.profile.fullName.isNotEmpty
            ? provider.profile.fullName
            : 'आपका नाम');

    final displayDesignation = _designationController.text.trim().isNotEmpty
        ? _designationController.text.trim()
        : (provider.profile.designation.isNotEmpty
            ? provider.profile.designation
            : 'पद / दायित्व');

    final displayPhone = _phoneController.text.trim().isNotEmpty
        ? _phoneController.text.trim()
        : (provider.profile.phoneNumber.isNotEmpty
            ? provider.profile.phoneNumber
            : '+91 98765 43210');

    return Card(
      elevation: 3.0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFD84315), Color(0xFFE65100), Color(0xFFF57C00)],
          ),
        ),
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.visibility_outlined,
                    color: Colors.white70, size: 16),
                const SizedBox(width: 6),
                Text(
                  'लाइव नेमप्लेट पूर्वावलोकन (Live Ribbon Preview)',
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            StrokedText(
              displayName,
              fontSize: 22,
              fillColor: Colors.white,
              strokeColor: const Color(0xFF1E1E1E),
              strokeWidth: 3.5,
              fontFamily: 'Rozha One',
              textAlign: TextAlign.start,
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                displayDesignation,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFD84315),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.phone, color: Colors.white, size: 14),
                const SizedBox(width: 4),
                Text(
                  displayPhone,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Photo and Symbol Picker Tiles
  Widget _buildImagePickerRow(BuildContext context, PosterProvider provider) {
    return Row(
      children: [
        // 1. User Profile Photo Picker
        Expanded(
          child: Card(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  Text(
                    'आपकी फ़ोटो',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  CircleAvatar(
                    radius: 38,
                    backgroundColor: const Color(0xFFEEEEEE),
                    backgroundImage: provider.profile.profileImagePath != null &&
                            File(provider.profile.profileImagePath!).existsSync()
                        ? FileImage(File(provider.profile.profileImagePath!))
                        : null,
                    child: provider.profile.profileImagePath == null ||
                            !File(provider.profile.profileImagePath!).existsSync()
                        ? const Icon(Icons.person, size: 40, color: Colors.grey)
                        : null,
                  ),
                  const SizedBox(height: 10),
                  FilledButton.tonal(
                    onPressed: () async {
                      await provider.pickAndCropProfileImage();
                    },
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                    ),
                    child: Text(
                      provider.profile.profileImagePath == null
                          ? 'फ़ोटो चुनें'
                          : 'फ़ोटो बदलें',
                      style: GoogleFonts.poppins(fontSize: 12),
                    ),
                  ),
                  if (provider.profile.profileImagePath != null)
                    TextButton(
                      onPressed: () async {
                        await provider.clearProfileImage();
                      },
                      child: Text(
                        'हटाएं',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.red,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // 2. Party / Election Symbol Picker
        Expanded(
          child: Card(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  Text(
                    'प्रतीक चिन्ह / लोगो',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  CircleAvatar(
                    radius: 38,
                    backgroundColor: const Color(0xFFEEEEEE),
                    backgroundImage: provider.profile.partyOrSymbolImagePath !=
                                null &&
                            File(provider.profile.partyOrSymbolImagePath!)
                                .existsSync()
                        ? FileImage(
                            File(provider.profile.partyOrSymbolImagePath!))
                        : null,
                    child: provider.profile.partyOrSymbolImagePath == null ||
                            !File(provider.profile.partyOrSymbolImagePath!)
                                .existsSync()
                        ? const Icon(Icons.wb_sunny_outlined,
                            size: 40, color: Colors.grey)
                        : null,
                  ),
                  const SizedBox(height: 10),
                  FilledButton.tonal(
                    onPressed: () async {
                      await provider.pickAndCropPartySymbolImage();
                    },
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                    ),
                    child: Text(
                      provider.profile.partyOrSymbolImagePath == null
                          ? 'चिन्ह चुनें'
                          : 'चिन्ह बदलें',
                      style: GoogleFonts.poppins(fontSize: 12),
                    ),
                  ),
                  if (provider.profile.partyOrSymbolImagePath != null)
                    TextButton(
                      onPressed: () async {
                        await provider.clearPartySymbolImage();
                      },
                      child: Text(
                        'हटाएं',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.red,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
