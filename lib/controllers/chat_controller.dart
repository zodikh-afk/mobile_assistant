import '../repositories/chat_repository.dart';
import '../domain/view_models/chat_view_model.dart';
import '../domain/models/message_model.dart';

class ChatController {
  final ChatRepository _repository;

  ChatController(this._repository);

  // Отримуємо чати і одразу перетворюємо їх у ViewModel для екрану
  Future<List<ChatViewModel>> loadChatHistory() async {
    try {
      final models = await _repository.getAllChats();
      return models.map((model) => ChatViewModel.fromModel(model)).toList();
    } catch (e) {
      print("Помилка завантаження чатів: $e");
      return [];
    }
  }

  // Створюємо новий чат
  Future<ChatViewModel?> startNewChat(String title) async {
    try {
      final model = await _repository.createNewChat(title);
      return ChatViewModel.fromModel(model);
    } catch (e) {
      print("Помилка створення чату: $e");
      return null;
    }
  }

  // Отримати всі репліки для конкретного чату
  Future<List<MessageModel>> getChatContent(int chatId) async {
    try {
      return await _repository.getMessages(chatId);
    } catch (e) {
      return [];
    }
  }

  // Логіка відправки повідомлення
  Future<void> saveMessage(int chatId, String text, bool isUser) async {
    await _repository.saveMessage(chatId, text, isUser);
  }
}
