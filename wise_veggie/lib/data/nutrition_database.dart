import '../services/usda_service.dart';

// nutrition_database.dart
// Base de datos nutricional local para Wise Wigie
// Fuente: USDA FoodData Central & FAO/INCAP (valores por 100g)
//
// Estructura de cada alimento:
// {
//   'cal'   : kcal por 100g,
//   'prot'  : proteínas (g) por 100g,
//   'carb'  : carbohidratos (g) por 100g,
//   'fat'   : grasas (g) por 100g,
//   'sugar' : azúcares (g) por 100g,
//   'g_pza' : gramos por pieza estándar (null si no aplica),
//   'g_taza': gramos por taza (null si no aplica),
//   'g_cda' : gramos por cucharada (null si no aplica),
//   'g_ml'  : gramos por ml — para líquidos (null si no aplica),
//   'units' : lista de unidades válidas para este alimento,
// }

const List<String> kValidUnits = ['g', 'ml', 'pza', 'taza', 'cda'];

const Map<String, Map<String, dynamic>> nutritionDatabase = {

  // ─────────────────────────────────────────────
  // FRUTAS
  // ─────────────────────────────────────────────
  'manzana': {
    'cal': 52.0, 'prot': 0.3, 'carb': 13.8, 'fat': 0.2, 'sugar': 10.4,
    'g_pza': 182.0, 'g_taza': 125.0, 'g_cda': null, 'g_ml': null,
    'units': ['g', 'pza', 'taza'],
  },
  'plátano': {
    'cal': 89.0, 'prot': 1.1, 'carb': 22.8, 'fat': 0.3, 'sugar': 12.2,
    'g_pza': 118.0, 'g_taza': 150.0, 'g_cda': null, 'g_ml': null,
    'units': ['g', 'pza', 'taza'],
  },
  'naranja': {
    'cal': 47.0, 'prot': 0.9, 'carb': 11.8, 'fat': 0.1, 'sugar': 9.4,
    'g_pza': 131.0, 'g_taza': 180.0, 'g_cda': null, 'g_ml': null,
    'units': ['g', 'pza', 'taza'],
  },
  'mandarina': {
    'cal': 53.0, 'prot': 0.8, 'carb': 13.3, 'fat': 0.3, 'sugar': 10.6,
    'g_pza': 88.0, 'g_taza': 195.0, 'g_cda': null, 'g_ml': null,
    'units': ['g', 'pza', 'taza'],
  },
  'uvas': {
    'cal': 69.0, 'prot': 0.7, 'carb': 18.1, 'fat': 0.2, 'sugar': 15.5,
    'g_pza': 5.0, 'g_taza': 151.0, 'g_cda': null, 'g_ml': null,
    'units': ['g', 'pza', 'taza'],
  },
  'sandía': {
    'cal': 30.0, 'prot': 0.6, 'carb': 7.6, 'fat': 0.2, 'sugar': 6.2,
    'g_pza': null, 'g_taza': 152.0, 'g_cda': null, 'g_ml': null,
    'units': ['g', 'taza'],
  },
  'melón': {
    'cal': 34.0, 'prot': 0.8, 'carb': 8.2, 'fat': 0.2, 'sugar': 7.9,
    'g_pza': null, 'g_taza': 156.0, 'g_cda': null, 'g_ml': null,
    'units': ['g', 'taza'],
  },
  'piña': {
    'cal': 50.0, 'prot': 0.5, 'carb': 13.1, 'fat': 0.1, 'sugar': 9.9,
    'g_pza': null, 'g_taza': 165.0, 'g_cda': null, 'g_ml': null,
    'units': ['g', 'taza'],
  },
  'mango': {
    'cal': 60.0, 'prot': 0.8, 'carb': 15.0, 'fat': 0.4, 'sugar': 13.7,
    'g_pza': 336.0, 'g_taza': 165.0, 'g_cda': null, 'g_ml': null,
    'units': ['g', 'pza', 'taza'],
  },
  'papaya': {
    'cal': 43.0, 'prot': 0.5, 'carb': 10.8, 'fat': 0.3, 'sugar': 7.8,
    'g_pza': 304.0, 'g_taza': 145.0, 'g_cda': null, 'g_ml': null,
    'units': ['g', 'pza', 'taza'],
  },
  'fresa': {
    'cal': 32.0, 'prot': 0.7, 'carb': 7.7, 'fat': 0.3, 'sugar': 4.9,
    'g_pza': 12.0, 'g_taza': 152.0, 'g_cda': null, 'g_ml': null,
    'units': ['g', 'pza', 'taza'],
  },
  'guayaba': {
    'cal': 68.0, 'prot': 2.6, 'carb': 14.3, 'fat': 1.0, 'sugar': 8.9,
    'g_pza': 90.0, 'g_taza': 165.0, 'g_cda': null, 'g_ml': null,
    'units': ['g', 'pza', 'taza'],
  },
  'limón': {
    'cal': 29.0, 'prot': 1.1, 'carb': 9.3, 'fat': 0.3, 'sugar': 2.5,
    'g_pza': 58.0, 'g_taza': null, 'g_cda': null, 'g_ml': null,
    'units': ['g', 'pza'],
  },
  'toronja': {
    'cal': 42.0, 'prot': 0.8, 'carb': 10.7, 'fat': 0.1, 'sugar': 6.9,
    'g_pza': 246.0, 'g_taza': 230.0, 'g_cda': null, 'g_ml': null,
    'units': ['g', 'pza', 'taza'],
  },
  'aguacate': {
    'cal': 160.0, 'prot': 2.0, 'carb': 8.5, 'fat': 14.7, 'sugar': 0.7,
    'g_pza': 200.0, 'g_taza': 150.0, 'g_cda': null, 'g_ml': null,
    'units': ['g', 'pza', 'taza'],
  },
  'durazno': {
    'cal': 39.0, 'prot': 0.9, 'carb': 9.5, 'fat': 0.3, 'sugar': 8.4,
    'g_pza': 150.0, 'g_taza': 154.0, 'g_cda': null, 'g_ml': null,
    'units': ['g', 'pza', 'taza'],
  },
  'pera': {
    'cal': 57.0, 'prot': 0.4, 'carb': 15.2, 'fat': 0.1, 'sugar': 9.8,
    'g_pza': 178.0, 'g_taza': 140.0, 'g_cda': null, 'g_ml': null,
    'units': ['g', 'pza', 'taza'],
  },
  'ciruela': {
    'cal': 46.0, 'prot': 0.7, 'carb': 11.4, 'fat': 0.3, 'sugar': 9.9,
    'g_pza': 66.0, 'g_taza': 165.0, 'g_cda': null, 'g_ml': null,
    'units': ['g', 'pza', 'taza'],
  },
  'coco': {
    'cal': 354.0, 'prot': 3.3, 'carb': 15.2, 'fat': 33.5, 'sugar': 6.2,
    'g_pza': null, 'g_taza': 80.0, 'g_cda': 5.0, 'g_ml': null,
    'units': ['g', 'taza', 'cda'],
  },
  'tamarindo': {
    'cal': 239.0, 'prot': 2.8, 'carb': 62.5, 'fat': 0.6, 'sugar': 38.0,
    'g_pza': 2.0, 'g_taza': null, 'g_cda': null, 'g_ml': null,
    'units': ['g', 'pza'],
  },

  // ─────────────────────────────────────────────
  // VERDURAS Y HORTALIZAS
  // ─────────────────────────────────────────────
  'zanahoria': {
    'cal': 41.0, 'prot': 0.9, 'carb': 9.6, 'fat': 0.2, 'sugar': 4.7,
    'g_pza': 61.0, 'g_taza': 128.0, 'g_cda': null, 'g_ml': null,
    'units': ['g', 'pza', 'taza'],
  },
  'espinaca': {
    'cal': 23.0, 'prot': 2.9, 'carb': 3.6, 'fat': 0.4, 'sugar': 0.4,
    'g_pza': null, 'g_taza': 30.0, 'g_cda': null, 'g_ml': null,
    'units': ['g', 'taza'],
  },
  'lechuga': {
    'cal': 15.0, 'prot': 1.4, 'carb': 2.9, 'fat': 0.2, 'sugar': 1.2,
    'g_pza': null, 'g_taza': 47.0, 'g_cda': null, 'g_ml': null,
    'units': ['g', 'taza'],
  },
  'tomate': {
    'cal': 18.0, 'prot': 0.9, 'carb': 3.9, 'fat': 0.2, 'sugar': 2.6,
    'g_pza': 123.0, 'g_taza': 180.0, 'g_cda': null, 'g_ml': null,
    'units': ['g', 'pza', 'taza'],
  },
  'cebolla': {
    'cal': 40.0, 'prot': 1.1, 'carb': 9.3, 'fat': 0.1, 'sugar': 4.2,
    'g_pza': 110.0, 'g_taza': 160.0, 'g_cda': null, 'g_ml': null,
    'units': ['g', 'pza', 'taza'],
  },
  'ajo': {
    'cal': 149.0, 'prot': 6.4, 'carb': 33.1, 'fat': 0.5, 'sugar': 1.0,
    'g_pza': 3.0, 'g_taza': null, 'g_cda': 9.0, 'g_ml': null,
    'units': ['g', 'pza', 'cda'],
  },
  'chile jalapeño': {
    'cal': 29.0, 'prot': 0.9, 'carb': 6.5, 'fat': 0.4, 'sugar': 4.1,
    'g_pza': 14.0, 'g_taza': null, 'g_cda': null, 'g_ml': null,
    'units': ['g', 'pza'],
  },
  'chile serrano': {
    'cal': 32.0, 'prot': 1.8, 'carb': 6.7, 'fat': 0.4, 'sugar': 4.2,
    'g_pza': 6.0, 'g_taza': null, 'g_cda': null, 'g_ml': null,
    'units': ['g', 'pza'],
  },
  'calabaza': {
    'cal': 26.0, 'prot': 1.0, 'carb': 6.5, 'fat': 0.1, 'sugar': 2.8,
    'g_pza': 350.0, 'g_taza': 116.0, 'g_cda': null, 'g_ml': null,
    'units': ['g', 'taza'],
  },
  'brócoli': {
    'cal': 34.0, 'prot': 2.8, 'carb': 6.6, 'fat': 0.4, 'sugar': 1.7,
    'g_pza': null, 'g_taza': 91.0, 'g_cda': null, 'g_ml': null,
    'units': ['g', 'taza'],
  },
  'coliflor': {
    'cal': 25.0, 'prot': 1.9, 'carb': 5.0, 'fat': 0.3, 'sugar': 1.9,
    'g_pza': null, 'g_taza': 107.0, 'g_cda': null, 'g_ml': null,
    'units': ['g', 'taza'],
  },
  'chayote': {
    'cal': 19.0, 'prot': 0.8, 'carb': 4.5, 'fat': 0.1, 'sugar': 1.7,
    'g_pza': 200.0, 'g_taza': 132.0, 'g_cda': null, 'g_ml': null,
    'units': ['g', 'pza', 'taza'],
  },
  'nopal': {
    'cal': 16.0, 'prot': 1.4, 'carb': 3.3, 'fat': 0.1, 'sugar': 1.1,
    'g_pza': 86.0, 'g_taza': 86.0, 'g_cda': null, 'g_ml': null,
    'units': ['g', 'pza', 'taza'],
  },
  'elote': {
    'cal': 86.0, 'prot': 3.3, 'carb': 19.0, 'fat': 1.4, 'sugar': 3.2,
    'g_pza': 77.0, 'g_taza': 154.0, 'g_cda': null, 'g_ml': null,
    'units': ['g', 'pza', 'taza'],
  },
  'pepino': {
    'cal': 15.0, 'prot': 0.7, 'carb': 3.6, 'fat': 0.1, 'sugar': 1.7,
    'g_pza': 301.0, 'g_taza': 119.0, 'g_cda': null, 'g_ml': null,
    'units': ['g', 'pza', 'taza'],
  },
  'betabel': {
    'cal': 43.0, 'prot': 1.6, 'carb': 9.6, 'fat': 0.2, 'sugar': 6.8,
    'g_pza': 82.0, 'g_taza': 136.0, 'g_cda': null, 'g_ml': null,
    'units': ['g', 'pza', 'taza'],
  },
  'apio': {
    'cal': 16.0, 'prot': 0.7, 'carb': 3.0, 'fat': 0.2, 'sugar': 1.3,
    'g_pza': null, 'g_taza': 101.0, 'g_cda': null, 'g_ml': null,
    'units': ['g', 'taza'],
  },
  'pimiento': {
    'cal': 31.0, 'prot': 1.0, 'carb': 6.0, 'fat': 0.3, 'sugar': 4.2,
    'g_pza': 119.0, 'g_taza': 149.0, 'g_cda': null, 'g_ml': null,
    'units': ['g', 'pza', 'taza'],
  },
  'papa': {
    'cal': 77.0, 'prot': 2.0, 'carb': 17.5, 'fat': 0.1, 'sugar': 0.8,
    'g_pza': 150.0, 'g_taza': 150.0, 'g_cda': null, 'g_ml': null,
    'units': ['g', 'pza', 'taza'],
  },
  'camote': {
    'cal': 86.0, 'prot': 1.6, 'carb': 20.1, 'fat': 0.1, 'sugar': 4.2,
    'g_pza': 130.0, 'g_taza': 133.0, 'g_cda': null, 'g_ml': null,
    'units': ['g', 'pza', 'taza'],
  },
  'jícama': {
    'cal': 38.0, 'prot': 0.7, 'carb': 8.8, 'fat': 0.1, 'sugar': 1.8,
    'g_pza': null, 'g_taza': 130.0, 'g_cda': null, 'g_ml': null,
    'units': ['g', 'taza'],
  },
  'ejotes': {
    'cal': 31.0, 'prot': 1.8, 'carb': 7.1, 'fat': 0.1, 'sugar': 1.4,
    'g_pza': null, 'g_taza': 110.0, 'g_cda': null, 'g_ml': null,
    'units': ['g', 'taza'],
  },
  'cilantro': {
    'cal': 23.0, 'prot': 2.1, 'carb': 3.7, 'fat': 0.5, 'sugar': 0.9,
    'g_pza': null, 'g_taza': 16.0, 'g_cda': 1.0, 'g_ml': null,
    'units': ['g', 'taza', 'cda'],
  },

  // ─────────────────────────────────────────────
  // CEREALES Y GRANOS
  // ─────────────────────────────────────────────
  'arroz blanco cocido': {
    'cal': 130.0, 'prot': 2.7, 'carb': 28.2, 'fat': 0.3, 'sugar': 0.0,
    'g_pza': null, 'g_taza': 186.0, 'g_cda': 12.0, 'g_ml': null,
    'units': ['g', 'taza', 'cda'],
  },
  'arroz integral cocido': {
    'cal': 111.0, 'prot': 2.6, 'carb': 23.0, 'fat': 0.9, 'sugar': 0.4,
    'g_pza': null, 'g_taza': 195.0, 'g_cda': 12.0, 'g_ml': null,
    'units': ['g', 'taza', 'cda'],
  },
  'avena': {
    'cal': 389.0, 'prot': 16.9, 'carb': 66.3, 'fat': 6.9, 'sugar': 0.0,
    'g_pza': null, 'g_taza': 81.0, 'g_cda': 5.0, 'g_ml': null,
    'units': ['g', 'taza', 'cda'],
  },
  'avena cocida': {
    'cal': 71.0, 'prot': 2.5, 'carb': 12.0, 'fat': 1.5, 'sugar': 0.0,
    'g_pza': null, 'g_taza': 234.0, 'g_cda': null, 'g_ml': null,
    'units': ['g', 'taza'],
  },
  'tortilla de maíz': {
    'cal': 218.0, 'prot': 5.7, 'carb': 46.4, 'fat': 2.5, 'sugar': 0.5,
    'g_pza': 26.0, 'g_taza': null, 'g_cda': null, 'g_ml': null,
    'units': ['g', 'pza'],
  },
  'tortilla de harina': {
    'cal': 312.0, 'prot': 8.0, 'carb': 52.0, 'fat': 7.0, 'sugar': 2.0,
    'g_pza': 45.0, 'g_taza': null, 'g_cda': null, 'g_ml': null,
    'units': ['g', 'pza'],
  },
  'pan blanco': {
    'cal': 265.0, 'prot': 9.0, 'carb': 49.0, 'fat': 3.2, 'sugar': 5.1,
    'g_pza': 25.0, 'g_taza': null, 'g_cda': null, 'g_ml': null,
    'units': ['g', 'pza'],
  },
  'pan integral': {
    'cal': 247.0, 'prot': 13.0, 'carb': 41.0, 'fat': 4.2, 'sugar': 5.6,
    'g_pza': 28.0, 'g_taza': null, 'g_cda': null, 'g_ml': null,
    'units': ['g', 'pza'],
  },
  'pasta cocida': {
    'cal': 131.0, 'prot': 5.0, 'carb': 25.0, 'fat': 1.1, 'sugar': 0.6,
    'g_pza': null, 'g_taza': 140.0, 'g_cda': null, 'g_ml': null,
    'units': ['g', 'taza'],
  },
  'maíz palomero': {
    'cal': 375.0, 'prot': 11.0, 'carb': 74.0, 'fat': 4.3, 'sugar': 0.9,
    'g_pza': null, 'g_taza': 8.0, 'g_cda': null, 'g_ml': null,
    'units': ['g', 'taza'],
  },
  'granola': {
    'cal': 471.0, 'prot': 10.0, 'carb': 64.0, 'fat': 20.0, 'sugar': 24.0,
    'g_pza': null, 'g_taza': 122.0, 'g_cda': 7.5, 'g_ml': null,
    'units': ['g', 'taza', 'cda'],
  },
  'cereal de maíz': {
    'cal': 357.0, 'prot': 7.5, 'carb': 84.0, 'fat': 0.5, 'sugar': 8.0,
    'g_pza': null, 'g_taza': 28.0, 'g_cda': null, 'g_ml': null,
    'units': ['g', 'taza'],
  },
  'quinoa cocida': {
    'cal': 120.0, 'prot': 4.4, 'carb': 21.3, 'fat': 1.9, 'sugar': 0.9,
    'g_pza': null, 'g_taza': 185.0, 'g_cda': null, 'g_ml': null,
    'units': ['g', 'taza'],
  },

  // ─────────────────────────────────────────────
  // LEGUMINOSAS
  // ─────────────────────────────────────────────
  'frijoles negros cocidos': {
    'cal': 132.0, 'prot': 8.9, 'carb': 23.7, 'fat': 0.5, 'sugar': 0.3,
    'g_pza': null, 'g_taza': 172.0, 'g_cda': 10.5, 'g_ml': null,
    'units': ['g', 'taza', 'cda'],
  },
  'frijoles pintos cocidos': {
    'cal': 143.0, 'prot': 9.0, 'carb': 26.0, 'fat': 0.6, 'sugar': 0.5,
    'g_pza': null, 'g_taza': 171.0, 'g_cda': null, 'g_ml': null,
    'units': ['g', 'taza'],
  },
  'lentejas cocidas': {
    'cal': 116.0, 'prot': 9.0, 'carb': 20.1, 'fat': 0.4, 'sugar': 1.8,
    'g_pza': null, 'g_taza': 198.0, 'g_cda': null, 'g_ml': null,
    'units': ['g', 'taza'],
  },
  'garbanzos cocidos': {
    'cal': 164.0, 'prot': 8.9, 'carb': 27.4, 'fat': 2.6, 'sugar': 4.8,
    'g_pza': null, 'g_taza': 164.0, 'g_cda': null, 'g_ml': null,
    'units': ['g', 'taza'],
  },
  'habas cocidas': {
    'cal': 110.0, 'prot': 7.9, 'carb': 19.7, 'fat': 0.4, 'sugar': 1.8,
    'g_pza': null, 'g_taza': 170.0, 'g_cda': null, 'g_ml': null,
    'units': ['g', 'taza'],
  },
  'soya cocida': {
    'cal': 173.0, 'prot': 16.6, 'carb': 9.9, 'fat': 9.0, 'sugar': 3.0,
    'g_pza': null, 'g_taza': 172.0, 'g_cda': null, 'g_ml': null,
    'units': ['g', 'taza'],
  },
  'edamame': {
    'cal': 122.0, 'prot': 10.9, 'carb': 8.9, 'fat': 5.2, 'sugar': 2.2,
    'g_pza': null, 'g_taza': 155.0, 'g_cda': null, 'g_ml': null,
    'units': ['g', 'taza'],
  },

  // ─────────────────────────────────────────────
  // PROTEÍNAS ANIMALES
  // ─────────────────────────────────────────────
  'pollo pechuga cocida': {
    'cal': 165.0, 'prot': 31.0, 'carb': 0.0, 'fat': 3.6, 'sugar': 0.0,
    'g_pza': 172.0, 'g_taza': 140.0, 'g_cda': null, 'g_ml': null,
    'units': ['g', 'pza', 'taza'],
  },
  'pollo muslo cocido': {
    'cal': 209.0, 'prot': 26.0, 'carb': 0.0, 'fat': 10.9, 'sugar': 0.0,
    'g_pza': 109.0, 'g_taza': null, 'g_cda': null, 'g_ml': null,
    'units': ['g', 'pza'],
  },
  'carne de res magra': {
    'cal': 215.0, 'prot': 26.1, 'carb': 0.0, 'fat': 11.8, 'sugar': 0.0,
    'g_pza': null, 'g_taza': 140.0, 'g_cda': null, 'g_ml': null,
    'units': ['g', 'taza'],
  },
  'carne molida 80%': {
    'cal': 254.0, 'prot': 17.2, 'carb': 0.0, 'fat': 20.0, 'sugar': 0.0,
    'g_pza': null, 'g_taza': 228.0, 'g_cda': null, 'g_ml': null,
    'units': ['g', 'taza'],
  },
  'cerdo lomo cocido': {
    'cal': 242.0, 'prot': 27.3, 'carb': 0.0, 'fat': 14.0, 'sugar': 0.0,
    'g_pza': null, 'g_taza': 140.0, 'g_cda': null, 'g_ml': null,
    'units': ['g', 'taza'],
  },
  'salmon cocido': {
    'cal': 208.0, 'prot': 20.4, 'carb': 0.0, 'fat': 13.4, 'sugar': 0.0,
    'g_pza': 154.0, 'g_taza': null, 'g_cda': null, 'g_ml': null,
    'units': ['g', 'pza'],
  },
  'atún en agua': {
    'cal': 116.0, 'prot': 25.5, 'carb': 0.0, 'fat': 1.0, 'sugar': 0.0,
    'g_pza': null, 'g_taza': 154.0, 'g_cda': null, 'g_ml': null,
    'units': ['g', 'taza'],
  },
  'sardina en lata': {
    'cal': 208.0, 'prot': 24.6, 'carb': 0.0, 'fat': 11.5, 'sugar': 0.0,
    'g_pza': 38.0, 'g_taza': null, 'g_cda': null, 'g_ml': null,
    'units': ['g', 'pza'],
  },
  'tilapia cocida': {
    'cal': 128.0, 'prot': 26.2, 'carb': 0.0, 'fat': 2.7, 'sugar': 0.0,
    'g_pza': 87.0, 'g_taza': null, 'g_cda': null, 'g_ml': null,
    'units': ['g', 'pza'],
  },
  'camarón cocido': {
    'cal': 99.0, 'prot': 20.9, 'carb': 0.9, 'fat': 1.1, 'sugar': 0.0,
    'g_pza': 6.0, 'g_taza': 145.0, 'g_cda': null, 'g_ml': null,
    'units': ['g', 'pza', 'taza'],
  },
  'huevo entero cocido': {
    'cal': 155.0, 'prot': 12.6, 'carb': 1.1, 'fat': 10.6, 'sugar': 1.1,
    'g_pza': 50.0, 'g_taza': null, 'g_cda': null, 'g_ml': null,
    'units': ['g', 'pza'],
  },
  'clara de huevo': {
    'cal': 52.0, 'prot': 10.9, 'carb': 0.7, 'fat': 0.2, 'sugar': 0.7,
    'g_pza': 33.0, 'g_taza': 243.0, 'g_cda': null, 'g_ml': null,
    'units': ['g', 'pza', 'taza'],
  },
  'jamón de pavo': {
    'cal': 107.0, 'prot': 14.6, 'carb': 4.0, 'fat': 3.9, 'sugar': 1.4,
    'g_pza': 28.0, 'g_taza': null, 'g_cda': null, 'g_ml': null,
    'units': ['g', 'pza'],
  },
  'salchicha': {
    'cal': 294.0, 'prot': 11.3, 'carb': 2.4, 'fat': 26.6, 'sugar': 1.6,
    'g_pza': 45.0, 'g_taza': null, 'g_cda': null, 'g_ml': null,
    'units': ['g', 'pza'],
  },

  // ─────────────────────────────────────────────
  // LÁCTEOS
  // ─────────────────────────────────────────────
  'leche entera': {
    'cal': 61.0, 'prot': 3.2, 'carb': 4.8, 'fat': 3.3, 'sugar': 5.0,
    'g_pza': null, 'g_taza': 244.0, 'g_cda': 15.0, 'g_ml': 1.03,
    'units': ['g', 'ml', 'taza', 'cda'],
  },
  'leche descremada': {
    'cal': 34.0, 'prot': 3.4, 'carb': 5.0, 'fat': 0.2, 'sugar': 5.0,
    'g_pza': null, 'g_taza': 245.0, 'g_cda': 15.0, 'g_ml': 1.03,
    'units': ['g', 'ml', 'taza', 'cda'],
  },
  'yogur natural': {
    'cal': 59.0, 'prot': 3.5, 'carb': 5.0, 'fat': 3.3, 'sugar': 4.0,
    'g_pza': null, 'g_taza': 245.0, 'g_cda': 15.0, 'g_ml': 1.03,
    'units': ['g', 'ml', 'taza', 'cda'],
  },
  'yogur griego': {
    'cal': 73.0, 'prot': 9.0, 'carb': 3.6, 'fat': 0.4, 'sugar': 3.2,
    'g_pza': null, 'g_taza': 245.0, 'g_cda': 15.0, 'g_ml': 1.05,
    'units': ['g', 'ml', 'taza', 'cda'],
  },
  'queso panela': {
    'cal': 290.0, 'prot': 20.0, 'carb': 3.5, 'fat': 22.0, 'sugar': 0.5,
    'g_pza': null, 'g_taza': null, 'g_cda': null, 'g_ml': null,
    'units': ['g'],
  },
  'queso oaxaca': {
    'cal': 350.0, 'prot': 23.0, 'carb': 2.0, 'fat': 28.0, 'sugar': 0.5,
    'g_pza': null, 'g_taza': null, 'g_cda': null, 'g_ml': null,
    'units': ['g'],
  },
  'queso fresco': {
    'cal': 264.0, 'prot': 16.0, 'carb': 3.1, 'fat': 21.0, 'sugar': 0.5,
    'g_pza': null, 'g_taza': 113.0, 'g_cda': 7.0, 'g_ml': null,
    'units': ['g', 'taza', 'cda'],
  },
  'queso manchego': {
    'cal': 392.0, 'prot': 24.7, 'carb': 0.4, 'fat': 32.3, 'sugar': 0.1,
    'g_pza': null, 'g_taza': null, 'g_cda': null, 'g_ml': null,
    'units': ['g'],
  },
  'crema ácida': {
    'cal': 193.0, 'prot': 2.4, 'carb': 4.6, 'fat': 19.4, 'sugar': 4.0,
    'g_pza': null, 'g_taza': 230.0, 'g_cda': 14.0, 'g_ml': 1.0,
    'units': ['g', 'ml', 'taza', 'cda'],
  },
  'mantequilla': {
    'cal': 717.0, 'prot': 0.9, 'carb': 0.1, 'fat': 81.1, 'sugar': 0.1,
    'g_pza': null, 'g_taza': 227.0, 'g_cda': 14.2, 'g_ml': null,
    'units': ['g', 'taza', 'cda'],
  },

  // ─────────────────────────────────────────────
  // GRASAS Y ACEITES
  // ─────────────────────────────────────────────
  'aceite de oliva': {
    'cal': 884.0, 'prot': 0.0, 'carb': 0.0, 'fat': 100.0, 'sugar': 0.0,
    'g_pza': null, 'g_taza': 216.0, 'g_cda': 13.5, 'g_ml': 0.91,
    'units': ['g', 'ml', 'cda'],
  },
  'aceite vegetal': {
    'cal': 884.0, 'prot': 0.0, 'carb': 0.0, 'fat': 100.0, 'sugar': 0.0,
    'g_pza': null, 'g_taza': 218.0, 'g_cda': 14.0, 'g_ml': 0.92,
    'units': ['g', 'ml', 'cda'],
  },
  'mayonesa': {
    'cal': 680.0, 'prot': 1.0, 'carb': 0.6, 'fat': 75.0, 'sugar': 0.4,
    'g_pza': null, 'g_taza': 220.0, 'g_cda': 13.8, 'g_ml': null,
    'units': ['g', 'cda'],
  },

  // ─────────────────────────────────────────────
  // BEBIDAS
  // ─────────────────────────────────────────────
  'jugo de naranja': {
    'cal': 45.0, 'prot': 0.7, 'carb': 10.4, 'fat': 0.2, 'sugar': 8.4,
    'g_pza': null, 'g_taza': 248.0, 'g_cda': null, 'g_ml': 1.04,
    'units': ['ml', 'taza'],
  },
  'refresco cola': {
    'cal': 41.0, 'prot': 0.0, 'carb': 10.6, 'fat': 0.0, 'sugar': 10.6,
    'g_pza': null, 'g_taza': 248.0, 'g_cda': null, 'g_ml': 1.0,
    'units': ['ml', 'taza'],
  },
  'café negro': {
    'cal': 2.0, 'prot': 0.3, 'carb': 0.0, 'fat': 0.0, 'sugar': 0.0,
    'g_pza': null, 'g_taza': 237.0, 'g_cda': null, 'g_ml': 1.0,
    'units': ['ml', 'taza'],
  },
  'té sin azúcar': {
    'cal': 1.0, 'prot': 0.0, 'carb': 0.3, 'fat': 0.0, 'sugar': 0.0,
    'g_pza': null, 'g_taza': 237.0, 'g_cda': null, 'g_ml': 1.0,
    'units': ['ml', 'taza'],
  },
  'agua de jamaica': {
    'cal': 37.0, 'prot': 0.4, 'carb': 9.5, 'fat': 0.1, 'sugar': 8.0,
    'g_pza': null, 'g_taza': 240.0, 'g_cda': null, 'g_ml': 1.0,
    'units': ['ml', 'taza'],
  },
  'leche de soya': {
    'cal': 33.0, 'prot': 2.7, 'carb': 1.8, 'fat': 1.8, 'sugar': 1.0,
    'g_pza': null, 'g_taza': 243.0, 'g_cda': null, 'g_ml': 1.03,
    'units': ['ml', 'taza'],
  },
  'leche de almendra': {
    'cal': 15.0, 'prot': 0.6, 'carb': 0.6, 'fat': 1.2, 'sugar': 0.0,
    'g_pza': null, 'g_taza': 240.0, 'g_cda': null, 'g_ml': 1.0,
    'units': ['ml', 'taza'],
  },

  // ─────────────────────────────────────────────
  // SNACKS Y OTROS
  // ─────────────────────────────────────────────
  'nuez': {
    'cal': 654.0, 'prot': 15.2, 'carb': 13.7, 'fat': 65.2, 'sugar': 2.6,
    'g_pza': 5.0, 'g_taza': 100.0, 'g_cda': 7.0, 'g_ml': null,
    'units': ['g', 'pza', 'taza', 'cda'],
  },
  'almendra': {
    'cal': 579.0, 'prot': 21.2, 'carb': 21.6, 'fat': 49.9, 'sugar': 4.4,
    'g_pza': 1.2, 'g_taza': 143.0, 'g_cda': 9.0, 'g_ml': null,
    'units': ['g', 'pza', 'taza', 'cda'],
  },
  'cacahuate': {
    'cal': 567.0, 'prot': 25.8, 'carb': 16.1, 'fat': 49.2, 'sugar': 4.7,
    'g_pza': 0.7, 'g_taza': 146.0, 'g_cda': 9.0, 'g_ml': null,
    'units': ['g', 'pza', 'taza', 'cda'],
  },
  'mantequilla de cacahuate': {
    'cal': 588.0, 'prot': 25.1, 'carb': 20.0, 'fat': 50.4, 'sugar': 9.2,
    'g_pza': null, 'g_taza': 258.0, 'g_cda': 16.0, 'g_ml': null,
    'units': ['g', 'taza', 'cda'],
  },
  'chocolate oscuro 70%': {
    'cal': 598.0, 'prot': 7.8, 'carb': 45.8, 'fat': 42.6, 'sugar': 24.0,
    'g_pza': null, 'g_taza': null, 'g_cda': null, 'g_ml': null,
    'units': ['g'],
  },
  'miel': {
    'cal': 304.0, 'prot': 0.3, 'carb': 82.4, 'fat': 0.0, 'sugar': 82.1,
    'g_pza': null, 'g_taza': 339.0, 'g_cda': 21.0, 'g_ml': 1.43,
    'units': ['g', 'ml', 'taza', 'cda'],
  },
  'azúcar blanca': {
    'cal': 387.0, 'prot': 0.0, 'carb': 99.8, 'fat': 0.0, 'sugar': 99.8,
    'g_pza': null, 'g_taza': 200.0, 'g_cda': 12.5, 'g_ml': null,
    'units': ['g', 'taza', 'cda'],
  },
  'sal': {
    'cal': 0.0, 'prot': 0.0, 'carb': 0.0, 'fat': 0.0, 'sugar': 0.0,
    'g_pza': null, 'g_taza': null, 'g_cda': 6.0, 'g_ml': null,
    'units': ['g', 'cda'],
  },
  'tofu': {
    'cal': 76.0, 'prot': 8.0, 'carb': 1.9, 'fat': 4.8, 'sugar': 0.7,
    'g_pza': null, 'g_taza': 248.0, 'g_cda': null, 'g_ml': null,
    'units': ['g', 'taza'],
  },
  'hummus': {
    'cal': 166.0, 'prot': 7.9, 'carb': 14.3, 'fat': 9.6, 'sugar': 0.5,
    'g_pza': null, 'g_taza': 246.0, 'g_cda': 15.0, 'g_ml': null,
    'units': ['g', 'taza', 'cda'],
  },
};

/// Retorna el factor de conversión a gramos para la cantidad y unidad dadas.
/// Devuelve null si la unidad no es válida para ese alimento.
double? getGramsFactor(String foodName, double quantity, String unit) {
  final food = nutritionDatabase[foodName.toLowerCase()];
  
  if (food == null) {
    // Si no está en la base local (ej. lo va a buscar en USDA), 
    // solo podemos calcular en gramos porque no tenemos equivalencias de piezas o tazas.
    if (unit == 'g') return quantity / 100.0;
    return null; 
  }

  final validUnits = food['units'] as List<String>;
  if (!validUnits.contains(unit)) return null;

  switch (unit) {
    case 'g':
      return quantity / 100.0;
    case 'ml':
      final gPerMl = food['g_ml'] as double?;
      if (gPerMl == null) return null;
      return (quantity * gPerMl) / 100.0;
    case 'pza':
      final gPorPza = food['g_pza'] as double?;
      if (gPorPza == null) return null;
      return (quantity * gPorPza) / 100.0;
    case 'taza':
      final gPorTaza = food['g_taza'] as double?;
      if (gPorTaza == null) return null;
      return (quantity * gPorTaza) / 100.0;
    case 'cda':
      final gPorCda = food['g_cda'] as double?;
      if (gPorCda == null) return null;
      return (quantity * gPorCda) / 100.0;
    default:
      return null;
  }
}

/// Retorna las unidades válidas para un alimento dado.
/// Devuelve lista vacía si el alimento no existe.
List<String> getValidUnits(String foodName) {
  final food = nutritionDatabase[foodName.toLowerCase()];
  if (food == null) return ['g'];
  return List<String>.from(food['units'] as List);
}

/// Retorna los valores nutricionales calculados para una cantidad y unidad.
/// ¡Estrategia Online-First! Busca en USDA primero, si no hay internet o falla, usa la DB local.
Future<Map<String, double>?> calculateNutrition(String foodName, double quantity, String unit) async {
  
  // 1. Obtener el factor de conversión (Si no está en DB local, solo admitirá 'g')
  final double? factor = getGramsFactor(foodName, quantity, unit);
  if (factor == null) return null;

  Map<String, dynamic>? foodData;

  // 2. Intentar buscar en la USDA primero (ONLINE)
  print('Buscando "$foodName" en la USDA (Online)...');
  try {
    final usdaService = UsdaService();
    foodData = await usdaService.searchFood(foodName);
  } catch (e) {
    print('Fallo al conectar con USDA (¿Sin internet?). Pasando a local...');
  }

  // 3. Si no se encontró en la USDA o no hay internet, usar la BD Local (OFFLINE)
  if (foodData == null) {
    print('Buscando "$foodName" en la base de datos local...');
    foodData = nutritionDatabase[foodName.toLowerCase()];
  }

  // 4. Si de plano no existe ni en internet ni en la base local
  if (foodData == null) {
    return null; 
  }

  // 5. Hacer el cálculo final con los gramos y los datos encontrados
  return {
    'cal':   (foodData['cal']   as double) * factor,
    'prot':  (foodData['prot']  as double) * factor,
    'carb':  (foodData['carb']  as double) * factor,
    'fat':   (foodData['fat']   as double) * factor,
    // Agregamos un ?? 0.0 por si la USDA no devuelve el dato de azúcar
    'sugar': ((foodData['sugar'] ?? 0.0) as double) * factor, 
  };
}