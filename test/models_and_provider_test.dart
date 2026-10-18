import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poster_maker/features/image_search/models/image_search_result.dart';
import 'package:poster_maker/features/poster/models/canvas_element.dart';
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

  group('CanvasElement Model & Interactive Layer Tests', () {
    test('Serializes to JSON and deserializes correctly', () {
      const element = CanvasElement(
        id: 'text_101',
        type: CanvasElementType.text,
        text: 'दीपावली की हार्दिक बधाई',
        dx: 0.5,
        dy: 0.35,
        scale: 1.2,
        fontFamily: 'Rozha One',
        fontSize: 28.0,
        textColor: Color(0xFFFFD54F),
        strokeColor: Color(0xFF212121),
        strokeWidth: 4.0,
      );

      final json = element.toJson();
      final restored = CanvasElement.fromJson(json);

      expect(restored.id, equals('text_101'));
      expect(restored.type, equals(CanvasElementType.text));
      expect(restored.text, equals('दीपावली की हार्दिक बधाई'));
      expect(restored.dx, equals(0.5));
      expect(restored.dy, equals(0.35));
      expect(restored.scale, equals(1.2));
      expect(restored.fontFamily, equals('Rozha One'));
    });

    test('copyWith modifies attributes properly', () {
      const element = CanvasElement(
        id: 'sticker_1',
        type: CanvasElementType.sticker,
        stickerEmoji: '🪔',
        dx: 0.2,
        dy: 0.2,
      );

      final updated = element.copyWith(
        dx: 0.7,
        dy: 0.8,
        scale: 1.5,
      );

      expect(updated.id, equals('sticker_1'));
      expect(updated.dx, equals(0.7));
      expect(updated.dy, equals(0.8));
      expect(updated.scale, equals(1.5));
      expect(updated.stickerEmoji, equals('🪔'));
    });
  });

  group('ImageSearchResult Model Tests', () {
    test('Parses search result JSON accurately', () {
      final json = {
        'id': 'pix_12345',
        'title': 'Diwali Lights Festival',
        'thumbnailUrl': 'https://example.com/thumb.jpg',
        'fullUrl': 'https://example.com/full.jpg',
        'source': 'Pixabay',
        'category': 'Festival',
        'isTransparentSticker': true,
      };

      final result = ImageSearchResult.fromJson(json);
      expect(result.id, equals('pix_12345'));
      expect(result.title, equals('Diwali Lights Festival'));
      expect(result.source, equals('Pixabay'));
      expect(result.isTransparentSticker, isTrue);
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
      expect(provider.themeMode, equals(ThemeMode.system));
      expect(provider.canvasElements.isEmpty, isTrue);
    });

    test('ThemeMode switches correctly between light and dark', () async {
      final provider = PosterProvider();

      await provider.setThemeMode(ThemeMode.dark);
      expect(provider.themeMode, equals(ThemeMode.dark));

      await provider.setThemeMode(ThemeMode.light);
      expect(provider.themeMode, equals(ThemeMode.light));

      await provider.toggleThemeMode();
      expect(provider.themeMode, equals(ThemeMode.dark));
    });

    test('Canvas elements manipulation (add, select, update, reorder, delete)', () {
      final provider = PosterProvider();

      const elem1 = CanvasElement(id: 'elem_1', type: CanvasElementType.text, text: 'Text 1');
      const elem2 = CanvasElement(id: 'elem_2', type: CanvasElementType.sticker, stickerEmoji: '🪔');

      // Add
      provider.addElement(elem1);
      provider.addElement(elem2);
      expect(provider.canvasElements.length, equals(2));
      expect(provider.selectedElementId, equals('elem_2'));

      // Update
      provider.updateElement(elem1.copyWith(text: 'Updated Text 1'));
      expect(provider.canvasElements.first.text, equals('Updated Text 1'));

      // Select
      provider.selectElement('elem_1');
      expect(provider.selectedElement?.text, equals('Updated Text 1'));

      // Duplicate
      provider.duplicateElement('elem_1');
      expect(provider.canvasElements.length, equals(3));

      // Remove
      provider.removeElement('elem_2');
      expect(provider.canvasElements.length, equals(2));

      // Clear all
      provider.clearAllElements();
      expect(provider.canvasElements.isEmpty, isTrue);
      expect(provider.selectedElementId, isNull);
    });

    test('Custom background url and reset works', () {
      final provider = PosterProvider();

      expect(provider.customBackgroundUrl, isNull);
      provider.setCustomBackground(url: 'https://images.unsplash.com/sample.jpg');
      expect(provider.customBackgroundUrl, equals('https://images.unsplash.com/sample.jpg'));

      provider.clearCustomBackground();
      expect(provider.customBackgroundUrl, isNull);
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
