import 'package:flutter/foundation.dart';

import '../data/database_helper.dart';
import '../models/expense.dart';

class ExpenseProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;

  List<Expense> _expenses = [];
  bool _loading = true;
  String? _error;

  List<Expense> get expenses => List.unmodifiable(_expenses);
  bool get isLoading => _loading;
  String? get error => _error;

  double get totalIncome =>
      _expenses.where((e) => e.isCredit).fold(0, (s, e) => s + e.amount);

  double get totalExpense =>
      _expenses.where((e) => !e.isCredit).fold(0, (s, e) => s + e.amount);

  double get balance => totalIncome - totalExpense;

  double get todayTotal {
    final now = DateTime.now();
    return _expenses
        .where((e) => !e.isCredit)
        .where((e) =>
    e.date.year == now.year &&
        e.date.month == now.month &&
        e.date.day == now.day)
        .fold(0, (s, e) => s + e.amount);
  }

  /// Sum of expenses from Monday of the current week until now.
  double get weekTotal {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));
    return _expenses
        .where((e) => !e.isCredit)
        .where((e) => !e.date.isBefore(start))
        .fold(0, (s, e) => s + e.amount);
  }

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    try {
      _expenses = await _db.getAll();
      _error = null;
    } on DbFailure catch (e) {
      _error = e.message;
    }
    _loading = false;
    notifyListeners();
  }

  /// Each returns null on success or an error message on failure.
  Future<String?> add(Expense e) => _run(() => _db.insert(e));
  Future<String?> update(Expense e) => _run(() => _db.update(e));
  Future<String?> delete(int id) => _run(() => _db.delete(id));
  Future<String?> clearAll() => _run(() => _db.deleteAllExpenses());

  Future<String?> _run(Future<Object?> Function() action) async {
    try {
      await action();
      _expenses = await _db.getAll(); // list + totals refresh automatically
      _error = null;
      notifyListeners();
      return null;
    } on DbFailure catch (e) {
      return e.message;
    }
  }
}