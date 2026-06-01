import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../providers/theme_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _name    = 'Cargando...';
  String _email   = 'Cargando...';
  bool   _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final data = await AuthService().getUserData();
    if (!mounted) return;
    setState(() {
      _name    = data?['name']  ?? 'Usuario';
      _email   = data?['email'] ?? AuthService().currentUser?.email ?? '';
      _loading = false;
    });
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Cerrar sesión',
            style: TextStyle(fontWeight: FontWeight.w600)),
        content: const Text('¿Seguro que quieres cerrar tu sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar',
                style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
    if (confirm == true) await AuthService().logout();
  }

  @override
  Widget build(BuildContext context) {
    final cs     = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme  = context.watch<ThemeProvider>();

    // Colores adaptativos según el modo
    final verde      = cs.primary;
    final verdeClaro = isDark ? cs.primary.withOpacity(0.15) : const Color(0xFFE8F5EE);
    final bgCard     = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textPri    = isDark ? Colors.white : const Color(0xFF3D2B1F);
    final textSec    = isDark ? Colors.white60 : const Color(0xFF7A5C4A);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Cuenta',
            style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 16),

                  // ── Avatar ──
                  Container(
                    width: 96, height: 96,
                    decoration: BoxDecoration(
                      color: verdeClaro,
                      shape: BoxShape.circle,
                      border: Border.all(color: verde, width: 2),
                    ),
                    child: Icon(Icons.person, size: 52, color: verde),
                  ),
                  const SizedBox(height: 16),

                  // ── Nombre ──
                  Text(_name,
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: textPri)),
                  const SizedBox(height: 4),

                  // ── Email ──
                  Text(_email,
                      style: TextStyle(fontSize: 14, color: textSec)),

                  const SizedBox(height: 32),
                  const Divider(),
                  const SizedBox(height: 8),

                  // ── Toggle modo oscuro ──
                  Container(
                    decoration: BoxDecoration(
                      color: bgCard,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: isDark
                              ? Colors.white12
                              : const Color(0xFFE2D9D0)),
                    ),
                    child: ListTile(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      leading: Icon(
                        isDark
                            ? Icons.dark_mode_outlined
                            : Icons.light_mode_outlined,
                        color: verde,
                      ),
                      title: Text(
                        'Modo oscuro',
                        style: TextStyle(
                            fontWeight: FontWeight.w500, color: textPri),
                      ),
                      trailing: Switch(
                        value: theme.isDark,
                        onChanged: (_) => theme.toggle(),
                        activeThumbColor: verde,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ── Cerrar sesión ──
                  Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.redAccent.withOpacity(0.1)
                          : Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      leading: const Icon(Icons.logout,
                          color: Colors.redAccent),
                      title: const Text('Cerrar sesión',
                          style: TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.w600)),
                      onTap: _logout,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}