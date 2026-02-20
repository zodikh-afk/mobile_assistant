import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Реєстрація користувача
  Future<String?> registerUser({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      // 1. Створюємо акаунт у Firebase Auth
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;

      // 2. Зберігаємо додаткові дані (логін) у Firestore
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'username': username,
          'email': email,
          'createdAt': DateTime.now(),
        });
      }
      return "Успіх";
    } catch (e) {
      return e.toString(); // Повертаємо помилку, якщо щось пішло не так
    }
  }
}