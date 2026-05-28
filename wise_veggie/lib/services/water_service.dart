import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Guarda y lee el consumo de agua diario en Firestore.
/// Colección: users/{uid}/water/{yyyy-MM-dd}
class WaterService {
  final _db   = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get _uid => _auth.currentUser!.uid;

  String _todayKey() {
    final now = DateTime.now();
    final mm  = now.month.toString().padLeft(2, '0');
    final dd  = now.day.toString().padLeft(2, '0');
    return '${now.year}-$mm-$dd';
  }

  String _keyFor(DateTime date) {
    final mm = date.month.toString().padLeft(2, '0');
    final dd = date.day.toString().padLeft(2, '0');
    return '${date.year}-$mm-$dd';
  }

  DocumentReference<Map<String, dynamic>> _todayRef() =>
      _db.collection('users').doc(_uid).collection('water').doc(_todayKey());

  // ── Stream litros de hoy ─────────────────────────────────────────────────
  Stream<double> streamTodayWater() {
    return _todayRef().snapshots().map((snap) {
      if (!snap.exists) return 0.0;
      return (snap.data()?['liters'] as num?)?.toDouble() ?? 0.0;
    });
  }

  // ── Añadir agua ──────────────────────────────────────────────────────────
  Future<void> addWater(double liters) async {
    final ref = _todayRef();
    await _db.runTransaction((tx) async {
      final snap    = await tx.get(ref);
      final current = (snap.data()?['liters'] as num?)?.toDouble() ?? 0.0;
      final newVal  = (current + liters).clamp(0.0, 10.0);
      tx.set(ref, {
        'liters': newVal,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    });
  }

  // ── Restar agua ───────────────────────────────────────────────────────────
  Future<void> removeWater(double liters) async {
    final ref = _todayRef();
    await _db.runTransaction((tx) async {
      final snap    = await tx.get(ref);
      final current = (snap.data()?['liters'] as num?)?.toDouble() ?? 0.0;
      final newVal  = (current - liters).clamp(0.0, 10.0);
      tx.set(ref, {
        'liters': newVal,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    });
  }

  // ── Días activos del mes actual ──────────────────────────────────────────
  Stream<Set<int>> streamActiveDaysThisMonth() {
    final now   = DateTime.now();
    final start = '${now.year}-${now.month.toString().padLeft(2, '0')}-01';
    final end   = '${now.year}-${now.month.toString().padLeft(2, '0')}-31';

    return _db
        .collection('users')
        .doc(_uid)
        .collection('water')
        .where(FieldPath.documentId, isGreaterThanOrEqualTo: start)
        .where(FieldPath.documentId, isLessThanOrEqualTo: end)
        .snapshots()
        .map((snap) => snap.docs
            .where((doc) =>
                ((doc.data()['liters'] as num?)?.toDouble() ?? 0.0) > 0)
            .map((doc) => int.parse(doc.id.split('-').last))
            .toSet());
  }

  // ── Racha real ───────────────────────────────────────────────────────────
  Future<int> calculateStreak() async {
    int      streak = 0;
    DateTime date   = DateTime.now();

    for (int i = 0; i < 365; i++) {
      final snap = await _db
          .collection('users')
          .doc(_uid)
          .collection('water')
          .doc(_keyFor(date))
          .get();

      final liters = (snap.data()?['liters'] as num?)?.toDouble() ?? 0.0;
      if (liters > 0) {
        streak++;
        date = date.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  }
}