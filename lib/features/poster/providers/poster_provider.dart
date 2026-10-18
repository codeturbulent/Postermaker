import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:poster_maker/features/poster/models/canvas_element.dart';
import 'package:poster_maker/features/poster/models/poster_template.dart';
import 'package:poster_maker/features/profile/models/user_profile.dart';

/// Central state manager for the poster maker application using [ChangeNotifier].
class PosterProvider extends ChangeNotifier {
  static const String _allProfilesStorageKey = 'saved_user_profiles_list_v2';
  static const String _activeProfileIndexKey = 'active_profile_index_v2';
  static const String _themeModeStorageKey = 'theme_mode_preference_v1';

  List<UserProfile> _allProfiles = [UserProfile.sample()];
  int _activeProfileIndex = 0;

  late PosterTemplate _selectedTemplate;
  String _customGreeting = '';
  late PhotoAlignment _photoAlignment;
  late Color _ribbonColor;
  TemplateCategory? _selectedCategoryFilter;

  // Theme Mode (Material 3 Light / Dark / System)
  ThemeMode _themeMode = ThemeMode.system;

  // New viral regional features
  double _currentAspectRatio = 0.8; // 1.0 (1:1), 0.8 (4:5), 9/16 (0.5625 WhatsApp Status)
  bool _showTopLeadersStrip = true;
  String? _selectedBadgeIcon = '🪔';

  // Interactive Draggable Canvas Elements & Custom Background
  List<CanvasElement> _canvasElements = [];
  String? _selectedElementId;
  String? _customBackgroundUrl;
  String? _customBackgroundImagePath;

  bool _isLoading = true;
  bool _isExporting = false;

  final ImagePicker _picker = ImagePicker();

  UserProfile get profile => _allProfiles[_activeProfileIndex];
  List<UserProfile> get allProfiles => List.unmodifiable(_allProfiles);
  int get activeProfileIndex => _activeProfileIndex;

  PosterTemplate get selectedTemplate => _selectedTemplate;
  String get customGreeting => _customGreeting;
  PhotoAlignment get photoAlignment => _photoAlignment;
  Color get ribbonColor => _ribbonColor;
  TemplateCategory? get selectedCategoryFilter => _selectedCategoryFilter;
  ThemeMode get themeMode => _themeMode;
  double get currentAspectRatio => _currentAspectRatio;
  bool get showTopLeadersStrip => _showTopLeadersStrip;
  String? get selectedBadgeIcon => _selectedBadgeIcon;
  bool get isLoading => _isLoading;
  bool get isExporting => _isExporting;

  List<CanvasElement> get canvasElements => List.unmodifiable(_canvasElements);
  String? get selectedElementId => _selectedElementId;
  CanvasElement? get selectedElement {
    if (_selectedElementId == null) return null;
    try {
      return _canvasElements.firstWhere((e) => e.id == _selectedElementId);
    } catch (_) {
      return null;
    }
  }
  String? get customBackgroundUrl => _customBackgroundUrl;
  String? get customBackgroundImagePath => _customBackgroundImagePath;

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
    _selectedTemplate = PosterTemplate.dummyTemplates.first;
    _customGreeting = _selectedTemplate.defaultGreetingText;
    _photoAlignment = _selectedTemplate.photoAlignment;
    _ribbonColor = _selectedTemplate.primaryColor;
    _currentAspectRatio = _selectedTemplate.aspectRatio;
  }

  /// Initializes provider by loading persisted profiles list from [SharedPreferences].
  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedListJson = prefs.getString(_allProfilesStorageKey);
      final savedIndex = prefs.getInt(_activeProfileIndexKey) ?? 0;
      final themeIndex = prefs.getInt(_themeModeStorageKey);

      if (themeIndex != null &&
          themeIndex >= 0 &&
          themeIndex < ThemeMode.values.length) {
        _themeMode = ThemeMode.values[themeIndex];
      }

      if (savedListJson != null && savedListJson.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(savedListJson) as List<dynamic>;
        _allProfiles = decoded
            .map((item) => UserProfile.fromJson(item as Map<String, dynamic>))
            .toList();

        if (_allProfiles.isEmpty) {
          _allProfiles = [UserProfile.sample()];
        }

        _activeProfileIndex =
            (savedIndex >= 0 && savedIndex < _allProfiles.length)
                ? savedIndex
                : 0;
      } else {
        _allProfiles = [UserProfile.sample()];
        _activeProfileIndex = 0;
        await _persistAllProfiles();
      }
    } catch (e) {
      debugPrint('Error loading saved profiles: $e');
      _allProfiles = [UserProfile.sample()];
      _activeProfileIndex = 0;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Persists all profiles to SharedPreferences
  Future<void> _persistAllProfiles() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final listJson =
          jsonEncode(_allProfiles.map((p) => p.toJson()).toList());
      await prefs.setString(_allProfilesStorageKey, listJson);
      await prefs.setInt(_activeProfileIndexKey, _activeProfileIndex);
    } catch (e) {
      debugPrint('Error persisting profiles: $e');
    }
  }

  /// Updates active profile data
  Future<void> updateProfile(UserProfile updated) async {
    _allProfiles[_activeProfileIndex] = updated;
    notifyListeners();
    await _persistAllProfiles();
  }

  /// Switches active profile (Family / Client Mode)
  Future<void> switchProfile(int index) async {
    if (index >= 0 && index < _allProfiles.length) {
      _activeProfileIndex = index;
      notifyListeners();
      await _persistAllProfiles();
    }
  }

  /// Adds a new candidate/family profile
  Future<void> addNewProfile({String? name, String? designation}) async {
    if (_allProfiles.length >= 6) return;

    final newProfile = UserProfile(
      id: 'profile_${DateTime.now().millisecondsSinceEpoch}',
      fullName: name ?? 'नया सदस्य',
      designation: designation ?? 'पदनाम',
      tagline: 'जन सेवा ही धर्म',
      phoneNumber: '+91 ',
      socialHandle: '@',
      profileImagePath: null,
      partyOrSymbolImagePath: null,
      topLeaderImagePaths: const [],
    );

    _allProfiles.add(newProfile);
    _activeProfileIndex = _allProfiles.length - 1;
    notifyListeners();
    await _persistAllProfiles();
  }

  /// Deletes a candidate profile (keeps at least 1)
  Future<void> deleteProfile(int index) async {
    if (_allProfiles.length <= 1) return;

    _allProfiles.removeAt(index);
    if (_activeProfileIndex >= _allProfiles.length) {
      _activeProfileIndex = _allProfiles.length - 1;
    }
    notifyListeners();
    await _persistAllProfiles();
  }

  /// Sets the currently active poster template
  void selectTemplate(PosterTemplate template) {
    _selectedTemplate = template;
    _customGreeting = template.defaultGreetingText;
    _photoAlignment = template.photoAlignment;
    _ribbonColor = template.primaryColor;
    _currentAspectRatio = template.aspectRatio;
    notifyListeners();
  }

  /// Customizes greeting text on the fly
  void setCustomGreeting(String greeting) {
    _customGreeting = greeting;
    notifyListeners();
  }

  /// 1-Tap Aspect Ratio Switcher (1:1 Post, 4:5 Banner, 9:16 WhatsApp Status)
  void setAspectRatio(double ratio) {
    _currentAspectRatio = ratio;
    notifyListeners();
  }

  /// Toggles visibility of top senior leader portraits bar
  void toggleTopLeadersStrip() {
    _showTopLeadersStrip = !_showTopLeadersStrip;
    notifyListeners();
  }

  /// 1-Tap sticker / auspicious symbol selection
  void setBadgeIcon(String? icon) {
    _selectedBadgeIcon = icon;
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

  /// Changes application theme mode (Light, Dark, System) and persists to SharedPreferences
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeModeStorageKey, mode.index);
    } catch (e) {
      debugPrint('Error saving theme mode: $e');
    }
  }

  /// Toggles between Light and Dark mode
  Future<void> toggleThemeMode() async {
    if (_themeMode == ThemeMode.dark) {
      await setThemeMode(ThemeMode.light);
    } else {
      await setThemeMode(ThemeMode.dark);
    }
  }

  /// Adds a new interactive movable layer (text, sticker, or photo) onto the canvas
  void addElement(CanvasElement element) {
    _canvasElements.add(element);
    _selectedElementId = element.id;
    notifyListeners();
  }

  /// Updates properties or coordinates of an existing canvas element
  void updateElement(CanvasElement element) {
    final idx = _canvasElements.indexWhere((e) => e.id == element.id);
    if (idx != -1) {
      _canvasElements[idx] = element;
      notifyListeners();
    }
  }

  /// Deletes a canvas element by id
  void removeElement(String id) {
    _canvasElements.removeWhere((e) => e.id == id);
    if (_selectedElementId == id) {
      _selectedElementId = null;
    }
    notifyListeners();
  }

  /// Selects or deselects an active element on the canvas
  void selectElement(String? id) {
    _selectedElementId = id;
    notifyListeners();
  }

  /// Re-orders element to top of layer stack
  void bringElementToFront(String id) {
    final idx = _canvasElements.indexWhere((e) => e.id == id);
    if (idx != -1 && idx < _canvasElements.length - 1) {
      final elem = _canvasElements.removeAt(idx);
      _canvasElements.add(elem);
      notifyListeners();
    }
  }

  /// Re-orders element to bottom of layer stack
  void sendElementToBack(String id) {
    final idx = _canvasElements.indexWhere((e) => e.id == id);
    if (idx > 0) {
      final elem = _canvasElements.removeAt(idx);
      _canvasElements.insert(0, elem);
      notifyListeners();
    }
  }

  /// Clones selected element slightly offset
  void duplicateElement(String id) {
    final idx = _canvasElements.indexWhere((e) => e.id == id);
    if (idx != -1) {
      final original = _canvasElements[idx];
      final clone = original.copyWith(
        id: 'elem_${DateTime.now().millisecondsSinceEpoch}',
        dx: (original.dx + 0.05).clamp(0.05, 0.95),
        dy: (original.dy + 0.05).clamp(0.05, 0.95),
      );
      addElement(clone);
    }
  }

  /// Removes all custom layers from the canvas
  void clearAllElements() {
    _canvasElements.clear();
    _selectedElementId = null;
    notifyListeners();
  }

  /// Sets a searched image or custom graphic as the full poster backdrop
  void setCustomBackground({String? url, String? filePath}) {
    _customBackgroundUrl = url;
    _customBackgroundImagePath = filePath;
    notifyListeners();
  }

  /// Reverts to template default background
  void clearCustomBackground() {
    _customBackgroundUrl = null;
    _customBackgroundImagePath = null;
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
      final updatedProfile = profile.copyWith(profileImagePath: finalPath);
      await updateProfile(updatedProfile);
      return true;
    } catch (e) {
      debugPrint('Error picking profile image: $e');
      return false;
    }
  }

  /// Adds a senior leader / mentor photo to the top strip (up to 4 leaders)
  Future<bool> addTopLeaderPhoto() async {
    try {
      if (profile.topLeaderImagePaths.length >= 4) return false;

      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
      );

      if (pickedFile == null) return false;

      final CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'नेताजी फ़ोटो क्रॉप करें',
            toolbarColor: const Color(0xFFD84315),
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
            aspectRatioPresets: [CropAspectRatioPreset.square],
          ),
          IOSUiSettings(
            title: 'नेताजी फ़ोटो क्रॉप करें',
            aspectRatioPresets: [CropAspectRatioPreset.square],
          ),
        ],
      );

      final finalPath = croppedFile?.path ?? pickedFile.path;
      final updatedList = List<String>.from(profile.topLeaderImagePaths)
        ..add(finalPath);
      final updatedProfile =
          profile.copyWith(topLeaderImagePaths: updatedList);
      await updateProfile(updatedProfile);
      return true;
    } catch (e) {
      debugPrint('Error adding leader photo: $e');
      return false;
    }
  }

  /// Removes a leader photo at index
  Future<void> removeTopLeaderPhoto(int index) async {
    if (index >= 0 && index < profile.topLeaderImagePaths.length) {
      final updatedList = List<String>.from(profile.topLeaderImagePaths)
        ..removeAt(index);
      final updatedProfile =
          profile.copyWith(topLeaderImagePaths: updatedList);
      await updateProfile(updatedProfile);
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
          profile.copyWith(partyOrSymbolImagePath: finalPath);
      await updateProfile(updatedProfile);
      return true;
    } catch (e) {
      debugPrint('Error picking symbol image: $e');
      return false;
    }
  }

  /// Clears selected profile photo
  Future<void> clearProfileImage() async {
    final updated = profile.copyWith(clearProfileImage: true);
    await updateProfile(updated);
  }

  /// Clears selected emblem / badge
  Future<void> clearPartySymbolImage() async {
    final updated = profile.copyWith(clearPartyOrSymbolImage: true);
    await updateProfile(updated);
  }
}
