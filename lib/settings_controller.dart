import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Holds the theme mode (light / dark / system) and the language (en / ar).
/// Both choices are saved on the device.
class SettingsController extends ChangeNotifier {
  static const _themeKey = 'themeMode';
  static const _langKey = 'lang';

  /// Currencies the user can choose from (labels only, no conversion).
  static const List<String> currencies = ['SAR', 'USD', 'GBP'];

  /// The selected currency code, read by the whole app.
  static String currency = 'SAR';

  /// Approximate exchange rates. All prices are stored in Saudi Riyal (SAR)
  /// and converted to the selected currency only when shown.
  static const Map<String, double> _perSar = {
    'SAR': 1.0,
    'USD': 1 / 3.75, // the riyal is pegged to the dollar
    'GBP': 1 / 4.9,
  };

  /// Converts an amount in SAR to the selected currency.
  static double fromSar(double sar) => sar * _perSar[currency]!;

  /// Converts an amount in the selected currency back to SAR.
  static double toSar(double value) => value / _perSar[currency]!;

  static const _currencyKey = 'currency';

  ThemeMode _themeMode = ThemeMode.dark;
  Locale _locale = const Locale('en');

  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final mode = prefs.getString(_themeKey);
    final lang = prefs.getString(_langKey);
    final cur = prefs.getString(_currencyKey);
    if (cur != null && currencies.contains(cur)) currency = cur;
    if (mode != null) {
      _themeMode = ThemeMode.values.firstWhere(
            (m) => m.name == mode,
        orElse: () => ThemeMode.dark,
      );
    }
    if (lang == 'ar' || lang == 'en') {
      _locale = Locale(lang!);
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, mode.name);
  }

  Future<void> setCurrency(String code) async {
    currency = code;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currencyKey, code);
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_langKey, locale.languageCode);
  }
}