import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'auth_screen.dart';
import 'auth_service.dart';
import 'home_screen.dart';
import 'settings_controller.dart';
import 'app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final settings = SettingsController();
  await settings.load();
  runApp(MySubscriptionApp(settings: settings));
}

class MySubscriptionApp extends StatelessWidget {
  final SettingsController settings;

  const MySubscriptionApp({super.key, required this.settings});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) {
        return MaterialApp(
          title: 'My Subscriptions',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: settings.themeMode,
          locale: settings.locale,
          supportedLocales: const [Locale('en'), Locale('ar')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: AuthGate(settings: settings),
        );
      },
    );
  }
}

/// Shows the login screen, or the home screen when a user is signed in.
class AuthGate extends StatefulWidget {
  final SettingsController settings;

  const AuthGate({super.key, required this.settings});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final AuthService _auth = AuthService();
  AppUser? _user;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _restore();
  }

  Future<void> _restore() async {
    final user = await _auth.currentUser();
    if (!mounted) return;
    setState(() {
      _user = user;
      _loading = false;
    });
  }

  Future<void> _logout() async {
    await _auth.logout();
    if (!mounted) return;
    setState(() => _user = null);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final user = _user;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: user == null
          ? AuthScreen(
              key: const ValueKey('auth'),
              settings: widget.settings,
              auth: _auth,
              onAuthenticated: (u) => setState(() => _user = u),
            )
          : HomeScreen(
              key: ValueKey('home-${user.id}'),
              settings: widget.settings,
              user: user,
              onLogout: _logout,
            ),
    );
  }
}
