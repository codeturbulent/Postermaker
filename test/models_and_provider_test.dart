import 'package:flutter_test/flutter_test.dart';
import 'package:poster_maker/models/poster_template.dart';
import 'package:poster_maker/models/user_profile.dart';
import 'package:poster_maker/providers/poster_provider.dart';

void main() {
  group('UserProfile Model Tests', () {
    test('Serializes to JSON and deserializes correctly', () {
      const original = UserProfile(
        fullName: 'अमित कुमार सिंह',
        designation: 'ब्लॉक प्रमुख',
        tagline: 'जन सेवा ही मेरा कर्म',
        phoneNumber: '+91 91234 56789',
        socialHandle: '@AmitSinghOfficial',
        profileImagePath: '/storage/emulated/0/DCIM/profile.jpg',
        partyOrSymbolImagePath: '/storage/emulated/0/DCIM/symbol.png',
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

    test('Category filtering works correctly', () {
      final festivals = PosterTemplate.dummyTemplates
          .where((t) => t.category == TemplateCategory.festival)
          .toList();
      final politicals = PosterTemplate.dummyTemplates
          .where((t) => t.category == TemplateCategory.political)
          .toList();

      expect(festivals.isNotEmpty, isTrue);
      expect(politicals.isNotEmpty, isTrue);
    });
  });

  group('PosterProvider State Tests', () {
    test('Initializes with default template and category filter', () {
      final provider = PosterProvider();

      expect(provider.selectedTemplate, isNotNull);
      expect(provider.selectedCategoryFilter, isNull);
      expect(provider.filteredTemplates.length, equals(5));

      // Category filter test
      provider.setCategoryFilter(TemplateCategory.political);
      expect(provider.selectedCategoryFilter, equals(TemplateCategory.political));
      for (final tpl in provider.filteredTemplates) {
        expect(tpl.category, equals(TemplateCategory.political));
      }
    });

    test('selectTemplate updates greeting and ribbon color', () {
      final provider = PosterProvider();
      final template = PosterTemplate.dummyTemplates[2];

      provider.selectTemplate(template);

      expect(provider.selectedTemplate.id, equals(template.id));
      expect(provider.customGreeting, equals(template.defaultGreetingText));
      expect(provider.ribbonColor, equals(template.primaryColor));
    });
  });
}
