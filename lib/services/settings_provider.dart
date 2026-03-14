import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'offline_dictionary_service.dart';

enum LexiconFontSize { small, defaultSize, large, extraLarge }

class SettingsProvider with ChangeNotifier {
  static const String _keyFontSize = 'settings_font_size';
  static const String _keyMinimalMode = 'settings_minimal_mode';
  static const String _keyDyslexiaMode = 'settings_dyslexia_mode';
  static const String _keyColorblindMode = 'settings_colorblind_mode';
  static const String _keySystemLookup = 'settings_system_lookup';
  static const String _keyFloatingBubble = 'settings_floating_bubble';
  static const String _keyThemeMode = 'settings_theme_mode';
  static const String _keyOfflineDownloaded = 'settings_offline_downloaded';

  LexiconFontSize _fontSize = LexiconFontSize.defaultSize;
  bool _minimalMode = false;
  bool _dyslexiaMode = false;
  bool _colorblindMode = false;
  bool _systemLookup = true;
  bool _floatingBubble = false;
  ThemeMode _themeMode = ThemeMode.dark;
  bool _offlineDownloaded = false;
  double _downloadProgress = 0.0;
  bool _isDownloading = false;

  LexiconFontSize get fontSize => _fontSize;
  bool get minimalMode => _minimalMode;
  bool get dyslexiaMode => _dyslexiaMode;
  bool get colorblindMode => _colorblindMode;
  bool get systemLookup => _systemLookup;
  bool get floatingBubble => _floatingBubble;
  ThemeMode get themeMode => _themeMode;
  bool get offlineDownloaded => _offlineDownloaded;
  double get downloadProgress => _downloadProgress;
  bool get isDownloading => _isDownloading;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _fontSize = LexiconFontSize.values[prefs.getInt(_keyFontSize) ?? 1];
    _minimalMode = prefs.getBool(_keyMinimalMode) ?? false;
    _dyslexiaMode = prefs.getBool(_keyDyslexiaMode) ?? false;
    _colorblindMode = prefs.getBool(_keyColorblindMode) ?? false;
    _systemLookup = prefs.getBool(_keySystemLookup) ?? true;
    _floatingBubble = prefs.getBool(_keyFloatingBubble) ?? false;
    _themeMode = ThemeMode.values[prefs.getInt(_keyThemeMode) ?? 1]; // Default to dark (index 1)
    _offlineDownloaded = await OfflineDictionaryService.instance.isInstalled;
    notifyListeners();
  }

  Future<void> setFontSize(LexiconFontSize size) async {
    _fontSize = size;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyFontSize, size.index);
    notifyListeners();
  }

  Future<void> setMinimalMode(bool value) async {
    _minimalMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyMinimalMode, value);
    notifyListeners();
  }

  Future<void> setDyslexiaMode(bool value) async {
    _dyslexiaMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyDyslexiaMode, value);
    notifyListeners();
  }

  Future<void> setColorblindMode(bool value) async {
    _colorblindMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyColorblindMode, value);
    notifyListeners();
  }

  Future<void> setSystemLookup(bool value) async {
    _systemLookup = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keySystemLookup, value);
    notifyListeners();
  }

  Future<void> setFloatingBubble(bool value) async {
    _floatingBubble = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyFloatingBubble, value);
    notifyListeners();
  }


  Future<void> installOfflineLibrary() async {
    _isDownloading = true;
    _downloadProgress = 0.0;
    notifyListeners();

    try {
      await OfflineDictionaryService.instance.downloadDictionary(
        onProgress: (progress) {
          _downloadProgress = progress;
          notifyListeners();
        },
      );
      _offlineDownloaded = true;
    } catch (_) {
      _offlineDownloaded = false;
    } finally {
      _isDownloading = false;
      notifyListeners();
    }
  }

  Future<void> uninstallOfflineLibrary() async {
    await OfflineDictionaryService.instance.deleteDictionary();
    _offlineDownloaded = false;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyThemeMode, _themeMode.index);
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyThemeMode, mode.index);
    notifyListeners();
  }

  double get textScaleFactor {
    switch (_fontSize) {
      case LexiconFontSize.small:
        return 0.85;
      case LexiconFontSize.defaultSize:
        return 1.0;
      case LexiconFontSize.large:
        return 1.2;
      case LexiconFontSize.extraLarge:
        return 1.4;
    }
  }
}
