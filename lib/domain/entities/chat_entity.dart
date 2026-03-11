class ChatEntity {
  final int? id;
  final String title;
  final String createdAt;

  ChatEntity({this.id, required this.title, required this.createdAt});

  Map<String, dynamic> toMap() {
    return {'id': id, 'title': title, 'created_at': createdAt};
  }

  factory ChatEntity.fromMap(Map<String, dynamic> map) {
    return ChatEntity(
      id: map['id'],
      title: map['title'],
      createdAt: map['created_at'],
    );
  }
}
