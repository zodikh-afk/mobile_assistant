import 'package:flutter/material.dart';
import '../business_logic/ai_service.dart';
import 'login_screen.dart';
import 'settings_screen.dart';

import '../controllers/auth_controller.dart';
import '../repositories/auth_repository.dart';

import '../controllers/chat_controller.dart';
import '../repositories/chat_repository.dart';
import '../domain/view_models/chat_view_model.dart';
import '../domain/models/message_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AIService _aiService = AIService();
  final TextEditingController _textController = TextEditingController();

  late final AuthController _authController;
  late final ChatController _chatController;

  List<ChatViewModel> _chatHistory = [];
  // ОСЬ ЦЬОГО РЯДКА НЕ ВИСТАЧАЛО:
  List<MessageModel> _messages = [];

  ChatViewModel? _currentChat;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _authController = AuthController(AuthRepository());
    _chatController = ChatController(ChatRepository());
    _loadChats();
  }

  void _loadChats() async {
    final history = await _chatController.loadChatHistory();
    setState(() {
      _chatHistory = history;
    });
  }

  void _createNewChat() async {
    Navigator.pop(context);
    final newChat = await _chatController.startNewChat(
        "Новий чат ${DateTime.now().hour}:${DateTime.now().minute}");

    if (newChat != null) {
      setState(() {
        _currentChat = newChat;
        _messages = []; // Очищаємо екран для нового чату
      });
      _loadChats();
    }
  }

  void _askGemini() async {
    if (_textController.text.isEmpty || _currentChat == null) return;

    final userText = _textController.text;

    // 1. Зберігаємо запит користувача в БД
    await _chatController.saveMessage(_currentChat!.id, userText, true);

    setState(() {
      _isLoading = true;
      _messages.add(MessageModel(text: userText, isUser: true));
      _textController.clear();
    });

    // 2. Отримуємо відповідь від Gemini
    final aiResponse = await _aiService.getResponse(userText);

    // 3. Зберігаємо відповідь Gemini в БД
    await _chatController.saveMessage(_currentChat!.id, aiResponse, false);

    setState(() {
      _messages.add(MessageModel(text: aiResponse, isUser: false));
      _isLoading = false;
    });
  }

  void _handleLogout() async {
    await _authController.handleLogout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: Text(_currentChat?.displayTitle ?? "Gemini Assistant")),
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton.icon(
                  onPressed: _createNewChat,
                  icon: const Icon(Icons.add),
                  label: const Text("Новий чат"),
                ),
              ),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: _chatHistory.length,
                  itemBuilder: (context, index) {
                    final chat = _chatHistory[index];
                    return ListTile(
                      leading: const Icon(Icons.chat_bubble_outline),
                      title: Text(chat.displayTitle),
                      selected: _currentChat?.id == chat.id,
                      onTap: () async {
                        // ЗАВАНТАЖЕННЯ ІСТОРІЇ ПРИ НАТИСКАННІ НА ЧАТ
                        final history =
                            await _chatController.getChatContent(chat.id);
                        setState(() {
                          _currentChat = chat;
                          _messages = history;
                        });
                        if (!mounted) return;
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Налаштування'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SettingsScreen()));
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Вийти', style: TextStyle(color: Colors.red)),
                onTap: _handleLogout,
              ),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // ВІДОБРАЖЕННЯ СПИСКУ ПОВІДОМЛЕНЬ
            Expanded(
              child: _messages.isEmpty
                  ? const Center(child: Text("Почніть розмову!"))
                  : ListView.builder(
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final msg = _messages[index];
                        return Align(
                          alignment: msg.isUser
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: msg.isUser
                                  ? Colors.blue[100]
                                  : Colors.grey[200],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(msg.text),
                          ),
                        );
                      },
                    ),
            ),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(),
              ),
            const SizedBox(height: 10),
            TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: _currentChat == null
                    ? "Створіть чат у меню..."
                    : "Запитай щось...",
                enabled: _currentChat != null,
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _askGemini,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
