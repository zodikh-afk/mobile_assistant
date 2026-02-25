class UserModel {
  final String id;
  final String username;
  final String email;

  // Конструктор
  UserModel({
    required this.id,
    required this.username,
    required this.email,
  });

  // Метод для перетворення даних з Firebase у наш клас
  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      id: data['uid'] ?? '',
      username: data['username'] ?? '',
      email: data['email'] ?? '',
    );
  }
}
