import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

import 'models/intake_provider.dart';
import 'providers/theme_provider.dart'; // ← nuevo
import 'screens/home_screen.dart';
import 'screens/auth_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => IntakeProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()), // ← nuevo
      ],
      child: const WiseVeggieApp(),
    ),
  );
}

class WiseVeggieApp extends StatelessWidget {
  const WiseVeggieApp({super.key});

  // ── Tema claro ──
  static final _lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Arial',
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF8EE4AF),
      brightness: Brightness.light,
      primary:   const Color(0xFF2D6A4F),
      secondary: const Color(0xFF8EE4AF),
      surface:   const Color(0xFFF0FFF0),
    ),
    scaffoldBackgroundColor: const Color(0xFFFAF7F2),
    cardColor: Colors.white,
      inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white.withAlpha((0.8 * 255).round()),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );

  // ── Tema oscuro ──
  static final _darkTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Arial',
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF8EE4AF),
      brightness: Brightness.dark,
      primary:   const Color(0xFF52B788),
      secondary: const Color(0xFF8EE4AF),
      surface:   const Color(0xFF1E1E1E),
    ),
    scaffoldBackgroundColor: const Color(0xFF121212),
    cardColor: const Color(0xFF1E1E1E),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF2A2A2A),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Wise Veggie',
      theme:     _lightTheme,
      darkTheme: _darkTheme,
      themeMode: themeProvider.isDark ? ThemeMode.dark : ThemeMode.light,

      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              body: Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            );
          }
          if (snapshot.hasData && snapshot.data != null) {
            return const HomeScreen();
          }
          return const LoginSelector();
        },
      ),
    );
  }
}

class LoginSelector extends StatelessWidget {
  const LoginSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 150,
                width: 150,
                decoration: BoxDecoration(
                
                ),
                child: ClipRRect(
  
                  child: Image.asset('assets/logoWV.png', fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Wise Veggie',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: cs.primary,
                ),
              ),
              const Text('Tu guía nutricional inteligente',
                  style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 50),
              const Text('¿Cómo vas a ingresar hoy?',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
              const SizedBox(height: 30),

                // Solo opción de usuario (Paciente) por el momento
                _buildRoleCard(context,
                  title: 'Soy Paciente',
                  subtitle: 'Registra tu ingesta y ve tu progreso',
                  icon: Icons.person,
                  color: const Color(0xFF2D6A4F),
                  onTap: () => Navigator.push(context,
                    MaterialPageRoute(
                      builder: (_) => const AuthScreen(role: 'Paciente')))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard(BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: color.withAlpha((0.3 * 255).round()), width: 1),
      ),
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        leading: CircleAvatar(
          backgroundColor: color.withAlpha((0.15 * 255).round()),
          child: Icon(icon, color: color),
        ),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 13)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}