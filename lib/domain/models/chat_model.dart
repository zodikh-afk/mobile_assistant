import '../entities/chat_entity.dart';

class ChatModel {
  final int id;
  final String title;
  final DateTime createdAt;

  ChatModel({required this.id, required this.title, required this.createdAt});

  factory ChatModel.fromEntity(ChatEntity entity) {
    return ChatModel(
      id: entity.id ?? 0,
      title: entity.title,
      createdAt: DateTime.parse(entity.createdAt),
    );
  }
}
