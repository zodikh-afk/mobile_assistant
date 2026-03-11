class MessageEntity {
  final int? id;
  final int chatId;
  final String text;
  final int isUser; // 1 - користувач, 0 - Gemini

  MessageEntity(
      {this.id,
      required this.chatId,
      required this.text,
      required this.isUser});

  Map<String, dynamic> toMap() {
    return {
      'chat_id': chatId,
      'text': text,
      'is_user': isUser,
      'created_at': DateTime.now().toIso8601String()
    };
  }
}
