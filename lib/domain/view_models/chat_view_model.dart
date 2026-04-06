import '../models/chat_model.dart';

class ChatViewModel {
  final int id;
  final String displayTitle;

  ChatViewModel({required this.id, required this.displayTitle});

  factory ChatViewModel.fromModel(ChatModel model) {
    return ChatViewModel(
      id: model.id,
      displayTitle: model.title,
    );
  }
}
