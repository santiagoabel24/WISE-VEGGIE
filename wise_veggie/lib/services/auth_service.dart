import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── Usuario actual ──
  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ── Registrar nuevo usuario ──
  Future<String?> register({
    required String email,
    required String password,
    required String name,
    required String role,
    Map<String, dynamic>? extraData,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      // Guardar datos del usuario en Firestore
      await _db.collection('users').doc(cred.user!.uid).set({
        'name': name.trim(),
        'email': email.trim(),
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
        ...?extraData,
      });

      return null; // null = sin error
    } on FirebaseAuthException catch (e) {
      return _authError(e.code);
    } catch (e) {
      return 'Error inesperado. Intenta de nuevo.';
    }
  }

  // ── Iniciar sesión ──
  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return null; // null = sin error
    } on FirebaseAuthException catch (e) {
      return _authError(e.code);
    } catch (e) {
      return 'Error inesperado. Intenta de nuevo.';
    }
  }

  // ── Cerrar sesión ──
  Future<void> logout() async {
    await _auth.signOut();
  }

  // ── Obtener datos del usuario desde Firestore ──
  Future<Map<String, dynamic>?> getUserData() async {
    final uid = currentUser?.uid;
    if (uid == null) return null;
    final doc = await _db.collection('users').doc(uid).get();
    return doc.data();
  }

  // ── Mensajes de error en español ──
  String _authError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'Este correo ya está registrado.';
      case 'invalid-email':
        return 'El correo no tiene un formato válido.';
      case 'weak-password':
        return 'La contraseña debe tener al menos 6 caracteres.';
      case 'user-not-found':
        return 'No existe una cuenta con este correo.';
      case 'wrong-password':
        return 'Contraseña incorrecta.';
      case 'invalid-credential':
        return 'Correo o contraseña incorrectos.';
      case 'too-many-requests':
        return 'Demasiados intentos. Espera un momento.';
      case 'network-request-failed':
        return 'Sin conexión a internet.';
      default:
        return 'Error: $code';
    }
  }
}