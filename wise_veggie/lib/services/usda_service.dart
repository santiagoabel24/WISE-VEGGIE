import 'dart:convert';
import 'package:http/http.dart' as http;

class UsdaService {
  static const String _apiKey = '';

  /// Busca un alimento en la USDA y devuelve sus macros por 100g.
  /// Retorna null si falla o no encuentra nada.
  Future<Map<String, double>?> searchFood(String foodName) async {
    // La URL oficial de la USDA pidiendo 1 solo resultado para no gastar internet
    final url = Uri.parse(
        'https://api.nal.usda.gov/fdc/v1/foods/search?api_key=$_apiKey&query=$foodName&pageSize=1');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Si la USDA encontró resultados
        if (data['foods'] != null && data['foods'].isNotEmpty) {
          final food = data['foods'][0]; // Tomamos la mejor coincidencia
          final nutrients = food['foodNutrients'] as List;

          double cal = 0, prot = 0, carb = 0, fat = 0, sugar = 0;

          // La USDA usa IDs numéricos para los nutrientes
          // 1008 = Calorías, 1003 = Proteína, 1004 = Grasas, 1005 = Carbos, 2000 = Azúcar
          for (var n in nutrients) {
            if (n['nutrientId'] == 1008) cal = (n['value'] ?? 0).toDouble();
            if (n['nutrientId'] == 1003) prot = (n['value'] ?? 0).toDouble();
            if (n['nutrientId'] == 1004) fat = (n['value'] ?? 0).toDouble();
            if (n['nutrientId'] == 1005) carb = (n['value'] ?? 0).toDouble();
            if (n['nutrientId'] == 2000) sugar = (n['value'] ?? 0).toDouble();
          }

          // Lo devolvemos en el mismito formato que usa tu nutrition_database.dart
          return {
            'cal': cal,
            'prot': prot,
            'carb': carb,
            'fat': fat,
            'sugar': sugar, // ¡Ahora también incluye los azúcares!
          };
        }
      }
    } catch (e) {
      print('Error buscando en la USDA: $e');
    }
    
    return null; // Si algo sale mal o no hay internet
  }
}