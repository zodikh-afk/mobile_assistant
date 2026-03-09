class UserEntity {
  final String uid;
  final String username;
  final String email;
  final DateTime createdAt;

  UserEntity({
    required this.uid,
    required this.username,
    required this.email,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'username': username,
      'email': email,
      'createdAt': createdAt,
    };
  }
}
