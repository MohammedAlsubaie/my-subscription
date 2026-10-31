import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'auth_service.dart';
import 'settings_controller.dart';
import 'settings_sheet.dart';
import 'strings.dart';

/// Login and "create account" in one screen.
class AuthScreen extends StatefulWidget {
  final SettingsController settings;
  final AuthService auth;
  final ValueChanged<AppUser> onAuthenticated;

  const AuthScreen({
    super.key,
    required this.settings,
    required this.auth,
    required this.onAuthenticated,
  });

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _register = false;
  bool _hidePass = true;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _busy = true;
      _error = null;
    });
    final result = _register
        ? await widget.auth
            .register(_nameCtrl.text, _emailCtrl.text, _passCtrl.text)
        : await widget.auth.login(_emailCtrl.text, _passCtrl.text);
    if (!mounted) return;
    final user = result.user;
    if (user != null) {
      widget.onAuthenticated(user);
    } else {
      setState(() {
        _busy = false;
        _error = result.error;
      });
    }
  }

  InputDecoration _dec(String label, IconData icon, {Widget? suffix}) {
    final p = AppPalette.of(context);
    OutlineInputBorder border(Color c, [double w = 0]) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: w == 0 ? BorderSide.none : BorderSide(color: c, width: w),
        );
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: p.subtext),
      floatingLabelStyle: TextStyle(color: p.accent),
      prefixIcon: Icon(icon, color: p.accent),
      suffixIcon: suffix,
      filled: true,
      fillColor: p.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      border: border(p.surface),
      enabledBorder: border(p.surface),
      focusedBorder: border(p.accent, 1.6),
      errorBorder: border(p.danger, 1.2),
      focusedErrorBorder: border(p.danger, 1.6),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: IconButton(
                  tooltip: context.tr('settings'),
                  icon: Icon(Icons.tune_rounded, color: p.accent),
                  onPressed: () => showSettingsSheet(context, widget.settings),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: p.gradient),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: p.gradient.first.withAlpha(80),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.subscriptions_rounded,
                      color: Colors.white, size: 44),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                context.tr(_register ? 'createAccount' : 'welcomeBack'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: p.text,
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                context.tr(_register ? 'registerSubtitle' : 'loginSubtitle'),
                textAlign: TextAlign.center,
                style: TextStyle(color: p.subtext, height: 1.4),
              ),
              const SizedBox(height: 28),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    AnimatedSize(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOutCubic,
                      alignment: Alignment.topCenter,
                      child: _register
                          ? Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: TextFormField(
                                controller: _nameCtrl,
                                textCapitalization: TextCapitalization.words,
                                textInputAction: TextInputAction.next,
                                style: TextStyle(color: p.text),
                                decoration: _dec(context.tr('fullName'),
                                    Icons.person_rounded),
                                validator: (v) =>
                                    (v == null || v.trim().isEmpty)
                                        ? context.tr('fullNameReq')
                                        : null,
                              ),
                            )
                          : const SizedBox(width: double.infinity),
                    ),
                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      textDirection: TextDirection.ltr,
                      autocorrect: false,
                      style: TextStyle(color: p.text),
                      decoration:
                          _dec(context.tr('email'), Icons.email_rounded),
                      validator: (v) {
                        final value = (v ?? '').trim();
                        if (value.isEmpty) return context.tr('emailReq');
                        final ok =
                            RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value);
                        return ok ? null : context.tr('emailInvalid');
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passCtrl,
                      obscureText: _hidePass,
                      textInputAction: TextInputAction.done,
                      textDirection: TextDirection.ltr,
                      onFieldSubmitted: (_) => _busy ? null : _submit(),
                      style: TextStyle(color: p.text),
                      decoration: _dec(
                        context.tr('password'),
                        Icons.lock_rounded,
                        suffix: IconButton(
                          icon: Icon(
                            _hidePass
                                ? Icons.visibility_rounded
                                : Icons.visibility_off_rounded,
                            color: p.subtext,
                          ),
                          onPressed: () =>
                              setState(() => _hidePass = !_hidePass),
                        ),
                      ),
                      validator: (v) {
                        final value = v ?? '';
                        if (value.isEmpty) return context.tr('passwordReq');
                        if (_register && value.length < 6) {
                          return context.tr('passwordShort');
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 14),
                Row(
                  children: [
                    Icon(Icons.error_outline_rounded,
                        color: p.danger, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        context.tr(_error!),
                        style: TextStyle(color: p.danger),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 24),
              Container(
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: p.gradient,
                    begin: AlignmentDirectional.centerStart,
                    end: AlignmentDirectional.centerEnd,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: p.gradient.first.withAlpha(70),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: _busy ? null : _submit,
                    child: Center(
                      child: _busy
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.6,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              context.tr(_register ? 'createAccount' : 'login'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    context.tr(_register ? 'haveAccount' : 'noAccount'),
                    style: TextStyle(color: p.subtext),
                  ),
                  TextButton(
                    onPressed: _busy
                        ? null
                        : () => setState(() {
                              _register = !_register;
                              _error = null;
                            }),
                    child: Text(
                      context.tr(_register ? 'login' : 'createAccount'),
                      style: TextStyle(
                        color: p.accent,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
