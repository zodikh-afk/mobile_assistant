import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/entities/user_entity.dart';
import '../domain/models/user_model.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserModel?> register(
      String email, String password, String username) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? firebaseUser = result.user;

      if (firebaseUser != null) {
        final userEntity = UserEntity(
          uid: firebaseUser.uid,
          username: username,
          email: email,
          createdAt: DateTime.now(),
        );

        await _firestore
            .collection('users')
            .doc(firebaseUser.uid)
            .set(userEntity.toMap());

        return UserModel(
            id: firebaseUser.uid, username: username, email: email);
      }
    } catch (e) {
      throw Exception(e.toString());
    }
    return null;
  }

  Future<UserModel?> login(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? firebaseUser = result.user;

      if (firebaseUser != null) {
        DocumentSnapshot doc =
            await _firestore.collection('users').doc(firebaseUser.uid).get();

        if (doc.exists) {
          return UserModel.fromEntity(doc.data() as Map<String, dynamic>);
        }

        return UserModel(
            id: firebaseUser.uid, username: 'Користувач', email: email);
      }
    } catch (e) {
      throw Exception(e.toString());
    }
    return null;
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}
