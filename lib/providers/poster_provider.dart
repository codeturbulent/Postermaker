import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/poster_template.dart';
import '../models/user_profile.dart';

/// Central state manager for the poster maker application using [ChangeNotifier].
class PosterProvider extends ChangeNotifier {
  static const String _profileStorageKey = 'saved_user_profile_json_v1';

  UserProfile _profile = UserProfile.sample();
  late PosterTemplate _selectedTemplate;
  String _customGreeting = '';
  late PhotoAlignment _photoAlignment;
  late Color _ribbonColor;
  TemplateCategory? _selectedCategoryFilter;

  bool _isLoading = true;
  bool _isExporting = false;

  final ImagePicker _picker = ImagePicker();

  UserProfile get profile => _profile;
  PosterTemplate get selectedTemplate => _selectedTemplate;
  String get customGreeting => _customGreeting;
  PhotoAlignment get photoAlignment => _photoAlignment;
  Color get ribbonColor => _ribbonColor;
  TemplateCategory? get selectedCategoryFilter => _selectedCategoryFilter;
  bool get isLoading => _isLoading;
  bool get isExporting => _isExporting;

  /// Returns templates filtered by currently active category chip
  List<PosterTemplate> get filteredTemplates {
    if (_selectedCategoryFilter == null) {
      return PosterTemplate.dummyTemplates;
    }
    return PosterTemplate.dummyTemplates
        .where((tpl) => tpl.category == _selectedCategoryFilter)
        .toList();
  }

  PosterProvider() {
    // Select first template as initial state
    _selectedTemplate = PosterTemplate.dummyTemplates.first;
    _customGreeting = _selectedTemplate.defaultGreetingText;
    _photoAlignment = _selectedTemplate.photoAlignment;
    _ribbonColor = _selectedTemplate.primaryColor;
  }

  /// Initializes provider by loading persisted user profile from [SharedPreferences].
  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedJsonString = prefs.getString(_profileStorageKey);

      if (savedJsonString != null && savedJsonString.isNotEmpty) {
        final Map<String, dynamic> decoded =
            jsonDecode(savedJsonString) as Map<String, dynamic>;
        _profile = UserProfile.fromJson(decoded);
      } else {
        // First run: Seed with authentic sample profile so user has an immediate preview
        _profile = UserProfile.sample();
        await _persistProfile(_profile);
      }
    } catch (e) {
      debugPrint('Error loading saved profile: $e');
      _profile = UserProfile.sample();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Persists profile to local storage and updates state
  Future<void> updateProfile(UserProfile newProfile) async {
    _profile = newProfile;
    notifyListeners();
    await _persistProfile(newProfile);
  }

  Future<void> _persistProfile(UserProfile profileToSave) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(profileToSave.toJson());
      await prefs.setString(_profileStorageKey, jsonString);
    } catch (e) {
      debugPrint('Error saving profile to SharedPreferences: $e');
    }
  }

  /// Sets the currently active poster template
  void selectTemplate(PosterTemplate template) {
    _selectedTemplate = template;
    _customGreeting = template.defaultGreetingText;
    _photoAlignment = template.photoAlignment;
    _ribbonColor = template.primaryColor;
    notifyListeners();
  }

  /// Customizes greeting text on the fly
  void setCustomGreeting(String greeting) {
    _customGreeting = greeting;
    notifyListeners();
  }

  /// Flips user photo placement (Left vs Right)
  void setPhotoAlignment(PhotoAlignment alignment) {
    _photoAlignment = alignment;
    notifyListeners();
  }

  /// Customizes footer ribbon theme color
  void setRibbonColor(Color color) {
    _ribbonColor = color;
    notifyListeners();
  }

  /// Filters templates list by category
  void setCategoryFilter(TemplateCategory? category) {
    _selectedCategoryFilter = category;
    notifyListeners();
  }

  void setIsExporting(bool exporting) {
    _isExporting = exporting;
    notifyListeners();
  }

  /// Selects and crops user profile photo with 1:1 and 3:4 aspect ratio presets
  Future<bool> pickAndCropProfileImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 95,
      );

      if (pickedFile == null) return false;

      final CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'फ़ोटो क्रॉप करें',
            toolbarColor: const Color(0xFFD84315),
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: false,
            aspectRatioPresets: [
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio3x2,
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.ratio4x3,
            ],
          ),
          IOSUiSettings(
            title: 'फ़ोटो क्रॉप करें',
            aspectRatioPresets: [
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio3x2,
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.ratio4x3,
            ],
          ),
        ],
      );

      final finalPath = croppedFile?.path ?? pickedFile.path;
      final updatedProfile = _profile.copyWith(profileImagePath: finalPath);
      await updateProfile(updatedProfile);
      return true;
    } catch (e) {
      debugPrint('Error picking profile image: $e');
      return false;
    }
  }

  /// Selects and crops secondary party/organization symbol badge
  Future<bool> pickAndCropPartySymbolImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 95,
      );

      if (pickedFile == null) return false;

      final CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'प्रतीक चिन्ह क्रॉप करें',
            toolbarColor: const Color(0xFF1B5E20),
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
            aspectRatioPresets: [
              CropAspectRatioPreset.square,
            ],
          ),
          IOSUiSettings(
            title: 'प्रतीक चिन्ह क्रॉप करें',
            aspectRatioPresets: [
              CropAspectRatioPreset.square,
            ],
          ),
        ],
      );

      final finalPath = croppedFile?.path ?? pickedFile.path;
      final updatedProfile =
          _profile.copyWith(partyOrSymbolImagePath: finalPath);
      await updateProfile(updatedProfile);
      return true;
    } catch (e) {
      debugPrint('Error picking symbol image: $e');
      return false;
    }
  }

  /// Clears selected profile photo
  Future<void> clearProfileImage() async {
    final updated = _profile.copyWith(clearProfileImage: true);
    await updateProfile(updated);
  }

  /// Clears selected emblem / badge
  Future<void> clearPartySymbolImage() async {
    final updated = _profile.copyWith(clearPartyOrSymbolImage: true);
    await updateProfile(updated);
  }
}
