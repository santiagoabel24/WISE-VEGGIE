import 'package:flutter/material.dart';

class FoodRecord {
  final String id;
  final String name;
  final int calories;
  final double sugarGrams;
  final DateTime timestamp;

  FoodRecord({
    required this.id,
    required this.name,
    required this.calories,
    required this.sugarGrams,
    required this.timestamp,
  });
}

class IntakeProvider with ChangeNotifier {
  final List<FoodRecord> _dailyRecords = [];
  final int dailyCalorieGoal = 2000;

  List<FoodRecord> get dailyRecords => _dailyRecords;

  int get totalCaloriesConsumed {
    return _dailyRecords.fold(0, (sum, record) => sum + record.calories);
  }

  double get totalSugarConsumed {
    return _dailyRecords.fold(0.0, (sum, record) => sum + record.sugarGrams);
  }

  void addFood(String name, int calories, double sugarGrams) {
    if (name.isEmpty || calories < 0 || sugarGrams < 0) return; 

    final newRecord = FoodRecord(
      id: DateTime.now().toString(),
      name: name,
      calories: calories,
      sugarGrams: sugarGrams,
      timestamp: DateTime.now(),
    );

    _dailyRecords.add(newRecord);
    notifyListeners(); 
  }

  // MÉTODO NUEVO: Limpia los datos al cerrar sesión
  void clearData() {
    _dailyRecords.clear();
    notifyListeners();
  }
}