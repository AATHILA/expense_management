class UserProfile {
  final String name;
  final String? photoPath;

  const UserProfile({required this.name, this.photoPath});

  static const defaults = UserProfile(name: 'Sahal Muhammed');

  UserProfile withName(String n) => UserProfile(name: n, photoPath: photoPath);
  UserProfile withPhoto(String? path) =>
      UserProfile(name: name, photoPath: path);

  Map<String, dynamic> toMap() => {
        'id': 1, // single-row table
        'name': name,
        'photo_path': photoPath,
      };

  factory UserProfile.fromMap(Map<String, dynamic> m) => UserProfile(
        name: m['name'] as String,
        photoPath: m['photo_path'] as String?,
      );
}
