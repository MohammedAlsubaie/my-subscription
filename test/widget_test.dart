import 'package:flutter_test/flutter_test.dart';
import 'package:mysub/subscription.dart';

Subscription _sub(double price, BillingCycle cycle, {String group = 'Personal'}) {
  final now = DateTime(2026, 1, 1);
  return Subscription(
    id: '1',
    name: 'Test',
    price: price,
    cycle: cycle,
    category: 'Other',
    startDate: now,
    renewalDate: now,
    group: group,
  );
}

void main() {
  test('monthly and yearly cost follow the billing cycle', () {
    expect(_sub(30, BillingCycle.monthly).monthlyCost, 30);
    expect(_sub(30, BillingCycle.monthly).yearlyCost, 360);
    expect(_sub(120, BillingCycle.yearly).monthlyCost, 10);
    expect(_sub(90, BillingCycle.quarterly).yearlyCost, 360);
  });

  test('next renewal is never in the past', () {
    final s = _sub(10, BillingCycle.monthly);
    expect(s.daysLeft >= 0, true);
  });

  test('group is saved and restored from JSON', () {
    final s = _sub(10, BillingCycle.monthly, group: 'Work');
    expect(Subscription.fromJson(s.toJson()).group, 'Work');
  });

  test('old data without a group goes to Personal', () {
    final json = _sub(10, BillingCycle.monthly).toJson()..remove('group');
    expect(Subscription.fromJson(json).group, 'Personal');
  });
}
