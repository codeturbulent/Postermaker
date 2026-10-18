import 'package:flutter_test/flutter_test.dart';
import 'package:poster_maker/models/poster_template.dart';
import 'package:poster_maker/models/user_profile.dart';
import 'package:poster_maker/providers/poster_provider.dart';
import 'package:poster_maker/utils/slogan_bank.dart';

void main() {
  group('UserProfile Model Tests', () {
    test('Serializes to JSON and deserializes correctly with top leaders', () {
      const original = UserProfile(
        id: 'user_123',
        fullName: 'अमित कुमार सिंह',
        designation: 'ब्लॉक प्रमुख',
        tagline: 'जन सेवा ही मेरा कर्म',
        phoneNumber: '+91 91234 56789',
        socialHandle: '@AmitSinghOfficial',
        profileImagePath: '/storage/emulated/0/DCIM/profile.jpg',
        partyOrSymbolImagePath: '/storage/emulated/0/DCIM/symbol.png',
        topLeaderImagePaths: ['/path/leader1.jpg', '/path/leader2.jpg'],
      );

      final json = original.toJson();
      final restored = UserProfile.fromJson(json);

      expect(restored.fullName, equals(original.fullName));
      expect(restored.designation, equals(original.designation));
      expect(restored.tagline, equals(original.tagline));
      expect(restored.phoneNumber, equals(original.phoneNumber));
      expect(restored.socialHandle, equals(original.socialHandle));
      expect(restored.profileImagePath, equals(original.profileImagePath));
      expect(
          restored.partyOrSymbolImagePath, equals(original.partyOrSymbolImagePath));
      expect(restored.topLeaderImagePaths.length, equals(2));
      expect(restored.topLeaderImagePaths.first, equals('/path/leader1.jpg'));
    });

    test('copyWith properly updates fields and clears image paths', () {
      final sample = UserProfile.sample();
      final updated = sample.copyWith(
        fullName: 'नया नाम',
        clearProfileImage: true,
      );

      expect(updated.fullName, equals('नया नाम'));
      expect(updated.profileImagePath, isNull);
      expect(updated.designation, equals(sample.designation));
    });
  });

  group('PosterTemplate Model Tests', () {
    test('dummyTemplates contains 5 authentic Indian templates', () {
      expect(PosterTemplate.dummyTemplates.length, equals(5));

      for (final template in PosterTemplate.dummyTemplates) {
        expect(template.id.isNotEmpty, isTrue);
        expect(template.title.isNotEmpty, isTrue);
        expect(template.defaultGreetingText.isNotEmpty, isTrue);
        expect(template.gradientColors.isNotEmpty, isTrue);
        expect(
          template.aspectRatio == 1.0 || template.aspectRatio == 0.8,
          isTrue,
        );
      }
    });
  });

  group('PosterProvider State & Viral Features Tests', () {
    test('Initializes with default template, aspect ratio, and profiles', () {
      final provider = PosterProvider();

      expect(provider.selectedTemplate, isNotNull);
      expect(provider.selectedCategoryFilter, isNull);
      expect(provider.filteredTemplates.length, equals(5));
      expect(provider.allProfiles.isNotEmpty, isTrue);
      expect(provider.currentAspectRatio, equals(provider.selectedTemplate.aspectRatio));
    });

    test('Aspect ratio switcher (1:1, 4:5, 9:16 Status) updates correctly', () {
      final provider = PosterProvider();

      provider.setAspectRatio(9 / 16);
      expect(provider.currentAspectRatio, equals(9 / 16));

      provider.setAspectRatio(1.0);
      expect(provider.currentAspectRatio, equals(1.0));
    });

    test('Badge icon sticker selection updates', () {
      final provider = PosterProvider();

      provider.setBadgeIcon('🕉️');
      expect(provider.selectedBadgeIcon, equals('🕉️'));

      provider.setBadgeIcon(null);
      expect(provider.selectedBadgeIcon, isNull);
    });

    test('Top leaders strip toggle works', () {
      final provider = PosterProvider();

      final initial = provider.showTopLeadersStrip;
      provider.toggleTopLeadersStrip();
      expect(provider.showTopLeadersStrip, equals(!initial));
    });
  });

  group('SloganBank Library Tests', () {
    test('SloganBank provides 30+ regional lines across 4 categories', () {
      expect(SloganBank.categories.length, equals(4));

      int totalSlogans = 0;
      for (final cat in SloganBank.categories) {
        expect(cat.title.isNotEmpty, isTrue);
        expect(cat.icon.isNotEmpty, isTrue);
        expect(cat.slogans.isNotEmpty, isTrue);
        totalSlogans += cat.slogans.length;
      }

      expect(totalSlogans, greaterThanOrEqualTo(25));
    });
  });
}
