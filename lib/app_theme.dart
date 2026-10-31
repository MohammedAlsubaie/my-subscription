import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// All the colors of the app in one place (one set for dark, one for light).
class AppPalette {
  final Color bg;
  final Color surface;
  final Color text;
  final Color subtext;
  final Color accent;
  final Color avatarBg;
  final Color avatarIcon;
  final Color danger;
  final List<Color> gradient;

  const AppPalette({
    required this.bg,
    required this.surface,
    required this.text,
    required this.subtext,
    required this.accent,
    required this.avatarBg,
    required this.avatarIcon,
    required this.danger,
    required this.gradient,
  });

  static const AppPalette dark = AppPalette(
    bg: Color(0xFF0E1525),
    surface: Color(0xFF1B2437),
    text: Color(0xFFEAF0FB),
    subtext: Color(0xFF9AA7BD),
    accent: Color(0xFF8B8DF5),
    avatarBg: Color(0xFF0F5A82),
    avatarIcon: Color(0xFFFFFFFF),
    danger: Color(0xFFE5484D),
    gradient: [Color(0xFF5B4BE0), Color(0xFF0EA5E9)],
  );

  static const AppPalette light = AppPalette(
    bg: Color(0xFFF3F5FC),
    surface: Color(0xFFFFFFFF),
    text: Color(0xFF172033),
    subtext: Color(0xFF6B778C),
    accent: Color(0xFF5B5BE0),
    avatarBg: Color(0xFFDCEBFF),
    avatarIcon: Color(0xFF1D6FA5),
    danger: Color(0xFFE5484D),
    gradient: [Color(0xFF6C5CE7), Color(0xFF38BDF8)],
  );

  static AppPalette of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? dark : light;
}

class AppTheme {
  static ThemeData get dark => _build(AppPalette.dark, Brightness.dark);
  static ThemeData get light => _build(AppPalette.light, Brightness.light);

  static ThemeData _build(AppPalette p, Brightness b) {
    final scheme = ColorScheme.fromSeed(
      seedColor: p.accent,
      brightness: b,
    ).copyWith(
      primary: p.accent,
      onPrimary: Colors.white,
      surface: p.surface,
      onSurface: p.text,
      error: p.danger,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: b,
      colorScheme: scheme,
      scaffoldBackgroundColor: p.bg,
      splashFactory: InkRipple.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: p.bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: p.text,
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: p.accent),
        actionsIconTheme: IconThemeData(color: p.accent),
        systemOverlayStyle: b == Brightness.dark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: p.accent,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: p.surface,
        contentTextStyle: TextStyle(color: p.text),
        actionTextColor: p.accent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}