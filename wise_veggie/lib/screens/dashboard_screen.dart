import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/meal_service.dart';
import '../services/water_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // (Legacy color constants removed; using Theme data instead)

  // Theme-derived colors
  bool get isDark => Theme.of(context).brightness == Brightness.dark;

  Color get bgColor => Theme.of(context).scaffoldBackgroundColor;
  Color get cardColor => Theme.of(context).cardColor;
  Color get textColor => Theme.of(context).colorScheme.onSurface;
  Color get textDimColor => Theme.of(context).colorScheme.onSurface.withOpacity(0.75);
  Color get borderColor => Theme.of(context).dividerColor;
  Color get highlightColor => Theme.of(context).colorScheme.primary.withOpacity(isDark ? 0.2 : 0.12);
  Color get inactiveDayColor => Theme.of(context).dividerColor.withOpacity(0.08);

  // ── Servicios ──
  final _mealService  = MealService();
  final _waterService = WaterService();

  // ── Datos del usuario ──
  String _userName    = 'Cargando...';
  bool   _loadingUser = true;

  // ── Racha real ──
  int  _streakDays    = 0;
  bool _loadingStreak = true;

  // ── Metas fijas ──
  final double waterGoal = 2.5;
  final double calGoal   = 2000;

  final DateTime _today = DateTime.now();

  // ── Saludo dinámico ──
  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return '¡Buenos días';
    if (h < 18) return '¡Buenas tardes';
    return '¡Buenas noches';
  }

  String get _greetingEmoji {
    final h = DateTime.now().hour;
    if (h < 12) return '☀️';
    if (h < 18) return '🌤️';
    return '🌙';
  }

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _loadStreak();
  }

  Future<void> _loadUserName() async {
    final data = await AuthService().getUserData();
    if (!mounted) return;
    setState(() {
      _userName    = data?['name'] ?? 'Usuario';
      _loadingUser = false;
    });
  }

  Future<void> _loadStreak() async {
    final streak = await _waterService.calculateStreak();
    if (!mounted) return;
    setState(() {
      _streakDays    = streak;
      _loadingStreak = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<MealRecord>>(
      stream: _mealService.getTodayMeals(),
      builder: (context, mealSnap) {
        final meals      = mealSnap.data ?? [];
        final calToday   = meals.fold(0.0, (s, m) => s + m.calories);
        final totalProt  = meals.fold(0.0, (s, m) => s + m.proteins);
        final totalCarbs = meals.fold(0.0, (s, m) => s + m.carbs);
        final totalFats  = meals.fold(0.0, (s, m) => s + m.fats);

        return StreamBuilder<double>(
          stream: _waterService.streamTodayWater(),
          builder: (context, waterSnap) {
            final waterDrank = waterSnap.data ?? 0.0;

            return StreamBuilder<Set<int>>(
              stream: _waterService.streamActiveDaysThisMonth(),
              builder: (context, daysSnap) {
                final activeDays = daysSnap.data ?? {};

                return Scaffold(
                  backgroundColor: bgColor, // ← Color dinámico
                  body: CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: _buildHeader(calToday),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            _buildStatsRow(calToday, waterDrank, activeDays),
                            const SizedBox(height: 16),
                            _buildWaterCard(waterDrank),
                            const SizedBox(height: 16),
                            _buildNutritionCard(totalProt, totalCarbs, totalFats),
                            const SizedBox(height: 16),
                            _buildCalendarCard(activeDays),
                            const SizedBox(height: 16),
                            _buildTipCard(),
                          ]),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  // ─────────────────────────────────────────────
  // HEADER (Mantiene sus colores porque es verde oscuro)
  // ─────────────────────────────────────────────
  Widget _buildHeader(double calToday) {
    final remaining = calGoal - calToday;
    final isOver    = remaining < 0;
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [cs.primary, cs.secondary ?? cs.primary.withOpacity(0.9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$_greeting, ${_loadingUser ? '...' : _userName}! $_greetingEmoji',
                    style: TextStyle(
                        color: cs.onPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(_today),
                    style: TextStyle(
                        color: cs.onPrimary.withOpacity(0.85), fontSize: 13),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: cs.onPrimary.withOpacity(0.18),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(children: [
                const Text('🔥', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 6),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _loadingStreak ? '...' : '$_streakDays días',
                      style: TextStyle(
                          color: cs.onPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14),
                    ),
                    Text('racha',
                        style: TextStyle(
                            color: cs.onPrimary.withOpacity(0.75),
                            fontSize: 10)),
                  ],
                ),
              ]),
            ),
          ]),

          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Calorías de hoy',
                      style: TextStyle(color: Colors.white70, fontSize: 13)),
                  Text(
                    '${calToday.toInt()} / ${calGoal.toInt()} kcal',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (calToday / calGoal).clamp(0.0, 1.0),
                  minHeight: 8,
                  backgroundColor: Colors.white24,
                  valueColor: AlwaysStoppedAnimation(
                      isOver ? Colors.redAccent : Colors.white),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isOver
                    ? '+${(-remaining).toInt()} kcal sobre tu meta'
                    : '${remaining.toInt()} kcal restantes para tu meta',
                style: TextStyle(
                    color: Colors.white.withOpacity(0.75), fontSize: 11),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // FILA DE ESTADÍSTICAS
  // ─────────────────────────────────────────────
  Widget _buildStatsRow(
      double calToday, double waterDrank, Set<int> activeDays) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(children: [
        _statCard('💧', 'Agua',
            '${waterDrank.toStringAsFixed(1)}L',
            '/ ${waterGoal.toStringAsFixed(1)}L'),
        const SizedBox(width: 10),
        _statCard('🔥', 'Calorías',
            '${calToday.toInt()}',
            '/ ${calGoal.toInt()} kcal'),
        const SizedBox(width: 10),
        _statCard('📅', 'Días activos',
            '${activeDays.length}',
            'este mes'),
      ]),
    );
  }

  Widget _statCard(String emoji, String label, String value, String sub) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: cardColor, // ← Dinámico
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor), // ← Dinámico
          boxShadow: [
            if (!isDark) // Quitamos la sombra en modo oscuro para que se vea más limpio
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
          ],
        ),
        child: Column(children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 16, color: textColor)), // ← Dinámico
          Text(sub,
              style: TextStyle(fontSize: 10, color: textDimColor), // ← Dinámico
              textAlign: TextAlign.center),
          const SizedBox(height: 2),
            Text(label,
              style: TextStyle(
                fontSize: 11,
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w500)),
        ]),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // TARJETA DE AGUA
  // ─────────────────────────────────────────────
  Widget _buildWaterCard(double waterDrank) {
    final pct     = (waterDrank / waterGoal).clamp(0.0, 1.0);
    final glasses = (waterDrank / 0.25).round();

    return _card(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _cardHeader('💧', 'Hidratación del día', '$glasses vasos bebidos'),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                '${waterDrank.toStringAsFixed(2)} de ${waterGoal.toStringAsFixed(1)} litros',
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 15, color: textColor), // ← Dinámico
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: pct,
                  minHeight: 10,
                  backgroundColor: highlightColor, // ← Dinámico
                  valueColor:
                      const AlwaysStoppedAnimation(Color(0xFF38BDF8)),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                pct >= 1.0
                    ? '¡Meta de hidratación alcanzada! 🎉'
                    : 'Te faltan ${(waterGoal - waterDrank).toStringAsFixed(2)}L para tu meta',
                style: TextStyle(fontSize: 11, color: textDimColor), // ← Dinámico
              ),
            ]),
          ),
          const SizedBox(width: 16),
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0369A1).withOpacity(0.3) : const Color(0xFFE0F7FF), // ← Dinámico
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
                child: Text('🥤', style: TextStyle(fontSize: 28))),
          ),
        ]),

        const SizedBox(height: 14),

        Row(children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _waterService.removeWater(0.25),
              icon: const Icon(Icons.remove, size: 16),
              label: const Text('-1 vaso'),
              style: OutlinedButton.styleFrom(
                foregroundColor: textDimColor, // ← Dinámico
                side: BorderSide(color: borderColor), // ← Dinámico
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _waterService.addWater(0.25),
              icon: const Icon(Icons.add, size: 16),
              label: const Text('+1 vaso'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF38BDF8),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 56,
            child: OutlinedButton(
              onPressed: _showAddWaterDialog,
              style: OutlinedButton.styleFrom(
                foregroundColor: textDimColor,
                side: BorderSide(color: borderColor),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
              child: const Icon(Icons.edit, size: 18),
            ),
          ),
        ]),
      ]),
    );
  }

  Future<void> _showAddWaterDialog() async {
    final controller = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Añadir agua (ml)'),
          content: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              hintText: 'Ej. 250 (ml)',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final text = controller.text.trim();
                if (text.isEmpty) return;
                final value = double.tryParse(text.replaceAll(',', '.'));
                if (value == null || value <= 0) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Introduce un número válido')),
                    );
                  }
                  return;
                }

                final liters = value / 1000.0;
                await _waterService.addWater(liters);
                if (mounted) Navigator.of(context).pop();
              },
              child: const Text('Añadir'),
            ),
          ],
        );
      },
    );
  }

  // ─────────────────────────────────────────────
  // TARJETA DE NUTRICIÓN
  // ─────────────────────────────────────────────
  Widget _buildNutritionCard(
      double totalProt, double totalCarbs, double totalFats) {
    return _card(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _cardHeader('🥗', 'Macronutrientes', 'resumen de hoy'),
        const SizedBox(height: 14),
        Row(children: [
          _macroBar('Proteínas', totalProt,  80,  const Color(0xFF3B82F6)),
          const SizedBox(width: 10),
          _macroBar('Carbos',    totalCarbs, 250, const Color(0xFFF59E0B)),
          const SizedBox(width: 10),
          _macroBar('Grasas',    totalFats,  65,  const Color(0xFFEF4444)),
        ]),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: highlightColor, // ← Dinámico
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(children: [
            Icon(Icons.info_outline, size: 14, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'La OMS recomienda que los carbohidratos representen el 55-75% de tu energía diaria.',
                style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.primary),
              ),
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _macroBar(String label, double current, double goal, Color color) {
    final pct = (current / goal).clamp(0.0, 1.0);
    return Expanded(
      child: Column(children: [
        Text('${current.toStringAsFixed(1)}g',
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 14, color: color)),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: pct,
            minHeight: 8,
            backgroundColor: color.withOpacity(0.15),
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 10, color: textDimColor)), // ← Dinámico
        Text('/ ${goal.toInt()}g',
            style: TextStyle(
                fontSize: 9, color: textDimColor.withOpacity(0.7))), // ← Dinámico
      ]),
    );
  }

  // ─────────────────────────────────────────────
  // CALENDARIO
  // ─────────────────────────────────────────────
  Widget _buildCalendarCard(Set<int> activeDays) {
    final daysInMonth =
        DateUtils.getDaysInMonth(_today.year, _today.month);
    final firstDay =
        DateTime(_today.year, _today.month, 1).weekday % 7;

    return _card(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _cardHeader('📆', 'Constancia del mes',
            '${activeDays.length} días activos'),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: ['D', 'L', 'M', 'X', 'J', 'V', 'S']
              .map((d) => SizedBox(
                    width: 36,
                    child: Text(d,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: textDimColor)), // ← Dinámico
                  ))
              .toList(),
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 6,
            crossAxisSpacing: 6,
            childAspectRatio: 1,
          ),
          itemCount: firstDay + daysInMonth,
          itemBuilder: (context, i) {
            if (i < firstDay) return const SizedBox();
            final day      = i - firstDay + 1;
            final isToday  = day == _today.day;
            final isActive = activeDays.contains(day);
            final isFuture = day > _today.day;

            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: isToday
                  ? Theme.of(context).colorScheme.primary
                  : isActive
                    ? highlightColor // ← Dinámico
                    : isFuture
                      ? Colors.transparent
                      : inactiveDayColor, // ← Dinámico
                shape: BoxShape.circle,
                border: isToday
                  ? null
                  : Border.all(
                    color: isActive
                      ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
                      : Colors.transparent),
              ),
              child: Center(
                child: Text(
                  '$day',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight:
                        isToday ? FontWeight.bold : FontWeight.normal,
                    color: isToday
                      ? Theme.of(context).colorScheme.onPrimary
                      : isActive
                        ? Theme.of(context).colorScheme.primary // ← Dinámico
                        : isFuture
                          ? textDimColor.withOpacity(0.3) // ← Dinámico
                          : textDimColor, // ← Dinámico
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 14),
        Row(children: [
          _legend(Theme.of(context).colorScheme.primary, 'Hoy'),
          const SizedBox(width: 16),
          _legend(highlightColor, 'Activo'), // ← Dinámico
          const SizedBox(width: 16),
          _legend(inactiveDayColor, 'Sin registro'), // ← Dinámico
        ]),
      ]),
    );
  }

  Widget _legend(Color color, String label) {
    return Row(children: [
      Container(
        width: 12, height: 12,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: borderColor), // ← Dinámico
        ),
      ),
      const SizedBox(width: 4),
      Text(label, style: TextStyle(fontSize: 11, color: textDimColor)), // ← Dinámico
    ]);
  }

  // ─────────────────────────────────────────────
  // CONSEJO OMS (Mantiene sus colores porque es fondo oscuro)
  // ─────────────────────────────────────────────
  Widget _buildTipCard() {
    final tips = [
      {'emoji': '🥦', 'tip': 'Come al menos 400g de frutas y verduras al día para reducir el riesgo de enfermedades crónicas.'},
      {'emoji': '🧂', 'tip': 'Reduce el consumo de sal a menos de 5g por día para proteger tu corazón.'},
      {'emoji': '💧', 'tip': 'El agua es esencial. La OMS recomienda beber entre 1.5 y 2 litros diarios.'},
      {'emoji': '🚶', 'tip': 'La OMS recomienda al menos 150 minutos de actividad física moderada a la semana.'},
      {'emoji': '🌾', 'tip': 'Prefiere cereales integrales sobre refinados. Tienen más fibra y nutrientes.'},
    ];
    final tip = tips[_today.day % tips.length];

    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [cs.primary, cs.secondary ?? cs.primary.withOpacity(0.9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(children: [
        Container(
          width: 52, height: 52,
          decoration: BoxDecoration(
            color: cs.onPrimary.withOpacity(0.18),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
              child: Text(tip['emoji']!, style: const TextStyle(fontSize: 26))),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Consejo OMS del día',
                style: TextStyle(
                    color: cs.onPrimary.withOpacity(0.9),
                    fontSize: 11,
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            Text(tip['tip']!,
                style: TextStyle(
                    color: cs.onPrimary, fontSize: 13, height: 1.4)),
          ]),
        ),
      ]),
    );
  }

  // ─────────────────────────────────────────────
  // HELPERS GLOBALES
  // ─────────────────────────────────────────────
  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor, // ← Dinámico
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor), // ← Dinámico
        boxShadow: [
          if (!isDark) // Quitamos la sombra en modo oscuro para que se vea más limpio
            BoxShadow(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
        ],
      ),
      child: child,
    );
  }

  Widget _cardHeader(String emoji, String title, String subtitle) {
    return Row(children: [
      Container(
        width: 38, height: 38,
        decoration: BoxDecoration(
          color: highlightColor, // ← Dinámico
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(child: Text(emoji, style: const TextStyle(fontSize: 18))),
      ),
      const SizedBox(width: 10),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style: TextStyle(
                fontWeight: FontWeight.w600, fontSize: 14, color: textColor)), // ← Dinámico
        Text(subtitle,
            style: TextStyle(fontSize: 11, color: textDimColor)), // ← Dinámico
      ]),
    ]);
  }

  String _formatDate(DateTime d) {
    const months = [
      '', 'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
      'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
    ];
    const days = [
      '', 'lunes', 'martes', 'miércoles',
      'jueves', 'viernes', 'sábado', 'domingo'
    ];
    return '${days[d.weekday]}, ${d.day} de ${months[d.month]}';
  }
}