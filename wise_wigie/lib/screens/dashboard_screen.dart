import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import '../services/meal_service.dart';
import '../services/water_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // ── Colores del tema ──
  static const _verde      = Color(0xFF1A6B4A);
  static const _verdeClaro = Color(0xFFE8F5EE);
  static const _verdeMedio = Color(0xFF2D9166);
  static const _crema      = Color(0xFFFAF7F2);
  static const _cafe       = Color(0xFF3D2B1F);
  static const _cafeMedio  = Color(0xFF7A5C4A);

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
    // Stream de calorías reales
    return StreamBuilder<List<MealRecord>>(
      stream: _mealService.getTodayMeals(),
      builder: (context, mealSnap) {
        final meals      = mealSnap.data ?? [];
        final calToday   = meals.fold(0.0, (s, m) => s + m.calories);
        final totalProt  = meals.fold(0.0, (s, m) => s + m.proteins);
        final totalCarbs = meals.fold(0.0, (s, m) => s + m.carbs);
        final totalFats  = meals.fold(0.0, (s, m) => s + m.fats);

        // Stream de agua en tiempo real
        return StreamBuilder<double>(
          stream: _waterService.streamTodayWater(),
          builder: (context, waterSnap) {
            final waterDrank = waterSnap.data ?? 0.0;

            // Stream de días activos en tiempo real
            return StreamBuilder<Set<int>>(
              stream: _waterService.streamActiveDaysThisMonth(),
              builder: (context, daysSnap) {
                final activeDays = daysSnap.data ?? {};

                return Scaffold(
                  backgroundColor: _crema,
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
  // HEADER
  // ─────────────────────────────────────────────
  Widget _buildHeader(double calToday) {
    final remaining = calGoal - calToday;
    final isOver    = remaining < 0;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1A6B4A), Color(0xFF2D9166)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
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
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(_today),
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.8), fontSize: 13),
                  ),
                ],
              ),
            ),
            // Racha real desde Firestore
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
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
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14),
                    ),
                    Text('racha',
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.75),
                            fontSize: 10)),
                  ],
                ),
              ]),
            ),
          ]),

          const SizedBox(height: 20),

          // Barra de calorías reales
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
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
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 16, color: _cafe)),
          Text(sub,
              style: const TextStyle(fontSize: 10, color: _cafeMedio),
              textAlign: TextAlign.center),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(
                  fontSize: 11,
                  color: _verdeMedio,
                  fontWeight: FontWeight.w500)),
        ]),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // TARJETA DE AGUA — datos reales + botones +/-
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
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 15, color: _cafe),
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: pct,
                  minHeight: 10,
                  backgroundColor: _verdeClaro,
                  valueColor:
                      const AlwaysStoppedAnimation(Color(0xFF38BDF8)),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                pct >= 1.0
                    ? '¡Meta de hidratación alcanzada! 🎉'
                    : 'Te faltan ${(waterGoal - waterDrank).toStringAsFixed(2)}L para tu meta',
                style: const TextStyle(fontSize: 11, color: _cafeMedio),
              ),
            ]),
          ),
          const SizedBox(width: 16),
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFE0F7FF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
                child: Text('🥤', style: TextStyle(fontSize: 28))),
          ),
        ]),

        const SizedBox(height: 14),

        // Botones para añadir/quitar agua
        Row(children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _waterService.removeWater(0.25),
              icon: const Icon(Icons.remove, size: 16),
              label: const Text('-1 vaso'),
              style: OutlinedButton.styleFrom(
                foregroundColor: _cafeMedio,
                side: const BorderSide(color: Color(0xFFE2D9D0)),
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
        ]),
      ]),
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
            color: _verdeClaro,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Row(children: [
            Icon(Icons.info_outline, size: 14, color: _verde),
            SizedBox(width: 6),
            Expanded(
              child: Text(
                'La OMS recomienda que los carbohidratos representen el 55-75% de tu energía diaria.',
                style: TextStyle(fontSize: 11, color: _verde),
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
        Text(label, style: const TextStyle(fontSize: 10, color: _cafeMedio)),
        Text('/ ${goal.toInt()}g',
            style: TextStyle(
                fontSize: 9, color: _cafeMedio.withOpacity(0.7))),
      ]),
    );
  }

  // ─────────────────────────────────────────────
  // CALENDARIO — días activos reales desde Firestore
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
                        style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _cafeMedio)),
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
                    ? _verde
                    : isActive
                        ? _verdeClaro
                        : isFuture
                            ? Colors.transparent
                            : const Color(0xFFF0EBE6),
                shape: BoxShape.circle,
                border: isToday
                    ? null
                    : Border.all(
                        color: isActive
                            ? _verdeMedio.withOpacity(0.3)
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
                        ? Colors.white
                        : isActive
                            ? _verde
                            : isFuture
                                ? _cafeMedio.withOpacity(0.3)
                                : _cafeMedio,
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 14),
        Row(children: [
          _legend(_verde, 'Hoy'),
          const SizedBox(width: 16),
          _legend(_verdeClaro, 'Activo'),
          const SizedBox(width: 16),
          _legend(const Color(0xFFF0EBE6), 'Sin registro'),
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
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
        ),
      ),
      const SizedBox(width: 4),
      Text(label, style: const TextStyle(fontSize: 11, color: _cafeMedio)),
    ]);
  }

  // ─────────────────────────────────────────────
  // CONSEJO OMS DEL DÍA
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

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A6B4A), Color(0xFF2D9166)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _verde.withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(children: [
        Container(
          width: 52, height: 52,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
              child: Text(tip['emoji']!, style: const TextStyle(fontSize: 26))),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Consejo OMS del día',
                style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            Text(tip['tip']!,
                style: const TextStyle(
                    color: Colors.white, fontSize: 13, height: 1.4)),
          ]),
        ),
      ]),
    );
  }

  // ─────────────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────────────
  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2D9D0)),
        boxShadow: [
          BoxShadow(
            color: _verde.withOpacity(0.06),
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
          color: _verdeClaro,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(child: Text(emoji, style: const TextStyle(fontSize: 18))),
      ),
      const SizedBox(width: 10),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style: const TextStyle(
                fontWeight: FontWeight.w600, fontSize: 14, color: _cafe)),
        Text(subtitle,
            style: const TextStyle(fontSize: 11, color: _cafeMedio)),
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