class User {
  final String uid;
  final String name;
  final String email;
  final List<String> interests;
  final String level;

  User({required this.uid, required this.name, required this.email, required this.interests, required this.level});

  factory User.fromMap(Map<String, dynamic> data, String uid) {
    return User(
      uid: uid,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      interests: List<String>.from(data['interests'] ?? []),
      level: data['level'] ?? 'unknown',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'interests': interests,
      'level': level,
    };
  }
}