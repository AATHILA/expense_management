import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../data/database_helper.dart';
import '../models/user_profile.dart';

class ProfileProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;

  UserProfile _profile = UserProfile.defaults;
  UserProfile get profile => _profile;

  Future<void> load() async {
    try {
      _profile = await _db.getProfile();
    } on DbFailure {
      // keep defaults if the profile can't be read
    }
    notifyListeners();
  }

  /// Each returns null on success or an error message on failure.
  Future<String?> updateName(String name) => _save(_profile.withName(name));

  Future<String?> updatePhoto(String pickedPath) async {
    try {
      // Copy into app storage so the image survives cache clean-ups.
      final dir = await getApplicationDocumentsDirectory();
      final dest = p.join(dir.path,
          'profile_${DateTime.now().millisecondsSinceEpoch}${p.extension(pickedPath)}');
      await File(pickedPath).copy(dest);
      final old = _profile.photoPath;
      final err = await _save(_profile.withPhoto(dest));
      if (err == null && old != null) _deleteFile(old);
      return err;
    } catch (_) {
      return 'Could not save the photo.';
    }
  }

  Future<String?> removePhoto() async {
    final old = _profile.photoPath;
    final err = await _save(_profile.withPhoto(null));
    if (err == null && old != null) _deleteFile(old);
    return err;
  }

  Future<String?> _save(UserProfile next) async {
    try {
      await _db.saveProfile(next);
      _profile = next;
      notifyListeners();
      return null;
    } on DbFailure catch (e) {
      return e.message;
    }
  }

  void _deleteFile(String path) {
    try {
      final f = File(path);
      if (f.existsSync()) f.deleteSync();
    } catch (_) {}
  }
}
