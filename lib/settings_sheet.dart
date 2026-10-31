import 'package:flutter/material.dart';

import 'strings.dart';
import 'settings_controller.dart';
import 'app_theme.dart';

/// Bottom sheet where the user picks the theme and the language.
Future<void> showSettingsSheet(
    BuildContext context,
    SettingsController settings,
    ) {
  final p = AppPalette.of(context);
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: p.surface,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (_) => ListenableBuilder(
      listenable: settings,
      builder: (ctx, _) => _SettingsBody(settings: settings, ctx: ctx),
    ),
  );
}

class _SettingsBody extends StatelessWidget {
  final SettingsController settings;
  final BuildContext ctx;

  const _SettingsBody({required this.settings, required this.ctx});

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(ctx);
    final style = SegmentedButton.styleFrom(
      backgroundColor: p.bg,
      foregroundColor: p.subtext,
      selectedBackgroundColor: p.accent,
      selectedForegroundColor: Colors.white,
      side: BorderSide.none,
    );

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              ctx.tr('settings'),
              style: TextStyle(
                color: p.text,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 20),
            Text(ctx.tr('theme'), style: TextStyle(color: p.subtext)),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<ThemeMode>(
                showSelectedIcon: false,
                style: style,
                segments: [
                  ButtonSegment(
                    value: ThemeMode.light,
                    icon: const Icon(Icons.light_mode_outlined, size: 18),
                    label: Text(ctx.tr('light')),
                  ),
                  ButtonSegment(
                    value: ThemeMode.dark,
                    icon: const Icon(Icons.dark_mode_outlined, size: 18),
                    label: Text(ctx.tr('dark')),
                  ),
                  ButtonSegment(
                    value: ThemeMode.system,
                    icon: const Icon(Icons.brightness_auto_outlined, size: 18),
                    label: Text(ctx.tr('system')),
                  ),
                ],
                selected: {settings.themeMode},
                onSelectionChanged: (s) => settings.setThemeMode(s.first),
              ),
            ),
            const SizedBox(height: 20),
            Text(ctx.tr('currency'), style: TextStyle(color: p.subtext)),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<String>(
                showSelectedIcon: false,
                style: style,
                segments: [
                  for (final c in SettingsController.currencies)
                    ButtonSegment(value: c, label: Text(c)),
                ],
                selected: {SettingsController.currency},
                onSelectionChanged: (s) => settings.setCurrency(s.first),
              ),
            ),
            const SizedBox(height: 20),
            Text(ctx.tr('language'), style: TextStyle(color: p.subtext)),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<String>(
                showSelectedIcon: false,
                style: style,
                segments: const [
                  ButtonSegment(value: 'en', label: Text('English')),
                  ButtonSegment(value: 'ar', label: Text('العربية')),
                ],
                selected: {settings.locale.languageCode},
                onSelectionChanged: (s) =>
                    settings.setLocale(Locale(s.first)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}