import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/image_search_result.dart';

/// Provider source types for image search.
enum ImageSearchProvider {
  all('सभी (All)'),
  pixabay('Pixabay'),
  unsplash('Unsplash'),
  wikimedia('Wikimedia Commons');

  final String label;
  const ImageSearchProvider(this.label);
}

/// Service orchestrating stock image searches across Pixabay, Unsplash, Wikimedia Commons,
/// and curated regional graphic libraries.
class ImageSearchService {
  static final HttpClient _httpClient = HttpClient()
    ..connectionTimeout = const Duration(seconds: 10);

  // Storage keys for user customized keys
  static const String _pixabayPrefKey = 'custom_pixabay_api_key_v1';
  static const String _unsplashPrefKey = 'custom_unsplash_access_key_v1';

  /// Resolves active Pixabay key securely from environment, prefs, or gitignored prod_env.json
  static Future<String> getPixabayKey() async {
    const envKey = String.fromEnvironment('PIXABAY_API_KEY');
    if (envKey.isNotEmpty) return envKey;

    try {
      final prefs = await SharedPreferences.getInstance();
      final custom = prefs.getString(_pixabayPrefKey);
      if (custom != null && custom.isNotEmpty) return custom;
    } catch (_) {}

    try {
      final file = File('config/prod_env.json');
      if (file.existsSync()) {
        final content =
            jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
        final key = content['PIXABAY_API_KEY'] as String?;
        if (key != null && key.isNotEmpty) return key;
      }
    } catch (_) {}

    return '';
  }

  /// Resolves active Unsplash access key securely from environment, prefs, or gitignored prod_env.json
  static Future<String> getUnsplashKey() async {
    const envKey = String.fromEnvironment('UNSPLASH_ACCESS_KEY');
    if (envKey.isNotEmpty) return envKey;

    try {
      final prefs = await SharedPreferences.getInstance();
      final custom = prefs.getString(_unsplashPrefKey);
      if (custom != null && custom.isNotEmpty) return custom;
    } catch (_) {}

    try {
      final file = File('config/prod_env.json');
      if (file.existsSync()) {
        final content =
            jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
        final key = content['UNSPLASH_ACCESS_KEY'] as String?;
        if (key != null && key.isNotEmpty) return key;
      }
    } catch (_) {}

    return '';
  }

  /// Popular search suggestions for regional Indian poster making
  static List<String> get popularSuggestions => const [
        'Diwali 🪔',
        'Holi 🎨',
        'Tiranga 🇮🇳',
        'Banner Background 🖼️',
        'Golden Frame ✨',
        'Elections 🗳️',
        'Birthday 🎂',
        'Mandala 🕉️',
        'Flowers 🌺',
        'Glow Effect 🌟',
      ];

  /// Curated offline/fallback regional graphics collection
  static final List<ImageSearchResult> _curatedAssets = [
    const ImageSearchResult(
      id: 'curated_diwali_1',
      title: 'दीपावली दीया एवं स्वर्ण रोशनी (Diwali Golden Lights)',
      thumbnailUrl:
          'https://images.unsplash.com/photo-1514565131-fce0801e5785?auto=format&fit=crop&w=600&q=80',
      fullUrl:
          'https://images.unsplash.com/photo-1514565131-fce0801e5785?auto=format&fit=crop&w=1400&q=85',
      source: 'Curated',
      category: 'त्यौहार (Festival)',
    ),
    const ImageSearchResult(
      id: 'curated_diwali_2',
      title: 'पारंपरिक दीया थाली (Traditional Diya Plate)',
      thumbnailUrl:
          'https://images.unsplash.com/photo-1605629921711-2f6b00c6bbf4?auto=format&fit=crop&w=600&q=80',
      fullUrl:
          'https://images.unsplash.com/photo-1605629921711-2f6b00c6bbf4?auto=format&fit=crop&w=1400&q=85',
      source: 'Curated',
      category: 'त्यौहार (Festival)',
    ),
    const ImageSearchResult(
      id: 'curated_patriotic_1',
      title: 'तिरंगा देशभक्ति पृष्ठभूमि (Tiranga Tri-color Backdrop)',
      thumbnailUrl:
          'https://images.unsplash.com/photo-1532375810709-75b1da00537c?auto=format&fit=crop&w=600&q=80',
      fullUrl:
          'https://images.unsplash.com/photo-1532375810709-75b1da00537c?auto=format&fit=crop&w=1400&q=85',
      source: 'Curated',
      category: 'राष्ट्रीय (Patriotic)',
    ),
    const ImageSearchResult(
      id: 'curated_political_1',
      title: 'पंचायत एवं ग्रामीण विकास (Rural Development Banner)',
      thumbnailUrl:
          'https://images.unsplash.com/photo-1540910419892-4a36d2c3266c?auto=format&fit=crop&w=600&q=80',
      fullUrl:
          'https://images.unsplash.com/photo-1540910419892-4a36d2c3266c?auto=format&fit=crop&w=1400&q=85',
      source: 'Curated',
      category: 'राजनीतिक (Political)',
    ),
    const ImageSearchResult(
      id: 'curated_birthday_1',
      title: 'जन्मदिन स्वर्ण उत्सव (Birthday Golden Celebration)',
      thumbnailUrl:
          'https://images.unsplash.com/photo-1513151233558-d860c5398176?auto=format&fit=crop&w=600&q=80',
      fullUrl:
          'https://images.unsplash.com/photo-1513151233558-d860c5398176?auto=format&fit=crop&w=1400&q=85',
      source: 'Curated',
      category: 'जन्मदिन (Birthday)',
    ),
    const ImageSearchResult(
      id: 'curated_golden_texture_1',
      title: 'शाही स्वर्ण बैकग्राउंड (Royal Gold Texture)',
      thumbnailUrl:
          'https://images.unsplash.com/photo-1579546929518-9e396f3cc809?auto=format&fit=crop&w=600&q=80',
      fullUrl:
          'https://images.unsplash.com/photo-1579546929518-9e396f3cc809?auto=format&fit=crop&w=1400&q=85',
      source: 'Curated',
      category: 'पृष्ठभूमि (Background)',
    ),
    const ImageSearchResult(
      id: 'sticker_diya_1',
      title: 'शुभ दीया ज्योति (Shubh Diya Flame)',
      thumbnailUrl:
          'https://images.unsplash.com/photo-1605629921711-2f6b00c6bbf4?auto=format&fit=crop&w=300&q=80',
      fullUrl:
          'https://images.unsplash.com/photo-1605629921711-2f6b00c6bbf4?auto=format&fit=crop&w=600&q=80',
      source: 'Curated Sticker',
      category: 'स्टीकर्स (Stickers)',
      isTransparentSticker: true,
    ),
  ];

  /// Unified multi-provider search across Pixabay, Unsplash, Wikimedia, and Curated Library
  static Future<List<ImageSearchResult>> searchImages({
    required String query,
    ImageSearchProvider provider = ImageSearchProvider.all,
    bool stickersOnly = false,
  }) async {
    final cleanQuery = query.trim().isEmpty ? 'festival' : query.trim();
    final results = <ImageSearchResult>[];

    final futures = <Future<List<ImageSearchResult>>>[];

    // 1. Pixabay Search
    if (provider == ImageSearchProvider.all || provider == ImageSearchProvider.pixabay) {
      futures.add(_searchPixabay(cleanQuery, stickersOnly: stickersOnly));
    }

    // 2. Unsplash Search
    if ((provider == ImageSearchProvider.all || provider == ImageSearchProvider.unsplash) && !stickersOnly) {
      futures.add(_searchUnsplash(cleanQuery));
    }

    // 3. Wikimedia Commons Search
    if (provider == ImageSearchProvider.all || provider == ImageSearchProvider.wikimedia) {
      futures.add(_searchWikimedia(cleanQuery));
    }

    final responses = await Future.wait(futures);
    for (final list in responses) {
      results.addAll(list);
    }

    // If query is empty or no network results, include curated regional assets
    if (results.isEmpty) {
      final qLower = cleanQuery.toLowerCase();
      final curated = _curatedAssets.where((item) {
        if (stickersOnly && !item.isTransparentSticker) return false;
        return item.title.toLowerCase().contains(qLower) ||
            item.category.toLowerCase().contains(qLower);
      }).toList();

      results.addAll(curated.isNotEmpty ? curated : _curatedAssets);
    }

    return results;
  }

  /// Searches Pixabay REST API with official API key
  static Future<List<ImageSearchResult>> _searchPixabay(
    String query, {
    bool stickersOnly = false,
  }) async {
    try {
      final key = await getPixabayKey();
      final encodedQuery = Uri.encodeComponent(query);
      final imageType = stickersOnly ? 'illustration' : 'all';
      final uri = Uri.parse(
        'https://pixabay.com/api/?key=$key&q=$encodedQuery&image_type=$imageType&per_page=20&safesearch=true',
      );

      final request = await _httpClient.getUrl(uri);
      request.headers.set('User-Agent', 'PosterMakerApp/1.0');
      final response = await request.close();

      if (response.statusCode != HttpStatus.ok) return [];

      final body = await response.transform(utf8.decoder).join();
      final Map<String, dynamic> data = jsonDecode(body) as Map<String, dynamic>;
      final hits = data['hits'] as List<dynamic>? ?? [];

      return hits.map((item) {
        final hit = item as Map<String, dynamic>;
        return ImageSearchResult(
          id: 'pixabay_${hit['id']}',
          title: (hit['tags'] as String? ?? 'Pixabay Image').split(',').first.trim(),
          thumbnailUrl: hit['webformatURL'] as String? ?? hit['previewURL'] as String? ?? '',
          fullUrl: hit['largeImageURL'] as String? ?? hit['webformatURL'] as String? ?? '',
          source: 'Pixabay',
          category: hit['type'] as String? ?? 'Photo',
          isTransparentSticker: hit['type'] == 'illustration' || (hit['tags'] as String? ?? '').contains('png'),
          width: hit['imageWidth'] as int?,
          height: hit['imageHeight'] as int?,
        );
      }).toList();
    } catch (e) {
      debugPrint('Pixabay search error: $e');
      return [];
    }
  }

  /// Searches Unsplash API with Application Access Key
  static Future<List<ImageSearchResult>> _searchUnsplash(String query) async {
    try {
      final key = await getUnsplashKey();
      final encodedQuery = Uri.encodeComponent(query);
      final uri = Uri.parse(
        'https://api.unsplash.com/search/photos?query=$encodedQuery&page=1&per_page=20',
      );

      final request = await _httpClient.getUrl(uri);
      request.headers.set('Authorization', 'Client-ID $key');
      request.headers.set('User-Agent', 'PosterMakerApp/1.0');
      final response = await request.close();

      if (response.statusCode != HttpStatus.ok) return [];

      final body = await response.transform(utf8.decoder).join();
      final Map<String, dynamic> data = jsonDecode(body) as Map<String, dynamic>;
      final results = data['results'] as List<dynamic>? ?? [];

      return results.map((item) {
        final photo = item as Map<String, dynamic>;
        final urls = photo['urls'] as Map<String, dynamic>? ?? {};
        final user = photo['user'] as Map<String, dynamic>? ?? {};
        final desc = photo['description'] as String? ??
            photo['alt_description'] as String? ??
            'Unsplash Photo';

        return ImageSearchResult(
          id: 'unsplash_${photo['id']}',
          title: desc,
          thumbnailUrl: urls['small'] as String? ?? urls['thumb'] as String? ?? '',
          fullUrl: urls['regular'] as String? ?? urls['full'] as String? ?? '',
          source: 'Unsplash (${user['name'] ?? 'Photographer'})',
          category: 'Photo',
          width: photo['width'] as int?,
          height: photo['height'] as int?,
        );
      }).toList();
    } catch (e) {
      debugPrint('Unsplash search error: $e');
      return [];
    }
  }

  /// Searches Wikimedia Commons Open API (public domain, zero credentials required)
  static Future<List<ImageSearchResult>> _searchWikimedia(String query) async {
    try {
      final encodedQuery = Uri.encodeComponent(query);
      final uri = Uri.parse(
        'https://commons.wikimedia.org/w/api.php?action=query&generator=search&gsrsearch=$encodedQuery&gsrnamespace=6&gsrlimit=14&prop=imageinfo&iiprop=url|mime|size&iiurlwidth=600&format=json',
      );

      final request = await _httpClient.getUrl(uri);
      request.headers.set('User-Agent', 'PosterMakerApp/1.0 (Mobile App)');
      final response = await request.close();

      if (response.statusCode != HttpStatus.ok) return [];

      final body = await response.transform(utf8.decoder).join();
      final Map<String, dynamic> data = jsonDecode(body) as Map<String, dynamic>;
      final pages = data['query']?['pages'] as Map<String, dynamic>?;
      if (pages == null) return [];

      final list = <ImageSearchResult>[];

      for (final entry in pages.values) {
        final page = entry as Map<String, dynamic>;
        final title = (page['title'] as String? ?? 'Image').replaceAll('File:', '');
        final imageInfo = (page['imageinfo'] as List<dynamic>?)?.firstOrNull
            as Map<String, dynamic>?;

        if (imageInfo != null) {
          final thumbUrl = imageInfo['thumburl'] as String? ?? imageInfo['url'] as String?;
          final fullUrl = imageInfo['url'] as String? ?? thumbUrl;
          final mime = imageInfo['mime'] as String? ?? '';

          if (fullUrl != null && (mime.contains('image/jpeg') || mime.contains('image/png') || mime.contains('image/webp'))) {
            list.add(
              ImageSearchResult(
                id: 'wiki_${page['pageid'] ?? DateTime.now().millisecondsSinceEpoch}',
                title: title,
                thumbnailUrl: thumbUrl ?? fullUrl,
                fullUrl: fullUrl,
                source: 'Wikimedia Commons',
                category: 'Public Domain',
                isTransparentSticker: mime.contains('png'),
              ),
            );
          }
        }
      }

      return list;
    } catch (e) {
      debugPrint('Wikimedia search error: $e');
      return [];
    }
  }
}
