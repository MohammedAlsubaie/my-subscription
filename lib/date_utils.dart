const List<String> _monthsEn = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

const List<String> _monthsAr = [
  'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
  'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
];

/// Strips the time part of a date.
DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// Adds [months] to [d], clamping the day (e.g. 31 Jan + 1 month = 28/29 Feb).
DateTime addMonths(DateTime d, int months) {
  final total = d.month - 1 + months;
  final year = d.year + total ~/ 12;
  final month = total % 12 + 1;
  final lastDay = DateTime(year, month + 1, 0).day;
  return DateTime(year, month, d.day > lastDay ? lastDay : d.day);
}

/// Example: 5 Mar 2026
String formatDate(DateTime d, {bool ar = false}) {
  final m = (ar ? _monthsAr : _monthsEn)[d.month - 1];
  return '${d.day} $m ${d.year}';
}

/// Example: Nov 17 (the year is added only if it is not the current year)
String formatShort(DateTime d, {bool ar = false}) {
  final m = (ar ? _monthsAr : _monthsEn)[d.month - 1];
  final y = d.year == DateTime.now().year ? '' : ' ${d.year}';
  return ar ? '${d.day} $m$y' : '$m ${d.day}$y';
}