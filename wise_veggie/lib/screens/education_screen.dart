import 'dart:math';
import 'package:flutter/material.dart';
import '../data/recommendations_data.dart';

/// Pantalla de Recomendaciones:
/// • Muestra 6 tarjetas aleatorias cada vez que entras o sales.
/// • Botón "Mezclar" para barajar de nuevo sin salir.
/// • Toca una tarjeta para ver el detalle completo en un bottom sheet.
class RecommendationsScreen extends StatefulWidget {
  const RecommendationsScreen({super.key});

  @override
  State<RecommendationsScreen> createState() => _RecommendationsScreenState();
}

class _RecommendationsScreenState extends State<RecommendationsScreen> {
  static const _verde      = Color(0xFF1A6B4A);
  static const _verdeClaro = Color(0xFFE8F5EE);
  static const _crema      = Color(0xFFFAF7F2);
  static const _cafe       = Color(0xFF3D2B1F);
  static const _cafeMedio  = Color(0xFF7A5C4A);

  static const int _cardCount = 6;

  late List<Recommendation> _displayed;
  final _random = Random();

  @override
  void initState() {
    super.initState();
    _reshuffle();
  }

  // Se vuelve a barajar cada vez que el usuario navega a esta pantalla
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reshuffle();
  }

  void _reshuffle() {
    final list = List<Recommendation>.from(allRecommendations)..shuffle(_random);
    setState(() => _displayed = list.take(_cardCount).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _crema,
      body: CustomScrollView(
        slivers: [
          // ── AppBar ────────────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: _verde,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(background: _buildHeader()),
            title: const Text('Recomendaciones',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                tooltip: 'Mezclar',
                onPressed: _reshuffle,
              ),
            ],
          ),

          // ── Subtítulo + botón mezclar ──────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
              child: Row(children: [
                Expanded(
                  child: Text(
                    '${_displayed.length} consejos para ti hoy',
                    style: const TextStyle(fontSize: 13, color: _cafeMedio),
                  ),
                ),
                GestureDetector(
                  onTap: _reshuffle,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _verdeClaro,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _verde.withOpacity(0.3)),
                    ),
                    child: const Row(children: [
                      Icon(Icons.shuffle_rounded, size: 13, color: _verde),
                      SizedBox(width: 4),
                      Text('Mezclar',
                          style: TextStyle(
                              fontSize: 12,
                              color: _verde,
                              fontWeight: FontWeight.w600)),
                    ]),
                  ),
                ),
              ]),
            ),
          ),

          // ── Lista de tarjetas ─────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _buildCard(_displayed[i]),
                ),
                childCount: _displayed.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // HEADER
  // ─────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1A6B4A), Color(0xFF2D9166)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 68, 20, 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Para ti hoy ✨',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(
            'Consejos basados en la OMS, FAO y evidencia científica',
            style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: [
              _headerChip('🥗', 'Nutrición'),
              const SizedBox(width: 8),
              _headerChip('💧', 'Hidratación'),
              const SizedBox(width: 8),
              _headerChip('🧠', 'Salud mental'),
              const SizedBox(width: 8),
              _headerChip('😴', 'Sueño'),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _headerChip(String emoji, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(children: [
        Text(emoji, style: const TextStyle(fontSize: 12)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 11)),
      ]),
    );
  }

  // ─────────────────────────────────────────────
  // TARJETA
  // ─────────────────────────────────────────────
  Widget _buildCard(Recommendation rec) {
    return GestureDetector(
      onTap: () => _showDetail(rec),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: rec.categoryColor.withOpacity(0.18)),
          boxShadow: [
            BoxShadow(
              color: rec.categoryColor.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(children: [
          // Franja izquierda con emoji
          Container(
            width: 80,
            padding: const EdgeInsets.symmetric(vertical: 22),
            decoration: BoxDecoration(
              color: rec.categoryColor.withOpacity(0.10),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                bottomLeft: Radius.circular(20),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(rec.emoji, style: const TextStyle(fontSize: 36)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: rec.categoryColor.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    rec.category,
                    style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: rec.categoryColor),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),

          // Contenido
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 16, 14, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(rec.title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: _cafe)),
                  const SizedBox(height: 6),
                  Text(
                    rec.description,
                    style: const TextStyle(
                        fontSize: 12, color: _cafeMedio, height: 1.45),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Badge OMS
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _verdeClaro,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(children: [
                          Icon(Icons.verified, size: 11, color: _verde),
                          SizedBox(width: 4),
                          Text('OMS',
                              style: TextStyle(
                                  fontSize: 10,
                                  color: _verde,
                                  fontWeight: FontWeight.w600)),
                        ]),
                      ),
                      // Ver más
                      Row(children: [
                        Text('Ver más',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: rec.categoryColor)),
                        Icon(Icons.arrow_forward_ios_rounded,
                            size: 10, color: rec.categoryColor),
                      ]),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // DETALLE (bottom sheet)
  // ─────────────────────────────────────────────
  void _showDetail(Recommendation rec) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        constraints:
            BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.72),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40, height: 4,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header coloreado
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: rec.categoryColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: rec.categoryColor.withOpacity(0.2)),
              ),
              child: Row(children: [
                Text(rec.emoji, style: const TextStyle(fontSize: 44)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: rec.categoryColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(rec.category,
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: rec.categoryColor)),
                      ),
                      const SizedBox(height: 6),
                      Text(rec.title,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: _cafe)),
                    ],
                  ),
                ),
              ]),
            ),

            // Descripción completa
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(rec.description,
                        style: const TextStyle(
                            fontSize: 15, color: _cafe, height: 1.6)),
                    const SizedBox(height: 16),
                    // Fuente OMS
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _verdeClaro,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _verde.withOpacity(0.2)),
                      ),
                      child: const Row(children: [
                        Icon(Icons.verified, size: 16, color: _verde),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Información basada en guías de la OMS, FAO y consenso científico internacional.',
                            style: TextStyle(fontSize: 12, color: _verde),
                          ),
                        ),
                      ]),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: rec.categoryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('Entendido',
                            style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}