import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/poster_template.dart';
import '../models/user_profile.dart';
import 'stroked_text.dart';

/// The central visual compositor widget for the poster maker application.
///
/// Encapsulated inside an [AspectRatio] and [LayoutBuilder] so that all visual elements,
/// font sizes, ribbons, and photo frames scale proportionally and identically across
/// preview devices and high-definition raster exports (1080x1080 / 1080x1350).
class PosterCanvas extends StatelessWidget {
  final GlobalKey repaintKey;
  final PosterTemplate template;
  final UserProfile profile;
  final String greetingText;
  final PhotoAlignment photoAlignment;
  final Color ribbonColor;

  const PosterCanvas({
    super.key,
    required this.repaintKey,
    required this.template,
    required this.profile,
    required this.greetingText,
    required this.photoAlignment,
    required this.ribbonColor,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: template.aspectRatio,
      child: RepaintBoundary(
        key: repaintKey,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final h = constraints.maxHeight;

            return ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: Stack(
                children: [
                  // -----------------------------------------------------------
                  // LAYER 1: BASE BACKGROUND + GRADIENT VIGNETTE
                  // -----------------------------------------------------------
                  Positioned.fill(
                    child: _buildBackground(w, h),
                  ),

                  // Dark bottom-to-top vignette to ensure high legibility of footer
                  Positioned.fill(
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: [0.0, 0.45, 0.75, 1.0],
                          colors: [
                            Colors.transparent,
                            Color(0x22000000),
                            Color(0x99000000),
                            Color(0xE6000000),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // -----------------------------------------------------------
                  // LAYER 2: TOP HEADER & EMBLEM / CATEGORY BADGE
                  // -----------------------------------------------------------
                  Positioned(
                    top: h * 0.03,
                    left: w * 0.04,
                    right: w * 0.04,
                    child: _buildHeaderRibbon(w, h),
                  ),

                  // -----------------------------------------------------------
                  // LAYER 3: STROKED HINDI GREETING & SUB-GREETING
                  // -----------------------------------------------------------
                  Positioned(
                    top: h * 0.13,
                    left: w * 0.05,
                    right: w * 0.05,
                    child: _buildGreetingSection(w, h),
                  ),

                  // -----------------------------------------------------------
                  // LAYER 4: USER CUTOUT / PHOTO FRAME LAYER
                  // -----------------------------------------------------------
                  _buildUserPhotoFrame(w, h),

                  // -----------------------------------------------------------
                  // LAYER 5, 6, 7: FOOTER NAMEPLATE, DESIGNATION & CONTACT STRIP
                  // -----------------------------------------------------------
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: _buildFooterRibbon(w, h),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// Builds the multi-stage background with network image and resilient fallback gradient.
  Widget _buildBackground(double w, double h) {
    return Container(
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
        width: w,
        height: h,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
              color: template.secondaryColor,
              strokeWidth: 2.0,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          // Graceful decorative pattern fallback when network is unavailable
          return CustomPaint(
            painter: _DecorativePosterBackdropPainter(
              primaryColor: template.primaryColor,
              secondaryColor: template.secondaryColor,
            ),
            size: Size(w, h),
          );
        },
      ),
    );
  }

  /// Top header with decorative badge, emblem, and festival tag
  Widget _buildHeaderRibbon(double w, double h) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Left: Party/Organization Emblem or Auspicious Symbol
        Container(
          width: w * 0.14,
          height: w * 0.14,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: template.secondaryColor,
              width: 2.5,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x66000000),
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: ClipOval(
            child: _buildEmblemContent(),
          ),
        ),

        // Center/Right: Category / Auspicious Tag Pill
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: w * 0.04,
            vertical: h * 0.008,
          ),
          decoration: BoxDecoration(
            color: template.primaryColor.withOpacity(0.95),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: template.accentColor,
              width: 1.5,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x55000000),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.star,
                color: template.accentColor,
                size: w * 0.04,
              ),
              SizedBox(width: w * 0.015),
              Text(
                template.badgeText,
                style: GoogleFonts.rozhaOne(
                  fontSize: w * 0.038,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmblemContent() {
    if (profile.partyOrSymbolImagePath != null &&
        profile.partyOrSymbolImagePath!.isNotEmpty) {
      final file = File(profile.partyOrSymbolImagePath!);
      if (file.existsSync()) {
        return Image.file(file, fit: BoxFit.cover);
      }
    }
    // Fallback authentic Indian symbol icon (Om / Lotus / Torch silhouette)
    return Center(
      child: Icon(
        Icons.wb_sunny_rounded,
        color: template.primaryColor,
        size: 26,
      ),
    );
  }

  /// Headline stroked Hindi typography and subtitle
  Widget _buildGreetingSection(double w, double h) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: StrokedText(
            greetingText.trim().isNotEmpty
                ? greetingText
                : template.defaultGreetingText,
            fontSize: w * 0.078,
            fillColor: template.accentColor,
            strokeColor: const Color(0xFF1B0000),
            strokeWidth: 4.5,
            fontFamily: 'Yatra One',
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(height: h * 0.008),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: w * 0.03,
            vertical: h * 0.004,
          ),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.55),
            borderRadius: BorderRadius.circular(6.0),
          ),
          child: Text(
            template.subGreetingText,
            textAlign: TextAlign.center,
            style: GoogleFonts.gotu(
              fontSize: w * 0.032,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ],
    );
  }

  /// User Cutout / Photo frame positioned above the bottom ribbon
  Widget _buildUserPhotoFrame(double w, double h) {
    final isLeft = photoAlignment == PhotoAlignment.left;
    final frameSize = w * 0.42;

    return Positioned(
      bottom: h * 0.175,
      left: isLeft ? w * 0.04 : null,
      right: !isLeft ? w * 0.04 : null,
      child: Container(
        width: frameSize,
        height: frameSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              template.secondaryColor,
              template.accentColor,
              template.primaryColor,
            ],
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x99000000),
              blurRadius: 10,
              spreadRadius: 2,
              offset: Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(4.0),
        child: Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFF263238),
          ),
          child: ClipOval(
            child: _buildUserAvatarContent(frameSize),
          ),
        ),
      ),
    );
  }

  Widget _buildUserAvatarContent(double size) {
    if (profile.profileImagePath != null &&
        profile.profileImagePath!.isNotEmpty) {
      final file = File(profile.profileImagePath!);
      if (file.existsSync()) {
        return Image.file(
          file,
          fit: BoxFit.cover,
          width: size,
          height: size,
        );
      }
    }

    // High quality leader cutout fallback placeholder
    final initials = profile.fullName.trim().isNotEmpty
        ? profile.fullName.trim().substring(0, 1)
        : 'न';

    return Container(
      color: const Color(0xFF37474F),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              initials,
              style: GoogleFonts.yatraOne(
                fontSize: size * 0.35,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'फ़ोटो जोड़ें',
              style: GoogleFonts.poppins(
                fontSize: size * 0.1,
                color: Colors.white70,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// High-contrast angled footer banner containing Name, Designation, and Contact details
  Widget _buildFooterRibbon(double w, double h) {
    final effectiveName = profile.fullName.trim().isNotEmpty
        ? profile.fullName
        : 'आपका नाम (यहाँ सेट करें)';
    final effectiveDesignation = profile.designation.trim().isNotEmpty
        ? profile.designation
        : 'ग्राम प्रधान / पदनाम';
    final effectiveTagline = profile.tagline.trim().isNotEmpty
        ? profile.tagline
        : 'आपकी सेवा में सदैव तत्पर';
    final effectivePhone = profile.phoneNumber.trim().isNotEmpty
        ? profile.phoneNumber
        : '+91 98765 43210';
    final effectiveSocial = profile.socialHandle.trim().isNotEmpty
        ? profile.socialHandle
        : '@YourSocialID';

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Upper Ribbon: Candidate Name & Designation Badge
        Container(
          margin: EdgeInsets.symmetric(horizontal: w * 0.02),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                ribbonColor,
                ribbonColor.withValues(alpha: 0.9),
                template.primaryColor,
              ],
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16.0),
              topRight: Radius.circular(16.0),
            ),
            border: Border.all(
              color: template.secondaryColor,
              width: 2.0,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x88000000),
                blurRadius: 8,
                offset: Offset(0, -2),
              ),
            ],
          ),
          padding: EdgeInsets.symmetric(
            horizontal: w * 0.04,
            vertical: h * 0.012,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: photoAlignment == PhotoAlignment.left
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              // 1. Full Name in bold stroked Indian typography
              FittedBox(
                fit: BoxFit.scaleDown,
                child: StrokedText(
                  effectiveName,
                  fontSize: w * 0.065,
                  fillColor: Colors.white,
                  strokeColor: const Color(0xFF212121),
                  strokeWidth: 3.5,
                  fontFamily: 'Rozha One',
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: h * 0.004),

              // 2. Designation pill banner
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: w * 0.03,
                  vertical: h * 0.004,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x33000000),
                      blurRadius: 3,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    effectiveDesignation,
                    style: GoogleFonts.poppins(
                      fontSize: w * 0.034,
                      fontWeight: FontWeight.w800,
                      color: ribbonColor,
                    ),
                  ),
                ),
              ),
              SizedBox(height: h * 0.003),

              // 3. Tagline
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  effectiveTagline,
                  style: GoogleFonts.gotu(
                    fontSize: w * 0.028,
                    fontWeight: FontWeight.w600,
                    color: template.accentColor,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Bottom Strip: Direct Phone/WhatsApp & Social Handle
        Container(
          color: const Color(0xFF121212),
          padding: EdgeInsets.symmetric(
            horizontal: w * 0.04,
            vertical: h * 0.008,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Phone & WhatsApp strip
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(3.0),
                    decoration: const BoxDecoration(
                      color: Color(0xFF25D366), // WhatsApp Green
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.phone,
                      color: Colors.white,
                      size: w * 0.032,
                    ),
                  ),
                  SizedBox(width: w * 0.015),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      effectivePhone,
                      style: GoogleFonts.poppins(
                        fontSize: w * 0.03,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),

              // Social Handle
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.alternate_email,
                    color: template.secondaryColor,
                    size: w * 0.032,
                  ),
                  SizedBox(width: w * 0.01),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      effectiveSocial,
                      style: GoogleFonts.poppins(
                        fontSize: w * 0.03,
                        fontWeight: FontWeight.w600,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Fallback decorative painter that generates authentic Indian festival/political sunburst
/// background patterns in case of zero internet connectivity.
class _DecorativePosterBackdropPainter extends CustomPainter {
  final Color primaryColor;
  final Color secondaryColor;

  _DecorativePosterBackdropPainter({
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = RadialGradient(
        center: Alignment.topCenter,
        radius: 1.2,
        colors: [
          secondaryColor.withValues(alpha: 0.8),
          primaryColor,
          const Color(0xFF101010),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Decorative rays
    final rayPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, 0);
    const count = 16;
    for (int i = 0; i < count; i += 2) {
      final path = Path();
      path.moveTo(center.dx, center.dy);
      path.lineTo((size.width / count) * i, size.height);
      path.lineTo((size.width / count) * (i + 1), size.height);
      path.close();
      canvas.drawPath(path, rayPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _DecorativePosterBackdropPainter oldDelegate) {
    return oldDelegate.primaryColor != primaryColor ||
        oldDelegate.secondaryColor != secondaryColor;
  }
}
