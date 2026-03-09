class UserModel {
  final String id;
  final String username;
  final String email;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
  });

  factory UserModel.fromEntity(Map<String, dynamic> data) {
    return UserModel(
      id: data['uid'] ?? '',
      username: data['username'] ?? '',
      email: data['email'] ?? '',
    );
  }
}
