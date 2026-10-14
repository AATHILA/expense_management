import 'package:flutter/foundation.dart';

import '../data/database_helper.dart';
import '../models/credit.dart';

class CreditProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;

  List<Credit> _credits = [];
  bool _loading = true;
  String? _error;

  List<Credit> get credits => List.unmodifiable(_credits);
  bool get isLoading => _loading;
  String? get error => _error;

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    try {
      _credits = await _db.getCredits();
      _error = null;
    } on DbFailure catch (e) {
      _error = e.message;
    }
    _loading = false;
    notifyListeners();
  }

  /// Each returns null on success or an error message on failure.
  Future<String?> add(Credit c) => _run(() => _db.insertCredit(c));
  Future<String?> delete(int id) => _run(() => _db.deleteCredit(id));
  Future<String?> clearAll() => _run(() => _db.deleteAllCredits());

  Future<String?> _run(Future<Object?> Function() action) async {
    try {
      await action();
      _credits = await _db.getCredits();
      _error = null;
      notifyListeners();
      return null;
    } on DbFailure catch (e) {
      return e.message;
    }
  }
}
