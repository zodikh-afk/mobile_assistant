import 'database_helper.dart';
import '../domain/entities/chat_entity.dart';
import '../domain/entities/message_entity.dart';
import '../domain/models/message_model.dart';
import '../domain/models/chat_model.dart';

class ChatRepository {
  final dbHelper = DatabaseHelper.instance;

  // Створення нового чату
  Future<ChatModel> createNewChat(String title) async {
    final db = await dbHelper.database;
    final entity =
        ChatEntity(title: title, createdAt: DateTime.now().toIso8601String());

    final id = await db.insert('chat_sessions', entity.toMap());

    return ChatModel(id: id, title: title, createdAt: DateTime.now());
  }

  // Отримання всіх чатів для шторки
  Future<List<ChatModel>> getAllChats() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps =
        await db.query('chat_sessions', orderBy: 'created_at DESC');

    return maps
        .map((map) => ChatModel.fromEntity(ChatEntity.fromMap(map)))
        .toList();
  }

  // Збереження повідомлення
  Future<void> saveMessage(int chatId, String text, bool isUser) async {
    final db = await dbHelper.database;
    final entity = MessageEntity(
      chatId: chatId,
      text: text,
      isUser: isUser ? 1 : 0,
    );
    await db.insert('messages', entity.toMap());
  }

  // Отримання повідомлень конкретного чату
  Future<List<MessageModel>> getMessages(int chatId) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'messages',
      where: 'chat_id = ?',
      whereArgs: [chatId],
      orderBy: 'created_at ASC',
    );

    return maps
        .map((map) => MessageModel(
              text: map['text'],
              isUser: map['is_user'] == 1,
            ))
        .toList();
  }
}
