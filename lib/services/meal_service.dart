import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ── Modelo de registro de comida ──
class MealRecord {
  final String? id;
  final String name;
  final double quantity;
  final String unit;
  final String time;
  final double calories;
  final double proteins;
  final double carbs;
  final double fats;
  final double sugar;
  final DateTime date;

  MealRecord({
    this.id,
    required this.name,
    required this.quantity,
    required this.unit,
    required this.time,
    required this.calories,
    required this.proteins,
    required this.carbs,
    required this.fats,
    required this.sugar,
    required this.date,
  });

  // Convertir a Map para guardar en Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'time': time,
      'calories': calories,
      'proteins': proteins,
      'carbs': carbs,
      'fats': fats,
      'sugar': sugar,
      'date': Timestamp.fromDate(date),
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  // Crear desde documento de Firestore
  factory MealRecord.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MealRecord(
      id: doc.id,
      name: data['name'] ?? '',
      quantity: (data['quantity'] ?? 0).toDouble(),
      unit: data['unit'] ?? 'g',
      time: data['time'] ?? '',
      calories: (data['calories'] ?? 0).toDouble(),
      proteins: (data['proteins'] ?? 0).toDouble(),
      carbs: (data['carbs'] ?? 0).toDouble(),
      fats: (data['fats'] ?? 0).toDouble(),
      sugar: (data['sugar'] ?? 0).toDouble(),
      date: (data['date'] as Timestamp).toDate(),
    );
  }

  // Copiar con cambios (para editar)
  MealRecord copyWith({
    String? name,
    double? quantity,
    String? unit,
    String? time,
    double? calories,
    double? proteins,
    double? carbs,
    double? fats,
    double? sugar,
  }) {
    return MealRecord(
      id: id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      time: time ?? this.time,
      calories: calories ?? this.calories,
      proteins: proteins ?? this.proteins,
      carbs: carbs ?? this.carbs,
      fats: fats ?? this.fats,
      sugar: sugar ?? this.sugar,
      date: date,
    );
  }
}

// ── Servicio CRUD completo ──
class MealService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Ruta base: users/{uid}/meals
  CollectionReference get _mealsRef {
    final uid = _auth.currentUser!.uid;
    return _db.collection('users').doc(uid).collection('meals');
  }

  // ── CREATE — Guardar nuevo registro ──
  Future<String?> addMeal(MealRecord meal) async {
    try {
      await _mealsRef.add(meal.toMap());
      return null;
    } catch (e) {
      return 'Error al guardar: $e';
    }
  }

  // ── READ — Registros de HOY en tiempo real ──
  Stream<List<MealRecord>> getTodayMeals() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return _mealsRef
        .where('date',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('date', isLessThan: Timestamp.fromDate(endOfDay))
        .orderBy('date')
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => MealRecord.fromFirestore(d)).toList());
  }

  // ── READ — Todos los registros (historial completo) ──
  Stream<List<MealRecord>> getAllMeals() {
    return _mealsRef
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => MealRecord.fromFirestore(d)).toList());
  }

  // ── READ — Registros por fecha específica ──
  Stream<List<MealRecord>> getMealsByDate(DateTime date) {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));

    return _mealsRef
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThan: Timestamp.fromDate(end))
        .orderBy('date')
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => MealRecord.fromFirestore(d)).toList());
  }

  // ── UPDATE — Editar registro existente ──
  Future<String?> updateMeal(MealRecord meal) async {
    if (meal.id == null) return 'El registro no tiene ID.';
    try {
      await _mealsRef.doc(meal.id).update(meal.toMap());
      return null;
    } catch (e) {
      return 'Error al actualizar: $e';
    }
  }

  // ── DELETE — Borrar registro ──
  Future<String?> deleteMeal(String mealId) async {
    try {
      await _mealsRef.doc(mealId).delete();
      return null;
    } catch (e) {
      return 'Error al eliminar: $e';
    }
  }
}