import '../../repositories/chat_repository.dart';
import '../../domain/models/chat_model.dart';
import '../../domain/models/message_model.dart';

class ChatService {
  final ChatRepository _repository;

  ChatService(this._repository);

  Future<ChatModel> createNewChat(String title) =>
      _repository.createNewChat(title);

  Future<List<ChatModel>> getAllChats() => _repository.getAllChats();

  Future<void> saveMessage(int chatId, String text, bool isUser) =>
      _repository.saveMessage(chatId, text, isUser);

  Future<List<MessageModel>> getMessages(int chatId) =>
      _repository.getMessages(chatId);

  Future<void> deleteChat(int chatId) => _repository.deleteChat(chatId);
}
