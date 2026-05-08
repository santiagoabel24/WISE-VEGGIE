import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/meal_service.dart'; // ← conectado a Firebase

// ─────────────────────────────────────────────
// BASE DE DATOS NUTRICIONAL SIMPLE
// Calorías y macros por cada 100g según tablas OMS/USDA
// ─────────────────────────────────────────────
const Map<String, Map<String, double>> _nutritionDB = {
  'manzana':      {'cal': 52,  'prot': 0.3, 'carb': 14,  'fat': 0.2, 'sugar': 10},
  'plátano':      {'cal': 89,  'prot': 1.1, 'carb': 23,  'fat': 0.3, 'sugar': 12},
  'naranja':      {'cal': 47,  'prot': 0.9, 'carb': 12,  'fat': 0.1, 'sugar': 9},
  'pollo':        {'cal': 165, 'prot': 31,  'carb': 0,   'fat': 3.6, 'sugar': 0},
  'arroz':        {'cal': 130, 'prot': 2.7, 'carb': 28,  'fat': 0.3, 'sugar': 0},
  'frijoles':     {'cal': 127, 'prot': 9,   'carb': 23,  'fat': 0.5, 'sugar': 0.3},
  'huevo':        {'cal': 155, 'prot': 13,  'carb': 1.1, 'fat': 11,  'sugar': 1.1},
  'leche':        {'cal': 61,  'prot': 3.2, 'carb': 4.8, 'fat': 3.3, 'sugar': 5},
  'pan':          {'cal': 265, 'prot': 9,   'carb': 49,  'fat': 3.2, 'sugar': 5},
  'tortilla':     {'cal': 218, 'prot': 5.7, 'carb': 44,  'fat': 2.5, 'sugar': 0.5},
  'atún':         {'cal': 116, 'prot': 26,  'carb': 0,   'fat': 1,   'sugar': 0},
  'yogur':        {'cal': 59,  'prot': 3.5, 'carb': 5,   'fat': 3.3, 'sugar': 4},
  'zanahoria':    {'cal': 41,  'prot': 0.9, 'carb': 10,  'fat': 0.2, 'sugar': 4.7},
  'espinaca':     {'cal': 23,  'prot': 2.9, 'carb': 3.6, 'fat': 0.4, 'sugar': 0.4},
  'aguacate':     {'cal': 160, 'prot': 2,   'carb': 9,   'fat': 15,  'sugar': 0.7},
  'pasta':        {'cal': 131, 'prot': 5,   'carb': 25,  'fat': 1.1, 'sugar': 0.6},
  'carne de res': {'cal': 250, 'prot': 26,  'carb': 0,   'fat': 15,  'sugar': 0},
  'salmon':       {'cal': 208, 'prot': 20,  'carb': 0,   'fat': 13,  'sugar': 0},
  'queso':        {'cal': 402, 'prot': 25,  'carb': 1.3, 'fat': 33,  'sugar': 0.5},
  'avena':        {'cal': 389, 'prot': 17,  'carb': 66,  'fat': 7,   'sugar': 1},
};

// ─────────────────────────────────────────────
// PANTALLA PRINCIPAL
// ─────────────────────────────────────────────
class IntakeScreen extends StatefulWidget {
  const IntakeScreen({super.key});

  @override
  State<IntakeScreen> createState() => _IntakeScreenState();
}

class _IntakeScreenState extends State<IntakeScreen>
    with SingleTickerProviderStateMixin {
  // Colores del tema
  static const _verde      = Color(0xFF1A6B4A);
  static const _verdeClaro = Color(0xFFE8F5EE);
  static const _verdeMedio = Color(0xFF2D9166);
  static const _crema      = Color(0xFFFAF7F2);
  static const _cafe       = Color(0xFF3D2B1F);
  static const _cafeMedio  = Color(0xFF7A5C4A);

  // Controladores del formulario
  final _formKey      = GlobalKey<FormState>();
  final _nameCtrl     = TextEditingController();
  final _quantityCtrl = TextEditingController();

  String    _selectedUnit = 'g';
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool      _isSaving     = false;
  bool      _showSuggestions = false;
  List<String> _suggestions = [];

  // Meta diaria de calorías
  final double _dailyCalorieGoal = 2000;

  // Macros calculados en tiempo real (preview)
  double _previewCal   = 0;
  double _previewProt  = 0;
  double _previewCarb  = 0;
  double _previewFat   = 0;
  double _previewSugar = 0;
  bool   _foodFound    = false;

  // ── Servicio Firebase ──
  final _mealService = MealService();

  @override
  void initState() {
    super.initState();
    _nameCtrl.addListener(_onNameChanged);
    _quantityCtrl.addListener(_onQuantityChanged);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _quantityCtrl.dispose();
    super.dispose();
  }

  // ── Búsqueda de sugerencias ──
  void _onNameChanged() {
    final query = _nameCtrl.text.toLowerCase().trim();
    if (query.isEmpty) {
      setState(() { _showSuggestions = false; _suggestions = []; });
      return;
    }
    final matches = _nutritionDB.keys.where((k) => k.contains(query)).toList();
    setState(() {
      _suggestions     = matches;
      _showSuggestions = matches.isNotEmpty;
    });
    _recalcPreview();
  }

  void _onQuantityChanged() => _recalcPreview();

  void _recalcPreview() {
    final name = _nameCtrl.text.toLowerCase().trim();
    final qty  = double.tryParse(_quantityCtrl.text) ?? 0;
    final data = _nutritionDB[name];

    if (data != null && qty > 0) {
      final factor = qty / 100;
      setState(() {
        _foodFound    = true;
        _previewCal   = data['cal']!   * factor;
        _previewProt  = data['prot']!  * factor;
        _previewCarb  = data['carb']!  * factor;
        _previewFat   = data['fat']!   * factor;
        _previewSugar = data['sugar']! * factor;
      });
    } else {
      setState(() {
        _foodFound    = false;
        _previewCal   = 0;
        _previewProt  = 0;
        _previewCarb  = 0;
        _previewFat   = 0;
        _previewSugar = 0;
      });
    }
  }

  void _selectSuggestion(String food) {
    _nameCtrl.text = food;
    _nameCtrl.selection =
        TextSelection.fromPosition(TextPosition(offset: food.length));
    setState(() { _showSuggestions = false; });
    _recalcPreview();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: _verde),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  // ─────────────────────────────────────────────
  // GUARDAR EN FIREBASE
  // ─────────────────────────────────────────────
  Future<void> _saveRecord() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final name   = _nameCtrl.text.trim();
    final qty    = double.parse(_quantityCtrl.text);
    final data   = _nutritionDB[name.toLowerCase()];
    final factor = qty / 100;

    final record = MealRecord(
      name:     name,
      quantity: qty,
      unit:     _selectedUnit,
      time:     _selectedTime.format(context),
      calories: data != null ? data['cal']!   * factor : _previewCal,
      proteins: data != null ? data['prot']!  * factor : _previewProt,
      carbs:    data != null ? data['carb']!  * factor : _previewCarb,
      fats:     data != null ? data['fat']!   * factor : _previewFat,
      sugar:    data != null ? data['sugar']! * factor : _previewSugar,
      date:     DateTime.now(),
    );

    final error = await _mealService.addMeal(record);

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } else {
      _nameCtrl.clear();
      _quantityCtrl.clear();
      setState(() {
        _selectedTime = TimeOfDay.now();
        _foodFound    = false;
        _previewCal   = 0;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 10),
            Text('${record.name} registrado correctamente'),
          ]),
          backgroundColor: _verde,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  // ─────────────────────────────────────────────
  // BORRAR EN FIREBASE
  // ─────────────────────────────────────────────
  Future<void> _deleteRecord(MealRecord meal) async {
    if (meal.id == null) return;
    await _mealService.deleteMeal(meal.id!);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Registro eliminado'),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // EDITAR EN FIREBASE — diálogo completo
  // ─────────────────────────────────────────────
  Future<void> _editRecord(MealRecord meal) async {
    final nameCtrl     = TextEditingController(text: meal.name);
    final quantityCtrl = TextEditingController(text: meal.quantity.toStringAsFixed(0));
    String selectedUnit = meal.unit;
    final editFormKey   = GlobalKey<FormState>();
    bool  isSaving      = false;

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            void recalc() => setDialogState(() {});

            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              contentPadding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              title: Row(children: [
                Container(
                  width: 34, height: 34,
                  decoration: BoxDecoration(
                    color: _verdeClaro,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.edit_outlined, color: _verde, size: 18),
                ),
                const SizedBox(width: 10),
                const Text('Editar registro',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _cafe)),
              ]),
              content: SizedBox(
                width: double.maxFinite,
                child: Form(
                  key: editFormKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 8),

                      // ── Nombre ──
                      TextFormField(
                        controller: nameCtrl,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: _inputDecoration(
                          label: 'Alimento',
                          hint: 'Ej. pollo, arroz...',
                          icon: Icons.restaurant_outlined,
                        ),
                        onChanged: (_) => recalc(),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Escribe el nombre'
                            : null,
                      ),
                      const SizedBox(height: 12),

                      // ── Cantidad + Unidad ──
                      Row(children: [
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: quantityCtrl,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d*\.?\d*'))
                            ],
                            decoration: _inputDecoration(
                              label: 'Cantidad',
                              hint: 'Ej. 150',
                              icon: Icons.scale_outlined,
                            ),
                            onChanged: (_) => recalc(),
                            validator: (v) {
                              if (v == null || v.isEmpty)
                                return 'Ingresa la cantidad';
                              if ((double.tryParse(v) ?? 0) <= 0)
                                return 'Inválida';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: selectedUnit,
                            decoration: _inputDecoration(
                              label: 'Unidad',
                              hint: '',
                              icon: Icons.straighten_outlined,
                            ),
                            items: ['g', 'ml', 'pza', 'taza', 'cda']
                                .map((u) => DropdownMenuItem(
                                    value: u, child: Text(u)))
                                .toList(),
                            onChanged: (v) =>
                                setDialogState(() => selectedUnit = v!),
                          ),
                        ),
                      ]),
                      const SizedBox(height: 16),

                      // ── Preview de macros recalculados ──
                      Builder(builder: (_) {
                        final name   = nameCtrl.text.toLowerCase().trim();
                        final qty    = double.tryParse(quantityCtrl.text) ?? 0;
                        final data   = _nutritionDB[name];
                        final factor = qty > 0 ? qty / 100 : 0;

                        if (data != null && qty > 0) {
                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _verdeClaro,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: _verde.withOpacity(0.2)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _previewItem('Calorías',
                                    '${(data['cal']! * factor).toStringAsFixed(0)} kcal'),
                                _previewItem('Proteínas',
                                    '${(data['prot']! * factor).toStringAsFixed(1)}g'),
                                _previewItem('Carbos',
                                    '${(data['carb']! * factor).toStringAsFixed(1)}g'),
                                _previewItem('Azúcar',
                                    '${(data['sugar']! * factor).toStringAsFixed(1)}g'),
                              ],
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      }),
                    ],
                  ),
                ),
              ),
              actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancelar',
                      style: TextStyle(color: Colors.grey)),
                ),
                StatefulBuilder(
                  builder: (ctx, setSaveState) => ElevatedButton(
                    onPressed: isSaving
                        ? null
                        : () async {
                            if (!editFormKey.currentState!.validate()) return;
                            setSaveState(() => isSaving = true);

                            final name   = nameCtrl.text.trim();
                            final qty    = double.parse(quantityCtrl.text);
                            final data   = _nutritionDB[name.toLowerCase()];
                            final factor = qty / 100;

                            final mealEditado = meal.copyWith(
                              name:     name,
                              quantity: qty,
                              unit:     selectedUnit,
                              calories: data != null ? data['cal']!   * factor : meal.calories,
                              proteins: data != null ? data['prot']!  * factor : meal.proteins,
                              carbs:    data != null ? data['carb']!  * factor : meal.carbs,
                              fats:     data != null ? data['fat']!   * factor : meal.fats,
                              sugar:    data != null ? data['sugar']! * factor : meal.sugar,
                            );

                            final error = await _mealService.updateMeal(mealEditado);

                            if (!ctx.mounted) return;
                            Navigator.pop(ctx);

                            if (error != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(error),
                                  backgroundColor: Colors.redAccent,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Row(children: [
                                    Icon(Icons.check_circle, color: Colors.white),
                                    SizedBox(width: 10),
                                    Text('Registro actualizado'),
                                  ]),
                                  backgroundColor: _verde,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _verde,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                    child: isSaving
                        ? const SizedBox(
                            width: 18, height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Guardar cambios'),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    nameCtrl.dispose();
    quantityCtrl.dispose();
  }

  // ─────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _crema,
      body: StreamBuilder<List<MealRecord>>(
        stream: _mealService.getTodayMeals(),
        builder: (context, snapshot) {
          final meals = snapshot.data ?? [];

          final totalCalories = meals.fold(0.0, (s, m) => s + m.calories);
          final totalProteins = meals.fold(0.0, (s, m) => s + m.proteins);
          final totalCarbs    = meals.fold(0.0, (s, m) => s + m.carbs);
          final totalSugar    = meals.fold(0.0, (s, m) => s + m.sugar);

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 160,
                pinned: true,
                backgroundColor: _verde,
                flexibleSpace: FlexibleSpaceBar(
                  background: _buildDaySummaryHeader(totalCalories),
                ),
                title: const Text(
                  'Registro de Ingesta',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildMacrosSummaryRow(totalProteins, totalCarbs, totalSugar),
                      const SizedBox(height: 20),
                      _buildFormCard(),
                      const SizedBox(height: 20),
                      _buildHistorySection(meals, snapshot.connectionState),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ─────────────────────────────────────────────
  // HEADER
  // ─────────────────────────────────────────────
  Widget _buildDaySummaryHeader(double totalCalories) {
    final pct       = (totalCalories / _dailyCalorieGoal).clamp(0.0, 1.0);
    final remaining = _dailyCalorieGoal - totalCalories;
    final isOver    = remaining < 0;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1A6B4A), Color(0xFF2D9166)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 70, 20, 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Calorías hoy',
                    style: TextStyle(color: Colors.white70, fontSize: 12)),
                Text(
                  '${totalCalories.toStringAsFixed(0)} / ${_dailyCalorieGoal.toInt()} kcal',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              ]),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isOver
                      ? Colors.redAccent.withOpacity(0.25)
                      : Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isOver
                      ? '+${(-remaining).toStringAsFixed(0)} kcal extra'
                      : '${remaining.toStringAsFixed(0)} kcal restantes',
                  style: TextStyle(
                    color: isOver ? Colors.red[200] : Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 8,
              backgroundColor: Colors.white24,
              valueColor: AlwaysStoppedAnimation(
                isOver ? Colors.redAccent : Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // MACROS
  // ─────────────────────────────────────────────
  Widget _buildMacrosSummaryRow(
      double totalProteins, double totalCarbs, double totalSugar) {
    return Row(
      children: [
        _macroChip('Proteínas', '${totalProteins.toStringAsFixed(1)}g', '🥩'),
        const SizedBox(width: 8),
        _macroChip('Carbos', '${totalCarbs.toStringAsFixed(1)}g', '🍞'),
        const SizedBox(width: 8),
        _macroChip('Azúcar', '${totalSugar.toStringAsFixed(1)}g', '🍬'),
      ],
    );
  }

  Widget _macroChip(String label, String value, String emoji) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2D9D0)),
          boxShadow: [
            BoxShadow(
              color: _verde.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 2),
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 14, color: _cafe)),
          Text(label,
              style: const TextStyle(fontSize: 10, color: _cafeMedio)),
        ]),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // FORMULARIO DE REGISTRO
  // ─────────────────────────────────────────────
  Widget _buildFormCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _verde.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: _verdeClaro,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.add_circle_outline,
                      color: _verde, size: 20),
                ),
                const SizedBox(width: 10),
                const Text('Registrar Alimento',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _cafe)),
              ]),
              const SizedBox(height: 16),
              _buildNameField(),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(flex: 2, child: _buildQuantityField()),
                const SizedBox(width: 10),
                Expanded(child: _buildUnitDropdown()),
              ]),
              const SizedBox(height: 12),
              _buildTimePicker(),
              const SizedBox(height: 16),
              if (_foodFound) ...[
                _buildNutritionPreview(),
                const SizedBox(height: 16),
              ],
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveRecord,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _verde,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.save_outlined, size: 18),
                            SizedBox(width: 8),
                            Text('Guardar Registro',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNameField() {
    return Column(
      children: [
        TextFormField(
          controller: _nameCtrl,
          textCapitalization: TextCapitalization.sentences,
          decoration: _inputDecoration(
            label: 'Nombre del alimento',
            hint: 'Ej. manzana, pollo, arroz...',
            icon: Icons.restaurant_outlined,
          ),
          validator: (v) => (v == null || v.trim().isEmpty)
              ? 'Escribe el nombre del alimento'
              : null,
        ),
        if (_showSuggestions)
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2D9D0)),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2))
              ],
            ),
            child: Column(
              children: _suggestions
                  .map((food) => InkWell(
                        onTap: () => _selectSuggestion(food),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          child: Row(children: [
                            const Icon(Icons.search,
                                size: 16, color: _cafeMedio),
                            const SizedBox(width: 8),
                            Text(food,
                                style: const TextStyle(
                                    color: _cafe, fontSize: 14)),
                          ]),
                        ),
                      ))
                  .toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildQuantityField() {
    return TextFormField(
      controller: _quantityCtrl,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))
      ],
      decoration: _inputDecoration(
        label: 'Cantidad',
        hint: 'Ej. 150',
        icon: Icons.scale_outlined,
      ),
      validator: (v) {
        if (v == null || v.isEmpty) return 'Ingresa la cantidad';
        if ((double.tryParse(v) ?? 0) <= 0) return 'Cantidad inválida';
        return null;
      },
    );
  }

  Widget _buildUnitDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedUnit,
      decoration: _inputDecoration(
        label: 'Unidad',
        hint: '',
        icon: Icons.straighten_outlined,
      ),
      items: ['g', 'ml', 'pza', 'taza', 'cda']
          .map((u) => DropdownMenuItem(value: u, child: Text(u)))
          .toList(),
      onChanged: (v) => setState(() => _selectedUnit = v!),
    );
  }

  Widget _buildTimePicker() {
    return InkWell(
      onTap: _pickTime,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: _crema,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2D9D0)),
        ),
        child: Row(children: [
          const Icon(Icons.access_time_outlined, color: _verde, size: 20),
          const SizedBox(width: 10),
          const Text('Hora de consumo',
              style: TextStyle(color: _cafeMedio, fontSize: 13)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: _verdeClaro,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _selectedTime.format(context),
              style: const TextStyle(
                  color: _verde, fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildNutritionPreview() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _verdeClaro,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _verde.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(children: [
            Icon(Icons.auto_awesome, color: _verde, size: 14),
            SizedBox(width: 6),
            Text('Aporte nutricional estimado',
                style: TextStyle(
                    color: _verde, fontSize: 12, fontWeight: FontWeight.w600)),
          ]),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _previewItem('Calorías', '${_previewCal.toStringAsFixed(0)} kcal'),
              _previewItem('Proteínas', '${_previewProt.toStringAsFixed(1)}g'),
              _previewItem('Carbos', '${_previewCarb.toStringAsFixed(1)}g'),
              _previewItem('Azúcar', '${_previewSugar.toStringAsFixed(1)}g'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _previewItem(String label, String value) {
    return Column(children: [
      Text(value,
          style: const TextStyle(
              fontWeight: FontWeight.bold, fontSize: 14, color: _cafe)),
      Text(label, style: const TextStyle(fontSize: 10, color: _cafeMedio)),
    ]);
  }

  // ─────────────────────────────────────────────
  // HISTORIAL DEL DÍA — leído de Firebase
  // ─────────────────────────────────────────────
  Widget _buildHistorySection(
      List<MealRecord> meals, ConnectionState connectionState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Historial de Hoy',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _cafe)),
            if (meals.isNotEmpty)
              Text('${meals.length} registros',
                  style: const TextStyle(fontSize: 12, color: _cafeMedio)),
          ],
        ),
        const SizedBox(height: 12),
        if (connectionState == ConnectionState.waiting)
          const Center(child: CircularProgressIndicator())
        else if (meals.isEmpty)
          _buildEmptyState()
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: meals.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) => _buildMealCard(meals[i]),
          ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2D9D0)),
      ),
      child: Column(children: [
        const Text('🥗', style: TextStyle(fontSize: 40)),
        const SizedBox(height: 10),
        const Text('Aún no has registrado nada hoy',
            style: TextStyle(color: _cafeMedio, fontSize: 14)),
        const SizedBox(height: 4),
        Text('¡Empieza registrando tu primer alimento!',
            style: TextStyle(color: _cafeMedio.withOpacity(0.6), fontSize: 12)),
      ]),
    );
  }

  // ── Tarjeta: deslizar = borrar, tocar = editar ──
  Widget _buildMealCard(MealRecord meal) {
    return Dismissible(
      key: Key('meal_${meal.id ?? meal.name}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red[400],
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (_) => _deleteRecord(meal),
      child: GestureDetector(
        onTap: () => _editRecord(meal), // ← toque abre el diálogo de edición
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2D9D0)),
            boxShadow: [
              BoxShadow(
                color: _verde.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: _verdeClaro,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text('🍽️', style: TextStyle(fontSize: 20)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(meal.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: _cafe)),
                    const SizedBox(height: 2),
                    Text(
                      '${meal.quantity.toStringAsFixed(0)}${meal.unit} · ${meal.time}',
                      style: const TextStyle(fontSize: 12, color: _cafeMedio),
                    ),
                  ],
                ),
              ),
              // Ícono de editar
              const Icon(Icons.edit_outlined, size: 16, color: _cafeMedio),
              const SizedBox(width: 10),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(
                  '${meal.calories.toStringAsFixed(0)}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: _verde),
                ),
                const Text('kcal',
                    style: TextStyle(fontSize: 10, color: _cafeMedio)),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // HELPER — Decoración de inputs
  // ─────────────────────────────────────────────
  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: _verde, size: 20),
      labelStyle: const TextStyle(color: _cafeMedio, fontSize: 13),
      hintStyle: TextStyle(color: _cafeMedio.withOpacity(0.5), fontSize: 13),
      filled: true,
      fillColor: _crema,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2D9D0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2D9D0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _verde, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    );
  }
}