import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Colores
  static const _verde     = Color(0xFF1A6B4A);
  static const _verdeClaro = Color(0xFFE8F5EE);
  static const _cafe      = Color(0xFF3D2B1F);
  static const _cafeMedio = Color(0xFF7A5C4A);
  static const _crema     = Color(0xFFFAF7F2);

  String _name  = 'Cargando...';
  String _email = 'Cargando...';
  bool   _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // ── Cargar datos reales desde Firestore ──
  Future<void> _loadUserData() async {
    final data = await AuthService().getUserData();
    if (!mounted) return;
    setState(() {
      _name    = data?['name']  ?? 'Usuario';
      _email   = data?['email'] ?? AuthService().currentUser?.email ?? '';
      _loading = false;
    });
  }

  // ── Cerrar sesión con confirmación ──
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

    if (confirm == true) {
      await AuthService().logout();
      // El StreamBuilder en main.dart redirige al login automáticamente
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _crema,
      appBar: AppBar(
        title: const Text('Mi Cuenta',
            style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: _cafe,
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
                      color: _verdeClaro,
                      shape: BoxShape.circle,
                      border: Border.all(color: _verde, width: 2),
                    ),
                    child: const Icon(Icons.person,
                        size: 52, color: _verde),
                  ),
                  const SizedBox(height: 16),

                  // ── Nombre ──
                  Text(_name,
                      style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: _cafe)),
                  const SizedBox(height: 4),

                  // ── Email ──
                  Text(_email,
                      style: const TextStyle(
                          fontSize: 14, color: _cafeMedio)),

                  const SizedBox(height: 32),
                  const Divider(),
                  const SizedBox(height: 16),

                  // ── Botón cerrar sesión ──
                  ListTile(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    tileColor: Colors.red.shade50,
                    leading: const Icon(Icons.logout,
                        color: Colors.redAccent),
                    title: const Text('Cerrar sesión',
                        style: TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.w600)),
                    onTap: _logout,
                  ),
                ],
              ),
            ),
    );
  }
}