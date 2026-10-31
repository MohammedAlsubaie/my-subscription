import 'package:flutter/material.dart';

import 'strings.dart';
import 'settings_controller.dart';
import 'app_theme.dart';

/// The big gradient card with the total monthly and yearly cost.
class SummaryCard extends StatelessWidget {
  final double monthly;
  final double yearly;

  const SummaryCard({super.key, required this.monthly, required this.yearly});

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 22, 24, 22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: p.gradient,
          begin: AlignmentDirectional.centerStart,
          end: AlignmentDirectional.centerEnd,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: p.gradient.first.withAlpha(70),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('totalExpenses'),
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 6),
                _Money(value: monthly, size: 36),
                const SizedBox(height: 2),
                Text(
                  context.tr('perMonth'),
                  style: const TextStyle(color: Color(0xCCFFFFFF), fontSize: 15),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _Money(value: yearly, size: 24),
              const SizedBox(height: 2),
              Text(
                context.tr('perYear'),
                style: const TextStyle(color: Color(0xCCFFFFFF), fontSize: 15),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// A number that counts up smoothly whenever the value changes.
class _Money extends StatelessWidget {
  final double value;
  final double size;

  const _Money({required this.value, required this.size});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: value),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutCubic,
      builder: (context, v, _) {
        return Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: SettingsController.fromSar(v).toStringAsFixed(2),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: size,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                text: ' ${context.currencyLabel}',
                style: TextStyle(
                  color: const Color(0xE6FFFFFF),
                  fontSize: size * 0.45,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}