import 'dart:io';

class ConnectivityController {
  /// Перевіряє наявність реального підключення до інтернету
  Future<bool> hasInternetConnection() async {
    try {
      // Робимо DNS-запит до надійного хоста
      final result = await InternetAddress.lookup('google.com');

      // Якщо запит успішний і ми отримали хоча б одну IP-адресу
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
      return false;
    } on SocketException catch (_) {
      // SocketException виникає, коли мережа недоступна
      return false;
    }
  }
}
