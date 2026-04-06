import 'package:flutter/material.dart';
import '../controllers/settings_controller.dart';
import '../controllers/theme_controller.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SettingsController _settingsController = SettingsController();
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentSettings();
  }

  void _loadCurrentSettings() async {
    bool darkTheme = await _settingsController.getThemeMode();
    setState(() {
      _isDarkMode = darkTheme;
    });
  }

  void _clearAuthData() async {
    await _settingsController.clearSavedAuthData();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Збережені дані для входу очищено!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Налаштування")),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text("Загальні",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue)),
          ),
          SwitchListTile(
            title: const Text('Темна тема'),
            value: _isDarkMode,
            onChanged: (bool value) async {
              setState(() {
                _isDarkMode = value;
              });

              await _settingsController.setThemeMode(value);

              ThemeController.toggleTheme(value);
            },
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text("Безпека",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue)),
          ),
          ListTile(
            leading: const Icon(Icons.delete_sweep, color: Colors.red),
            title: const Text("Скинути 'Запам'ятати мене'"),
            subtitle: const Text("Видаляє збережені пошту та пароль"),
            onTap: _clearAuthData,
          ),
        ],
      ),
    );
  }
}
