import 'package:flutter/material.dart';
import '../business_logic/ai_service.dart';
import '../business_logic/services/assistant_manager.dart';
import '../business_logic/commands/app_command_service.dart';
import 'login_screen.dart';
import 'settings_screen.dart';

import '../controllers/auth_controller.dart';
import '../repositories/auth_repository.dart';

import '../controllers/chat_controller.dart';
import '../repositories/chat_repository.dart';
import '../domain/view_models/chat_view_model.dart';
import '../domain/models/message_model.dart';

import '../controllers/profile_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _textController = TextEditingController();

  late final AuthController _authController;
  late final ChatController _chatController;
  late final AssistantManager _assistantManager;
  late final ProfileController _profileController;

  List<ChatViewModel> _chatHistory = [];
  List<MessageModel> _messages = [];

  ChatViewModel? _currentChat;
  bool _isLoading = false;
  String _userName = "Завантаження...";

  @override
  void initState() {
    super.initState();

    // Ініціалізація сервісів та контролерів
    final aiService = AIService();
    final commands = [AppCommandService()];

    _assistantManager = AssistantManager(aiService, commands);
    _authController = AuthController(AuthRepository());
    _chatController = ChatController(ChatRepository());
    _profileController = ProfileController();

    // Запуск початкової логіки додатка
    _initializeAppData();
  }

  // Метод для початкового налаштування при вході
  void _initializeAppData() async {
    // 1. Отримуємо логін користувача
    final name = await _profileController.getUsername();
    if (mounted && name != null) {
      setState(() => _userName = name);
    }

    // 2. Завантажуємо історію чатів
    final history = await _chatController.loadChatHistory();
    if (mounted) {
      setState(() => _chatHistory = history);
    }

    // 3. Автоматизація чату при вході
    if (history.isEmpty) {
      // Якщо чатів немає — створюємо новий автоматично
      _autoCreateFirstChat();
    } else {
      // Якщо чати є — відкриваємо останній
      _selectChat(history.first);
    }
  }

  void _autoCreateFirstChat() async {
    final newChat = await _chatController.startNewChat("Новий чат");
    if (newChat != null && mounted) {
      setState(() {
        _currentChat = newChat;
        _messages = [];
      });
      _loadChats();
    }
  }

  void _loadChats() async {
    final history = await _chatController.loadChatHistory();
    if (mounted) {
      setState(() => _chatHistory = history);
    }
  }

  void _selectChat(ChatViewModel chat) async {
    final history = await _chatController.getChatContent(chat.id);
    if (mounted) {
      setState(() {
        _currentChat = chat;
        _messages = history;
      });
    }
  }

  void _createNewChat() async {
    Navigator.pop(context);
    final newChat = await _chatController.startNewChat(
        "Новий чат ${DateTime.now().hour}:${DateTime.now().minute}");

    if (newChat != null && mounted) {
      setState(() {
        _currentChat = newChat;
        _messages = [];
      });
      _loadChats();
    }
  }

  void _deleteChat(int id) async {
    await _chatController.deleteChat(id);
    if (mounted) {
      if (_currentChat?.id == id) {
        setState(() {
          _currentChat = null;
          _messages = [];
        });
      }
      _loadChats();
    }
  }

  void _askGemini() async {
    if (_textController.text.isEmpty || _currentChat == null || _isLoading) {
      return;
    }

    FocusScope.of(context).unfocus();
    final userText = _textController.text;

    await _chatController.saveMessage(_currentChat!.id, userText, true);

    setState(() {
      _isLoading = true;
      _messages.add(MessageModel(text: userText, isUser: true));
      _textController.clear();
    });

    final aiResponse = await _assistantManager.processRequest(userText);
    await _chatController.saveMessage(_currentChat!.id, aiResponse, false);

    if (mounted) {
      setState(() {
        _messages.add(MessageModel(text: aiResponse, isUser: false));
        _isLoading = false;
      });
    }
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
      appBar: AppBar(
        title: Text(_currentChat?.displayTitle ?? "Gemini Assistant"),
      ),
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              // Шапка з логіном користувача
              UserAccountsDrawerHeader(
                accountName: Text(
                  _userName,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                accountEmail: null, // Приховуємо пошту за запитом
                currentAccountPicture: const CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 40, color: Colors.blueAccent),
                ),
                decoration: const BoxDecoration(color: Colors.blueAccent),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton.icon(
                  onPressed: _createNewChat,
                  icon: const Icon(Icons.add),
                  label: const Text("Новий чат"),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 45),
                  ),
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
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline,
                            color: Colors.grey),
                        onPressed: () => _deleteChat(chat.id),
                      ),
                      onTap: () => _selectChat(chat),
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
                        builder: (context) => const SettingsScreen()),
                  );
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
            Expanded(
              child: _messages.isEmpty
                  ? Center(
                      child: Text(
                        _currentChat == null
                            ? "Створюємо чат..."
                            : "Почніть розмову!",
                        style:
                            const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
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
              enabled: _currentChat != null && !_isLoading,
              decoration: InputDecoration(
                hintText:
                    _currentChat == null ? "Зачекайте..." : "Запитай щось...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.mic_none),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Голосовий ввід скоро з'явиться!")),
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.send,
                        color: _isLoading ? Colors.grey : Colors.blue,
                      ),
                      onPressed: _isLoading ? null : _askGemini,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
