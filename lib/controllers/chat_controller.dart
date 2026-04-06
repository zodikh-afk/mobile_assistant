import '../business_logic/services/chat_service.dart';
import '../business_logic/services/assistant_service.dart';
import '../business_logic/services/ai_service.dart';
import '../business_logic/commands/app_command_service.dart';
import '../business_logic/commands/time_command_service.dart';

import '../repositories/chat_repository.dart';
import '../domain/view_models/chat_view_model.dart';
import '../domain/view_models/message_view_model.dart';

class ChatController {
  late final ChatService _chatService;
  late final AssistantService _assistantService;

  ChatController() {
    // 1. Ініціалізуємо базу даних
    final chatRepository = ChatRepository();
    _chatService = ChatService(chatRepository);

    // 2. Ініціалізуємо ШІ та команди
    final aiService = AIService();
    final commands = [
      AppCommandService(),
      TimeCommandService(),
    ];
    _assistantService = AssistantService(aiService, commands);
  }

  Future<List<ChatViewModel>> loadChatHistory() async {
    final chats = await _chatService.getAllChats();
    return chats
        .map((c) => ChatViewModel(id: c.id, displayTitle: c.title))
        .toList();
  }

  Future<ChatViewModel?> startNewChat(String title) async {
    final chat = await _chatService.createNewChat(title);
    // Використовуємо displayTitle замість title та createdAt
    return ChatViewModel(id: chat.id, displayTitle: chat.title);
  }

  Future<List<MessageViewModel>> getChatContent(int chatId) async {
    // 1. Отримуємо сирі моделі з бази даних через сервіс
    final messages = await _chatService.getMessages(chatId);

    // 2. Трансформуємо кожну MessageModel у MessageViewModel
    return messages
        .map((m) => MessageViewModel(
              text: m.text,
              isUser: m.isUser,
            ))
        .toList();
  }

  Future<void> deleteChat(int chatId) async {
    await _chatService.deleteChat(chatId);
  }

  Future<void> saveMessage(int chatId, String text, bool isUser) async {
    await _chatService.saveMessage(chatId, text, isUser);
  }

  Future<String> handleUserMessage(int chatId, String text) async {
    String aiResponse = await _assistantService.processRequest(text);
    return aiResponse;
  }
}
