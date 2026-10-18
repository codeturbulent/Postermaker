import 'package:flutter/material.dart';

enum TemplateCategory {
  festival('त्यौहार / Festival'),
  political('राजनीतिक / Political'),
  birthdays('जन्मदिन / Birthday'),
  quotes('सुविचार / Quotes');

  final String label;
  const TemplateCategory(this.label);
}

enum PhotoAlignment {
  left('बाएं (Left)'),
  right('दाएं (Right)');

  final String label;
  const PhotoAlignment(this.label);
}

class PosterTemplate {
  final String id;
  final String title;
  final TemplateCategory category;
  final String assetOrNetworkUrl;
  final double aspectRatio; // 1.0 (1:1 Square) or 0.8 (4:5 Portrait)
  final Color primaryColor;
  final Color secondaryColor;
  final Color accentColor;
  final List<Color> gradientColors;
  final PhotoAlignment photoAlignment;
  final String defaultGreetingText;
  final String subGreetingText;
  final String badgeText;

  const PosterTemplate({
    required this.id,
    required this.title,
    required this.category,
    required this.assetOrNetworkUrl,
    this.aspectRatio = 0.8,
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentColor,
    required this.gradientColors,
    required this.photoAlignment,
    required this.defaultGreetingText,
    required this.subGreetingText,
    required this.badgeText,
  });

  /// 5 Realistic, production-ready templates configured with resilient network imagery
  /// and rich fallback linear/radial gradients so the app works immediately out-of-the-box.
  static final List<PosterTemplate> dummyTemplates = [
    const PosterTemplate(
      id: 'tpl_diwali_gold',
      title: 'दीपावली महापर्व',
      category: TemplateCategory.festival,
      assetOrNetworkUrl:
          'https://images.unsplash.com/photo-1514565131-fce0801e5785?auto=format&fit=crop&w=1080&q=80',
      aspectRatio: 1.0, // 1:1 Square
      primaryColor: Color(0xFFD84315), // Deep Rust Orange
      secondaryColor: Color(0xFFFFB300), // Marigold Gold
      accentColor: Color(0xFFFFE082),
      gradientColors: [
        Color(0xFF3E2723), // Deep Maroon/Brown
        Color(0xFFB71C1C), // Rich Red
        Color(0xFFE65100), // Vibrant Saffron
        Color(0xFFFF8F00), // Golden Amber
      ],
      photoAlignment: PhotoAlignment.right,
      defaultGreetingText: 'दीपावली की हार्दिक शुभकामनाएं',
      subGreetingText: 'प्रकाश पर्व आपके जीवन में सुख, समृद्धि और आरोग्य लाए।',
      badgeText: 'शुभ दीपावली',
    ),
    const PosterTemplate(
      id: 'tpl_panchayat_election',
      title: 'विजयी भव: पंचायत चुनाव',
      category: TemplateCategory.political,
      assetOrNetworkUrl:
          'https://images.unsplash.com/photo-1540910419892-4a36d2c3266c?auto=format&fit=crop&w=1080&q=80',
      aspectRatio: 0.8, // 4:5 Portrait
      primaryColor: Color(0xFF1B5E20), // Rich Forest Green
      secondaryColor: Color(0xFFE65100), // Bharat Saffron
      accentColor: Color(0xFFFFF9C4),
      gradientColors: [
        Color(0xFF0D3312), // Dark Emerald
        Color(0xFF1B5E20), // Indian Green
        Color(0xFFE65100), // Indian Saffron
        Color(0xFFFF6F00), // Bright Orange
      ],
      photoAlignment: PhotoAlignment.left,
      defaultGreetingText: 'समस्त क्षेत्रवासियों को सादर प्रणाम',
      subGreetingText: 'विकास ही हमारा संकल्प, आपका विश्वास हमारी ताकत।',
      badgeText: 'पंचायत चुनाव 2026',
    ),
    const PosterTemplate(
      id: 'tpl_samajwadi_kranti',
      title: 'युवा नेता - समाजवादी क्रांति',
      category: TemplateCategory.political,
      assetOrNetworkUrl:
          'https://images.unsplash.com/photo-1529107386315-e1a2ed48a620?auto=format&fit=crop&w=1080&q=80',
      aspectRatio: 0.8, // 4:5 Portrait
      primaryColor: Color(0xFFC62828), // Samajwadi Red
      secondaryColor: Color(0xFF2E7D32), // Samajwadi Green
      accentColor: Color(0xFFFFFFFF),
      gradientColors: [
        Color(0xFF5A0000), // Deep Crimson
        Color(0xFFB71C1C), // Bright Red
        Color(0xFF1B5E20), // Deep Green
        Color(0xFF003300), // Dark Green
      ],
      photoAlignment: PhotoAlignment.right,
      defaultGreetingText: 'सामाजिक न्याय एवं समरसता',
      subGreetingText: 'युवाओं का जोश, किसानों का सम्मान, सर्वजन हिताय संकल्प।',
      badgeText: 'क्रांति दिवस विशेष',
    ),
    const PosterTemplate(
      id: 'tpl_rashtra_pratham_bjp',
      title: 'राष्ट्र प्रथम - विकास पर्व',
      category: TemplateCategory.political,
      assetOrNetworkUrl:
          'https://images.unsplash.com/photo-1532375810709-75b1da00537c?auto=format&fit=crop&w=1080&q=80',
      aspectRatio: 1.0, // 1:1 Square
      primaryColor: Color(0xFFFF6D00), // Pure Kesariya / Saffron
      secondaryColor: Color(0xFF0D47A1), // Deep Navy Blue
      accentColor: Color(0xFFFFD54F),
      gradientColors: [
        Color(0xFFBF360C), // Deep Burnt Saffron
        Color(0xFFE65100), // Vibrant Saffron
        Color(0xFFFFA000), // Golden Yellow
        Color(0xFF0D47A1), // Bottom Blue Accent
      ],
      photoAlignment: PhotoAlignment.left,
      defaultGreetingText: 'सबका साथ, सबका विकास, सबका विश्वास',
      subGreetingText: 'राष्ट्र नवनिर्माण में हम सबका एक कदम।',
      badgeText: 'राष्ट्र प्रथम',
    ),
    const PosterTemplate(
      id: 'tpl_birthday_felicitation',
      title: 'जन्मदिन की अनंत बधाई',
      category: TemplateCategory.birthdays,
      assetOrNetworkUrl:
          'https://images.unsplash.com/photo-1513151233558-d860c5398176?auto=format&fit=crop&w=1080&q=80',
      aspectRatio: 0.8, // 4:5 Portrait
      primaryColor: Color(0xFF4A148C), // Royal Purple / Gold
      secondaryColor: Color(0xFFFFB300), // Amber Gold
      accentColor: Color(0xFFFFD54F),
      gradientColors: [
        Color(0xFF311B92), // Deep Violet
        Color(0xFF4A148C), // Royal Purple
        Color(0xFF880E4F), // Rich Burgundy
        Color(0xFFFF6F00), // Gold/Amber rim
      ],
      photoAlignment: PhotoAlignment.right,
      defaultGreetingText: 'जन्मदिन की हार्दिक बधाई एवं शुभकामनाएं',
      subGreetingText: 'ईश्वर आपको दीर्घायु, उत्तम स्वास्थ्य और अपार यश प्रदान करें।',
      badgeText: 'दीर्घायु भव:',
    ),
  ];
}
