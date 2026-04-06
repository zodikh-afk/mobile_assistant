import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'login_screen.dart';
import 'settings_screen.dart';

import '../controllers/auth_controller.dart';
import '../controllers/profile_controller.dart';
import '../controllers/chat_controller.dart';
import '../controllers/voice_controller.dart';

import '../domain/view_models/chat_view_model.dart';
import '../domain/view_models/message_view_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _textController = TextEditingController();

  late final AuthController _authController;
  late final ChatController _chatController;
  late final ProfileController _profileController;
  late final VoiceController _voiceController;

  List<ChatViewModel> _chatHistory = [];
  List<MessageViewModel> _messages = [];

  ChatViewModel? _currentChat;
  bool _isLoading = false;
  String _userName = "Завантаження...";

  bool _isVoiceInitialized = false;
  bool _isListeningMode = false;

  @override
  void initState() {
    super.initState();

    _authController = AuthController();
    _profileController = ProfileController();
    _chatController = ChatController();
    _voiceController = VoiceController();

    _initVoiceService();
    _initializeAppData();
  }

  void _initVoiceService() async {
    _isVoiceInitialized = await _voiceController.initSpeech();
    if (mounted) setState(() {});
  }

  Future<void> requestOverlayPermission() async {
    if (!await Permission.systemAlertWindow.isGranted) {
      await Permission.systemAlertWindow.request();
    }
  }

  void _initializeAppData() async {
    final name = await _profileController.getUsername();

    // 2. Гарантовано оновлюємо UI
    if (mounted) {
      setState(() {
        _userName = name;
      });
    }

    final history = await _chatController.loadChatHistory();
    if (mounted) {
      setState(() => _chatHistory = history);
    }

    if (history.isEmpty) {
      _autoCreateFirstChat();
    } else {
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

  void _toggleVoiceMode() {
    if (!_isVoiceInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Мікрофон недоступний. Перевірте дозволи.")),
      );
      return;
    }

    if (_isListeningMode) {
      _voiceController.stopListening();
      setState(() => _isListeningMode = false);
    } else {
      setState(() => _isListeningMode = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Автономний режим увімкнено. Я вас слухаю.")),
      );

      _voiceController.startListening(
        (text) {
          if (text.isNotEmpty) {
            _processInput(text);
          }
        },
      );
    }
  }

  void _askGemini() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    _textController.clear();
    _processInput(text);
  }

  void _processInput(String text) async {
    if (_currentChat == null || _isLoading) return;

    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
      _messages.add(MessageViewModel(text: text, isUser: true));
    });

    final aiResponse =
        await _chatController.handleUserMessage(_currentChat!.id, text);

    if (mounted) {
      setState(() {
        _messages.add(MessageViewModel(text: aiResponse, isUser: false));
        _isLoading = false;
      });
    }
  }

  void _handleLogout() async {
    if (_isListeningMode) {
      _voiceController.stopListening();
    }

    await _authController.handleLogout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  void dispose() {
    if (_isListeningMode) {
      _voiceController.stopListening();
    }
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentChat?.displayTitle ?? "Gemini Assistant"),
      ),
      drawer: Drawer(
        // ... (Твій код Drawer залишається без змін)
        child: SafeArea(
          child: Column(
            children: [
              UserAccountsDrawerHeader(
                accountName: Text(
                  _userName,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                accountEmail: null,
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
                    // Кнопка мікрофона тепер працює як перемикач
                    IconButton(
                      icon: Icon(
                        _isListeningMode ? Icons.mic : Icons.mic_none,
                        color: _isListeningMode ? Colors.red : Colors.grey,
                      ),
                      onPressed: _toggleVoiceMode,
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
