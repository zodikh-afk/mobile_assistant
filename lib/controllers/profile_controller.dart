import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Отримання імені користувача
  Future<String?> getUsername() async {
    try {
      final String uid = _auth.currentUser?.uid ?? "";
      if (uid.isEmpty) return null;

      // Шукаємо документ користувача в колекції 'users' за його UID
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(uid).get();

      if (doc.exists) {
        return doc.get('username') as String?;
      }
    } catch (e) {
      print("Помилка завантаження профілю: $e");
    }
    return null;
  }
}
