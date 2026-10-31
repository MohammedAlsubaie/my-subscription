import 'package:flutter/material.dart';

import 'strings.dart';
import 'settings_controller.dart';
import 'subscription.dart';
import 'app_theme.dart';
import 'date_utils.dart';

IconData categoryIcon(String category) {
  switch (category) {
    case 'Entertainment':
      return Icons.play_arrow_rounded;
    case 'Music':
      return Icons.music_note_rounded;
    case 'Gaming':
      return Icons.sports_esports_rounded;
    case 'Shopping':
      return Icons.shopping_bag_rounded;
    case 'Education':
      return Icons.school_rounded;
    case 'Cloud & Software':
      return Icons.cloud_rounded;
    default:
      return Icons.person_rounded;
  }
}

/// Icons the user can pick for a subscription.
const Map<String, IconData> kSubIcons = {
  'play': Icons.play_arrow_rounded,
  'movie': Icons.movie_rounded,
  'tv': Icons.tv_rounded,
  'music': Icons.music_note_rounded,
  'headphones': Icons.headphones_rounded,
  'game': Icons.sports_esports_rounded,
  'bag': Icons.shopping_bag_rounded,
  'cart': Icons.shopping_cart_rounded,
  'school': Icons.school_rounded,
  'book': Icons.menu_book_rounded,
  'cloud': Icons.cloud_rounded,
  'phone': Icons.smartphone_rounded,
  'wifi': Icons.wifi_rounded,
  'fitness': Icons.fitness_center_rounded,
  'food': Icons.restaurant_rounded,
  'car': Icons.directions_car_rounded,
  'home': Icons.home_rounded,
  'bolt': Icons.bolt_rounded,
  'heart': Icons.favorite_rounded,
  'star': Icons.star_rounded,
};

/// The icon shown for a subscription: the picked one, or one based on its category.
IconData iconForSub(Subscription s) {
  final picked = kSubIcons[s.iconKey];
  return picked ?? categoryIcon(s.category);
}

class SubscriptionTile extends StatelessWidget {
  final Subscription subscription;
  final VoidCallback onTap;

  const SubscriptionTile({
    super.key,
    required this.subscription,
    required this.onTap,
  });

  String _cycleLabel(BuildContext context) {
    switch (subscription.cycle) {
      case BillingCycle.monthly:
        return context.tr('monthly');
      case BillingCycle.quarterly:
        return context.tr('quarterly');
      case BillingCycle.yearly:
        return context.tr('yearly');
    }
  }

  String _subtitle(BuildContext context) {
    final s = subscription;
    if (!s.active) return context.tr('cancelled');
    final d = s.daysLeft;
    if (d == 0) return context.tr('renewsToday');
    if (d == 1) return context.tr('renewsTomorrow');
    if (d <= 7) return context.renewsIn(d);
    return '${context.tr('renews')} ${formatShort(s.nextRenewal, ar: context.isAr)}';
  }

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    final s = subscription;
    final soon = s.active && s.daysLeft <= 3;
    final nameColor = s.active ? p.text : p.subtext;

    return Material(
      color: p.surface,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: s.active ? Color(s.colorValue) : Color(s.colorValue).withAlpha(90),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  iconForSub(s),
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: nameColor,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _subtitle(context),
                      style: TextStyle(
                        color: soon ? p.danger : p.subtext,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${SettingsController.fromSar(s.price).toStringAsFixed(2)} ${context.currencyLabel}',
                    style: TextStyle(
                      color: s.active ? p.accent : p.subtext,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _cycleLabel(context),
                    style: TextStyle(color: p.subtext, fontSize: 13),
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