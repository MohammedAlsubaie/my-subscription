import 'date_utils.dart';

/// Currency label shown in the app. Change it to your own currency.
const String kCurrency = 'SAR';

/// Default circle color of a subscription (a calm blue).
const int kDefaultSubColor = 0xFF0F5A82;

/// Colors the user can pick for a subscription.
const List<int> kSubColors = [
  0xFFE5484D, // red
  0xFFF76B15, // orange
  0xFFF5B800, // amber
  0xFF30A46C, // green
  0xFF0F5A82, // blue
  0xFF3E63DD, // indigo
  0xFF8E4EC6, // purple
  0xFFD6409F, // pink
  0xFF6F7B8A, // grey
];

const List<String> kCategories = [
  'Entertainment',
  'Music',
  'Gaming',
  'Shopping',
  'Education',
  'Cloud & Software',
  'Other',
];

/// Groups the user can split subscriptions into (work, home, ...).
const List<String> kGroups = ['Personal', 'Work', 'Home', 'Family'];

/// Label of a group: built-in groups are translated, custom ones shown as typed.
String groupLabel(String g, String Function(String) tr) =>
    kGroups.contains(g) ? tr('grp.$g') : g;

enum BillingCycle { monthly, quarterly, yearly }

extension BillingCycleX on BillingCycle {
  String get label {
    switch (this) {
      case BillingCycle.monthly:
        return 'Monthly';
      case BillingCycle.quarterly:
        return 'Quarterly';
      case BillingCycle.yearly:
        return 'Yearly';
    }
  }

  int get months {
    switch (this) {
      case BillingCycle.monthly:
        return 1;
      case BillingCycle.quarterly:
        return 3;
      case BillingCycle.yearly:
        return 12;
    }
  }
}

class Subscription {
  final String id;
  final String name;
  final double price;
  final BillingCycle cycle;
  final String category;
  final DateTime startDate;
  final DateTime renewalDate;
  final bool active;
  final String group;
  final int colorValue;
  final String iconKey;

  const Subscription({
    required this.id,
    required this.name,
    required this.price,
    required this.cycle,
    required this.category,
    required this.startDate,
    required this.renewalDate,
    this.active = true,
    this.group = 'Personal',
    this.colorValue = kDefaultSubColor,
    this.iconKey = 'auto',
  });

  /// Cost per month, based on the billing cycle.
  double get monthlyCost => price / cycle.months;

  /// Cost per year, based on the billing cycle.
  double get yearlyCost => price * 12 / cycle.months;

  /// The next renewal date that is today or later. If the saved renewal date
  /// is in the past, it is rolled forward by the billing cycle.
  DateTime get nextRenewal {
    final today = dateOnly(DateTime.now());
    final base = dateOnly(renewalDate);
    var n = 0;
    var d = base;
    while (d.isBefore(today)) {
      n++;
      d = addMonths(base, cycle.months * n);
    }
    return d;
  }

  int get daysLeft => nextRenewal.difference(dateOnly(DateTime.now())).inDays;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'price': price,
    'cycle': cycle.name,
    'category': category,
    'startDate': startDate.toIso8601String(),
    'renewalDate': renewalDate.toIso8601String(),
    'active': active,
    'group': group,
    'color': colorValue,
    'icon': iconKey,
  };

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      cycle: BillingCycle.values.firstWhere(
            (c) => c.name == json['cycle'],
        orElse: () => BillingCycle.monthly,
      ),
      category: json['category'] as String? ?? 'Other',
      startDate: DateTime.parse(json['startDate'] as String),
      renewalDate: DateTime.parse(json['renewalDate'] as String),
      active: json['active'] as bool? ?? true,
      group: json['group'] as String? ?? 'Personal',
      colorValue: (json['color'] as num?)?.toInt() ?? kDefaultSubColor,
      iconKey: json['icon'] as String? ?? 'auto',
    );
  }
}