import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/meal_service.dart';
import '../data/nutrition_database.dart';

// Use `nutritionDatabase`, `calculateNutrition` and helpers from
// `lib/data/nutrition_database.dart` for nutritional data and conversions.

String _normalize(String s) {
  final map = {
    'á': 'a', 'é': 'e', 'í': 'i', 'ó': 'o', 'ú': 'u',
    'Á': 'a', 'É': 'e', 'Í': 'i', 'Ó': 'o', 'Ú': 'u',
    'ñ': 'n', 'Ñ': 'n', 'ü': 'u', 'Ü': 'u'
  };
  var out = s.toLowerCase().trim();
  map.forEach((k, v) { out = out.replaceAll(k, v); });
  return out;
}

/// Try to find the exact key in `nutritionDatabase` that matches [input].
/// Returns the matching key from the database (preserving accents) or null.
String? _findFoodKey(String input) {
  final q = input.toLowerCase().trim();
  if (q.isEmpty) return null;
  if (nutritionDatabase.containsKey(q)) return q;
  final normQ = _normalize(q);
  // exact normalized match
  for (final k in nutritionDatabase.keys) {
    if (_normalize(k) == normQ) return k;
  }
  // normalized contains
  for (final k in nutritionDatabase.keys) {
    if (_normalize(k).contains(normQ)) return k;
  }
  return null;
}

class IntakeScreen extends StatefulWidget {
  const IntakeScreen({super.key});

  @override
  State<IntakeScreen> createState() => _IntakeScreenState();
}

class _IntakeScreenState extends State<IntakeScreen>
    with SingleTickerProviderStateMixin {
  // Colores ahora provienen del tema (Theme.of(context)) para soportar modo oscuro

  final _formKey      = GlobalKey<FormState>();
  final _nameCtrl     = TextEditingController();
  final _quantityCtrl = TextEditingController();

  String    _selectedUnit    = 'g';
  TimeOfDay _selectedTime    = TimeOfDay.now();
  bool      _isSaving        = false;
  bool      _showSuggestions = false;
  List<String> _suggestions  = [];

  String _historyView = 'today';

  final double _dailyCalorieGoal = 2000;

  double _previewCal   = 0;
  double _previewProt  = 0;
  double _previewCarb  = 0;
  double _previewFat   = 0;
  double _previewSugar = 0;
  bool   _foodFound    = false;

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

  void _onNameChanged() {
    final query = _nameCtrl.text.toLowerCase().trim();
    if (query.isEmpty) {
      setState(() { _showSuggestions = false; _suggestions = []; });
      return;
    }
    final matches = nutritionDatabase.keys.where((k) => k.toLowerCase().contains(query)).toList();
    setState(() { _suggestions = matches; _showSuggestions = matches.isNotEmpty; });
    _recalcPreview();
  }

  void _onQuantityChanged() => _recalcPreview();

  Future<void> _recalcPreview() async {
    final name = _nameCtrl.text.toLowerCase().trim();
    final qty  = double.tryParse(_quantityCtrl.text) ?? 0;
    if (name.isEmpty || qty <= 0) {
      if (!mounted) return;
      setState(() { _foodFound = false; _previewCal = 0; _previewProt = 0; _previewCarb = 0; _previewFat = 0; _previewSugar = 0; });
      return;
    }

    final calc = await calculateNutrition(name, qty, _selectedUnit);
    if (!mounted) return;
    if (calc != null) {
      setState(() {
        _foodFound    = true;
        _previewCal   = calc['cal'] ?? 0;
        _previewProt  = calc['prot'] ?? 0;
        _previewCarb  = calc['carb'] ?? 0;
        _previewFat   = calc['fat'] ?? 0;
        _previewSugar = calc['sugar'] ?? 0;
      });
    } else {
      setState(() { _foodFound = false; _previewCal = 0; _previewProt = 0; _previewCarb = 0; _previewFat = 0; _previewSugar = 0; });
    }
  }

  void _selectSuggestion(String food) {
    _nameCtrl.text = food;
    _nameCtrl.selection = TextSelection.fromPosition(TextPosition(offset: food.length));
    setState(() { _showSuggestions = false; });
    _recalcPreview();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        final primary = Theme.of(context).colorScheme.primary;
        return Theme(
          data: Theme.of(context).copyWith(colorScheme: ColorScheme.light(primary: primary)),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  Future<void> _saveRecord() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final name   = _nameCtrl.text.trim();
    final qty    = double.parse(_quantityCtrl.text);
    final time   = _selectedTime.format(context);
    final calc   = await calculateNutrition(name.toLowerCase(), qty, _selectedUnit);

    final record = MealRecord(
      name:     name,
      quantity: qty,
      unit:     _selectedUnit,
      time:     time,
      calories: calc != null ? (calc['cal'] ?? _previewCal) : _previewCal,
      proteins: calc != null ? (calc['prot'] ?? _previewProt) : _previewProt,
      carbs:    calc != null ? (calc['carb'] ?? _previewCarb) : _previewCarb,
      fats:     calc != null ? (calc['fat'] ?? _previewFat) : _previewFat,
      sugar:    calc != null ? (calc['sugar'] ?? _previewSugar) : _previewSugar,
      date:     DateTime.now(),
    );

    final error = await _mealService.addMeal(record);
    if (!mounted) return;
    setState(() => _isSaving = false);

    if (error != null) {
      _showSnack(error, Colors.redAccent);
    } else {
      _nameCtrl.clear();
      _quantityCtrl.clear();
      setState(() { _selectedTime = TimeOfDay.now(); _foodFound = false; _previewCal = 0; });
      _showSnack('${record.name} registrado correctamente', Theme.of(context).colorScheme.primary, icon: Icons.check_circle);
    }
  }

  Future<void> _deleteRecord(MealRecord meal) async {
    if (meal.id == null) return;
    await _mealService.deleteMeal(meal.id!);
    if (!mounted) return;
    _showSnack('Registro eliminado', Colors.redAccent);
  }

  Future<void> _editRecord(MealRecord meal) async {
    final nameCtrl     = TextEditingController(text: meal.name);
    final quantityCtrl = TextEditingController(text: meal.quantity.toStringAsFixed(0));
    String selectedUnit = meal.unit;
    final editFormKey   = GlobalKey<FormState>();
    bool  isSaving      = false;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDS) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            contentPadding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            title: Row(children: [
              Container(
                width: 34, height: 34,
                decoration: BoxDecoration(color: Theme.of(ctx).colorScheme.primary.withAlpha((0.12 * 255).round()), borderRadius: BorderRadius.circular(10)),
                child: Icon(Icons.edit_outlined, color: Theme.of(ctx).colorScheme.primary, size: 18),
              ),
              const SizedBox(width: 10),
              Text('Editar registro',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Theme.of(ctx).colorScheme.onSurface)),
            ]),
            content: SizedBox(
              width: double.maxFinite,
              child: Form(
                key: editFormKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: nameCtrl,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: _inputDecoration(label: 'Alimento', hint: 'Ej. pollo, arroz...', icon: Icons.restaurant_outlined),
                      onChanged: (_) => setDS(() {}),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Escribe el nombre' : null,
                    ),
                    const SizedBox(height: 12),
                      Row(children: [
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          controller: quantityCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                          decoration: _inputDecoration(label: 'Cantidad', hint: 'Ej. 150', icon: Icons.scale_outlined),
                          onChanged: (_) => setDS(() {}),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Ingresa la cantidad';
                            if ((double.tryParse(v) ?? 0) <= 0) return 'Inválida';
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Builder(builder: (_) {
                          final name = nameCtrl.text.trim();
                          final key = _findFoodKey(name);
                          final units = key != null ? getValidUnits(key) : ['g'];
                          if (!units.contains(selectedUnit)) selectedUnit = units.first;
                          return DropdownButtonFormField<String>(
                            initialValue: selectedUnit,
                            decoration: _inputDecoration(label: 'Unidad', hint: '', icon: Icons.straighten_outlined),
                            items: units.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                            onChanged: (v) => setDS(() => selectedUnit = v!),
                          );
                        }),
                      ),
                    ]),
                    const SizedBox(height: 16),

                    Builder(builder: (_) {
                      final n = nameCtrl.text.toLowerCase().trim();
                      final q = double.tryParse(quantityCtrl.text) ?? 0;
                      if (n.isEmpty || q <= 0) return const SizedBox.shrink();
                      return FutureBuilder<Map<String, double>?>(
                        future: calculateNutrition(n, q, selectedUnit),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData || snapshot.data == null) return const SizedBox.shrink();
                          final calc = snapshot.data!;
                          final cs = Theme.of(context).colorScheme;
                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: cs.primary.withAlpha((0.12 * 255).round()),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: cs.primary.withAlpha((0.2 * 255).round())),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _previewItem('Calorías', '${(calc['cal'] ?? 0).toStringAsFixed(0)} kcal'),
                                _previewItem('Proteínas', '${(calc['prot'] ?? 0).toStringAsFixed(1)}g'),
                                _previewItem('Carbos', '${(calc['carb'] ?? 0).toStringAsFixed(1)}g'),
                                _previewItem('Azúcar', '${(calc['sugar'] ?? 0).toStringAsFixed(1)}g'),
                              ],
                            ),
                          );
                        },
                      );
                    }),
                  ],
                ),
              ),
            ),
            actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
              ),
              StatefulBuilder(
                builder: (ctx, setSS) => ElevatedButton(
                  onPressed: isSaving ? null : () async {
                    if (!editFormKey.currentState!.validate()) return;
                    setSS(() => isSaving = true);
                    final n = nameCtrl.text.trim();
                    final q = double.parse(quantityCtrl.text);
                    final calc = await calculateNutrition(n, q, selectedUnit);
                    final edited = meal.copyWith(
                      name: n, quantity: q, unit: selectedUnit,
                      calories: calc != null ? (calc['cal'] ?? meal.calories) : meal.calories,
                      proteins: calc != null ? (calc['prot'] ?? meal.proteins) : meal.proteins,
                      carbs:    calc != null ? (calc['carb'] ?? meal.carbs) : meal.carbs,
                      fats:     calc != null ? (calc['fat'] ?? meal.fats) : meal.fats,
                      sugar:    calc != null ? (calc['sugar'] ?? meal.sugar) : meal.sugar,
                    );
                    final error = await _mealService.updateMeal(edited);
                    if (!ctx.mounted) return;
                    Navigator.pop(ctx);
                    if (error != null) {
                      _showSnack(error, Colors.redAccent);
                    } else {
                      _showSnack('Registro actualizado', Theme.of(ctx).colorScheme.primary, icon: Icons.check_circle);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(ctx).colorScheme.primary, foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                  child: isSaving
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Guardar cambios'),
                ),
              ),
            ],
          );
        },
      ),
    );
    nameCtrl.dispose();
    quantityCtrl.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = cs.primary;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: StreamBuilder<List<MealRecord>>(
        stream: _historyView == 'today'
            ? _mealService.getTodayMeals()
            : _mealService.getWeekMeals(),
        builder: (context, snapshot) {
          final meals         = snapshot.data ?? [];
          final todayMeals    = _historyView == 'today' ? meals : _filterToday(meals);
          final totalCalories = todayMeals.fold(0.0, (s, m) => s + m.calories);
          final totalProteins = todayMeals.fold(0.0, (s, m) => s + m.proteins);
          final totalCarbs    = todayMeals.fold(0.0, (s, m) => s + m.carbs);
          final totalSugar    = todayMeals.fold(0.0, (s, m) => s + m.sugar);

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 160,
                pinned: true,
                backgroundColor: primary,
                flexibleSpace: FlexibleSpaceBar(
                  background: _buildHeader(totalCalories),
                ),
                title: Text('Registro de Ingesta',
                    style: TextStyle(color: cs.onPrimary, fontWeight: FontWeight.w600)),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildMacrosRow(totalProteins, totalCarbs, totalSugar),
                      const SizedBox(height: 20),
                      _buildFormCard(),
                      const SizedBox(height: 20),
                      _buildViewToggle(),
                      const SizedBox(height: 12),
                      _historyView == 'today'
                          ? _buildTodayHistory(meals, snapshot.connectionState)
                          : _buildWeekHistory(meals, snapshot.connectionState),
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

  Widget _buildHeader(double totalCalories) {
    final pct       = (totalCalories / _dailyCalorieGoal).clamp(0.0, 1.0);
    final remaining = _dailyCalorieGoal - totalCalories;
    final isOver    = remaining < 0;

    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [cs.primary, cs.secondary],
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
                Text('Calorías hoy', style: TextStyle(color: cs.onPrimary.withAlpha((0.9 * 255).round()), fontSize: 12)),
                Text(
                  '${totalCalories.toStringAsFixed(0)} / ${_dailyCalorieGoal.toInt()} kcal',
                  style: TextStyle(color: cs.onPrimary, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ]),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isOver ? Colors.redAccent.withAlpha((0.25 * 255).round()) : cs.onPrimary.withAlpha((0.2 * 255).round()),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isOver ? '+${(-remaining).toStringAsFixed(0)} kcal extra' : '${remaining.toStringAsFixed(0)} kcal restantes',
                  style: TextStyle(color: isOver ? Colors.red[200] : cs.onPrimary, fontSize: 12, fontWeight: FontWeight.w500),
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
              valueColor: AlwaysStoppedAnimation(isOver ? Colors.redAccent : Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMacrosRow(double prot, double carbs, double sugar) {
    return Row(children: [
      _macroChip('Proteínas', '${prot.toStringAsFixed(1)}g', '🥩'),
      const SizedBox(width: 8),
      _macroChip('Carbos', '${carbs.toStringAsFixed(1)}g', '🍞'),
      const SizedBox(width: 8),
      _macroChip('Azúcar', '${sugar.toStringAsFixed(1)}g', '🍬'),
    ]);
  }

  Widget _macroChip(String label, String value, String emoji) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Theme.of(context).dividerColor),
          boxShadow: [BoxShadow(color: Theme.of(context).colorScheme.primary.withAlpha((0.06 * 255).round()), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 2),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Theme.of(context).colorScheme.onSurface)),
          Text(label, style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.75))),
        ]),
      ),
    );
  }

  Widget _buildViewToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          _historyView == 'today' ? 'Historial de Hoy' : 'Historial Semanal',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface),
        ),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: Row(children: [
            _toggleBtn('Hoy', 'today'),
            _toggleBtn('Semana', 'week'),
          ]),
        ),
      ],
    );
  }

  Widget _toggleBtn(String label, String value) {
    final isSelected = _historyView == value;
    return GestureDetector(
      onTap: () => setState(() => _historyView = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isSelected ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurface.withOpacity(0.75),
          ),
        ),
      ),
    );
  }

  Widget _buildTodayHistory(List<MealRecord> meals, ConnectionState state) {
    if (state == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }
    if (meals.isEmpty) return _buildEmptyState('Aún no has registrado nada hoy');
    return Column(children: [
      _dayHeader(DateTime.now(), meals),
      const SizedBox(height: 8),
      ...meals.map((m) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: _buildMealCard(m),
      )),
    ]);
  }

  Widget _buildWeekHistory(List<MealRecord> meals, ConnectionState state) {
    if (state == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }
    if (meals.isEmpty) return _buildEmptyState('No hay registros esta semana');

    final Map<String, List<MealRecord>> grouped = {};
    for (final meal in meals) {
      final key = _dayKey(meal.date);
      grouped.putIfAbsent(key, () => []).add(meal);
    }

    final sortedKeys = grouped.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return Column(
      children: sortedKeys.map((key) {
        final dayMeals = grouped[key]!;
        final date     = dayMeals.first.date;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _dayHeader(date, dayMeals),
            const SizedBox(height: 8),
            ...dayMeals.map((m) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildMealCard(m),
            )),
            const SizedBox(height: 16),
          ],
        );
      }).toList(),
    );
  }

  Widget _dayHeader(DateTime date, List<MealRecord> meals) {
    final totalCal = meals.fold(0.0, (s, m) => s + m.calories);
    final isToday  = _isToday(date);
    final label    = isToday ? 'Hoy · ${_formatDate(date)}' : _formatDate(date);

    final cs = Theme.of(context).colorScheme;
    final primary = cs.primary;
    final primaryLight = primary.withOpacity(0.12);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isToday ? primary : primaryLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [
            Text(
              isToday ? '📅' : '🗓️',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isToday ? cs.onPrimary : cs.onSurface,
              ),
            ),
          ]),
            Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: isToday ? cs.onPrimary.withOpacity(0.2) : primaryLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${totalCal.toStringAsFixed(0)} kcal · ${meals.length} registro${meals.length != 1 ? 's' : ''}',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: isToday ? cs.onPrimary : primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealCard(MealRecord meal) {
    final cs = Theme.of(context).colorScheme;
    final primary = cs.primary;
    final primaryLight = primary.withOpacity(0.12);
    return Dismissible(
      key: Key('meal_${meal.id ?? meal.name}_${meal.date.millisecondsSinceEpoch}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(color: Colors.red[400], borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (_) => _deleteRecord(meal),
          child: GestureDetector(
        onTap: () => _editRecord(meal),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Theme.of(context).dividerColor),
            boxShadow: [BoxShadow(color: Theme.of(context).colorScheme.primary.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: Row(children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(color: primaryLight, borderRadius: BorderRadius.circular(12)),
              child: const Center(child: Text('🍽️', style: TextStyle(fontSize: 20))),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(meal.name,
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Theme.of(context).colorScheme.onSurface)),
                const SizedBox(height: 2),
                Text(
                  '${meal.quantity.toStringAsFixed(0)}${meal.unit} · ${meal.time}',
                  style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.75)),
                ),
              ]),
            ),
            Icon(Icons.edit_outlined, size: 16, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.75)),
            const SizedBox(width: 10),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(meal.calories.toStringAsFixed(0),
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: primary)),
              Text('kcal', style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.75))),
            ]),
          ]),
        ),
      ),
    );
  }

  Widget _buildFormCard() {
    final cs = Theme.of(context).colorScheme;
    final primary = cs.primary;
    final primaryLight = primary.withOpacity(0.12);
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Theme.of(context).colorScheme.primary.withOpacity(0.08), blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(color: primaryLight, borderRadius: BorderRadius.circular(10)),
                child: Icon(Icons.add_circle_outline, color: primary, size: 20),
              ),
              const SizedBox(width: 10),
              Text('Registrar Alimento',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface)),
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
            if (_foodFound) ...[_buildNutritionPreview(), const SizedBox(height: 16)],
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveRecord,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary, foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: _isSaving
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.save_outlined, size: 18),
                          SizedBox(width: 8),
                          Text('Guardar Registro', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                        ],
                      ),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildNameField() {
    return Column(children: [
      TextFormField(
        controller: _nameCtrl,
        textCapitalization: TextCapitalization.sentences,
        decoration: _inputDecoration(label: 'Nombre del alimento', hint: 'Ej. manzana, pollo, arroz...', icon: Icons.restaurant_outlined),
        validator: (v) => (v == null || v.trim().isEmpty) ? 'Escribe el nombre del alimento' : null,
      ),
        if (_showSuggestions)
        Container(
          margin: const EdgeInsets.only(top: 4),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).dividerColor),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: Column(
            children: _suggestions.map((food) => InkWell(
              onTap: () => _selectSuggestion(food),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(children: [
                    Icon(Icons.search, size: 16, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.75)),
                  const SizedBox(width: 8),
                    Text(food, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 14)),
                ]),
              ),
            )).toList(),
          ),
        ),
    ]);
  }

  Widget _buildQuantityField() {
    return TextFormField(
      controller: _quantityCtrl,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
      decoration: _inputDecoration(label: 'Cantidad', hint: 'Ej. 150', icon: Icons.scale_outlined),
      validator: (v) {
        if (v == null || v.isEmpty) return 'Ingresa la cantidad';
        if ((double.tryParse(v) ?? 0) <= 0) return 'Cantidad inválida';
        return null;
      },
    );
  }

  Widget _buildUnitDropdown() {
    final name = _nameCtrl.text.trim();
    final key = _findFoodKey(name);
    // Si el alimento está en la base local, usamos sus unidades válidas.
    // Si no está local, es un alimento USDA online y solo podemos calcularlo en gramos.
    final units = key != null ? getValidUnits(key) : ['g'];
    if (!units.contains(_selectedUnit)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _selectedUnit = units.first);
      });
    }
    return DropdownButtonFormField<String>(
      initialValue: _selectedUnit,
      decoration: _inputDecoration(label: 'Unidad', hint: '', icon: Icons.straighten_outlined),
      items: units.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
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
          color: Theme.of(context).inputDecorationTheme.fillColor ?? Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Row(children: [
            Icon(Icons.access_time_outlined, color: Theme.of(context).colorScheme.primary, size: 20),
            const SizedBox(width: 10),
            Text('Hora de consumo', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.75), fontSize: 13)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
              child: Text(_selectedTime.format(context),
                  style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w600, fontSize: 14)),
            ),
          ]),
      ),
    );
  }

  Widget _buildNutritionPreview() {
    final cs = Theme.of(context).colorScheme;
    final primary = cs.primary;
    final primaryLight = Theme.of(context).brightness == Brightness.dark ? primary.withOpacity(0.12) : primary.withOpacity(0.12);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: primaryLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: primary.withOpacity(0.2)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.auto_awesome, color: primary, size: 14),
          const SizedBox(width: 6),
          Text('Aporte nutricional estimado',
              style: TextStyle(color: primary, fontSize: 12, fontWeight: FontWeight.w600)),
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
      ]),
    );
  }

  Widget _previewItem(String label, String value) {
    return Column(children: [
      Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Theme.of(context).colorScheme.onSurface)),
      Text(label, style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.75))),
    ]);
  }

  Widget _buildEmptyState(String msg) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(children: [
        const Text('🥗', style: TextStyle(fontSize: 40)),
        const SizedBox(height: 10),
        Text(msg, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.75), fontSize: 14)),
        const SizedBox(height: 4),
        Text('¡Empieza registrando tu primer alimento!',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), fontSize: 12)),
      ]),
    );
  }

  String _dayKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  bool _isToday(DateTime d) {
    final now = DateTime.now();
    return d.year == now.year && d.month == now.month && d.day == now.day;
  }

  List<MealRecord> _filterToday(List<MealRecord> meals) {
    final now = DateTime.now();
    return meals.where((m) =>
        m.date.year == now.year &&
        m.date.month == now.month &&
        m.date.day == now.day).toList();
  }

  String _formatDate(DateTime d) {
    const months = ['', 'ene', 'feb', 'mar', 'abr', 'may', 'jun',
                    'jul', 'ago', 'sep', 'oct', 'nov', 'dic'];
    const days   = ['', 'lun', 'mar', 'mié', 'jue', 'vie', 'sáb', 'dom'];
    return '${days[d.weekday]} ${d.day} de ${months[d.month]}';
  }

  void _showSnack(String msg, Color color, {IconData? icon}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        if (icon != null) ...[Icon(icon, color: Colors.white), const SizedBox(width: 10)],
        Text(msg),
      ]),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      duration: const Duration(seconds: 2),
    ));
  }

  InputDecoration _inputDecoration({required String label, required String hint, required IconData icon}) {
    final cs = Theme.of(context).colorScheme;
    return InputDecoration(
      labelText: label, hintText: hint,
      prefixIcon: Icon(icon, color: cs.primary, size: 20),
      labelStyle: TextStyle(color: cs.onSurface.withOpacity(0.75), fontSize: 13),
      hintStyle: TextStyle(color: cs.onSurface.withOpacity(0.5), fontSize: 13),
      filled: true, fillColor: Theme.of(context).inputDecorationTheme.fillColor ?? Theme.of(context).cardColor,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Theme.of(context).dividerColor)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Theme.of(context).dividerColor)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: cs.primary, width: 1.5)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.redAccent)),
      focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.redAccent, width: 1.5)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    );
  }
}