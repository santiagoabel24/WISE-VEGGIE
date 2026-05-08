import 'package:flutter/material.dart';
import '../services/auth_service.dart'; // ← para cerrar sesión
import 'dashboard_screen.dart';
import 'intake_screen.dart';
import 'profile_screen.dart';
import 'chat_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const IntakeScreen(),
    const Scaffold(
        body: Center(
            child: Text(
                'Pantalla de Educación Nutricional en construcción'))),
  ];

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
      // El StreamBuilder en main.dart detecta el cambio y redirige al login
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wise Wigie',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: false,
        actions: [
          // ── Ícono de perfil ──
          IconButton(
            icon: const Icon(Icons.account_circle, size: 30),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ProfileScreen()),
              );
            },
          ),

          // ── Botón cerrar sesión ──
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            tooltip: 'Cerrar sesión',
            onPressed: _logout,
          ),

          const SizedBox(width: 6),
        ],
      ),
      body: _screens[_currentIndex],

      // ── Chat flotante ──
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2D6A4F),
        child: const Icon(Icons.chat_bubble_outline, color: Colors.white),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => NutriBotChatScreen()),
          );
        },
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFF2D6A4F),
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: 'Registro',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: 'Aprender',
          ),
        ],
      ),
    );
  }
}