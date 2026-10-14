import 'package:intl/intl.dart';

final _money = NumberFormat('#,##0.00');

/// ₹1,234.00
String money(double v) => '${v < 0 ? '-' : ''}₹${_money.format(v.abs())}';

/// Tue, 22 Feb 2026
String fmtDate(DateTime d) => DateFormat('EEE, d MMM y').format(d);

/// Today / Yesterday / Jan 30, 2022
String relativeDate(DateTime d) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(d.year, d.month, d.day);
  final diff = today.difference(day).inDays;
  if (diff == 0) return 'Today';
  if (diff == 1) return 'Yesterday';
  return DateFormat('MMM d, y').format(d);
}