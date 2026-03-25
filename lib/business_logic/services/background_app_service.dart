import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';

// Імпортуємо наші сервіси
import 'voice_service.dart';
import '../commands/app_command_service.dart';

class BackgroundAppService {
  Future<void> initialize() async {
    final service = FlutterBackgroundService();

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: false,
        isForegroundMode: true,
        notificationChannelId: 'assistant_bg_channel',
        initialNotificationTitle: 'AI Assistant (Фон)',
        initialNotificationContent: 'Готовий до локальних команд',
        foregroundServiceNotificationId: 888,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: false,
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
    );
  }

  void startService() {
    FlutterBackgroundService().startService();
  }

  void stopService() {
    FlutterBackgroundService().invoke('stopService');
  }
}

// ----------------------------------------------------------------------
// ФОНОВИЙ ІЗОЛЯТ (Окрема пам'ять)
// ----------------------------------------------------------------------
@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();
  WidgetsFlutterBinding.ensureInitialized();

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });
    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  // 1. Створюємо локальні екземпляри сервісів для фону
  final voiceService = VoiceService();
  final appCommandService = AppCommandService();

  // 2. Ініціалізуємо мікрофон
  bool isVoiceReady = await voiceService.initSpeech();

  if (isVoiceReady) {
    // 3. Запускаємо автономне слухання
    voiceService.startAutonomousListening(
      onResult: (text) async {
        final cleanText = text.trim().toLowerCase();
        if (cleanText.isEmpty) return;

        print("ФОН ПОЧУВ: $cleanText");

        // 4. Перевіряємо, чи є це локальною командою (без Gemini)
        if (appCommandService.canHandle(cleanText)) {
          if (service is AndroidServiceInstance) {
            service.setForegroundNotificationInfo(
              title: "Виконую команду...",
              content: text,
            );
          }

          await appCommandService.execute(cleanText);

          // Повертаємо стандартне сповіщення через пару секунд
          Future.delayed(const Duration(seconds: 3), () {
            if (service is AndroidServiceInstance) {
              service.setForegroundNotificationInfo(
                title: "AI Assistant (Фон)",
                content: "Слухаю команди...",
              );
            }
          });
        }
      },
    );
  } else {
    print("Не вдалося ініціалізувати мікрофон у фоні");
  }

  // Підтримуємо сервіс активним та оновлюємо сповіщення
  Timer.periodic(const Duration(seconds: 5), (timer) async {
    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) {
        service.setForegroundNotificationInfo(
          title: "AI Assistant (Фон)",
          content:
              voiceService.isListening ? "Слухаю..." : "Мікрофон в очікуванні",
        );
      }
    }
  });
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  return true;
}
