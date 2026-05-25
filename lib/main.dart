import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

import 'models/intake_provider.dart';
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
      ],
      child: const WiseVeggieApp(),
    ),
  );
}

class WiseVeggieApp extends StatelessWidget {
  const WiseVeggieApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Wise Wigie',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Arial',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8EE4AF),
          primary: const Color(0xFF2D6A4F),
          secondary: const Color(0xFF8EE4AF),
          surface: const Color(0xFFF0FFF0),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white.withOpacity(0.8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      // StreamBuilder detecta si hay sesión activa automáticamente
      // Usuario logueado → HomeScreen directo (sin pasar por login)
      // Sin sesión → LoginSelector (selección de rol)
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              backgroundColor: Color(0xFFF0FFF0),
              body: Center(
                child: CircularProgressIndicator(color: Color(0xFF2D6A4F)),
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
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.eco, size: 80,
                  color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 10),
              Text(
                "Wise Wigie",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const Text("Tu guía nutricional inteligente",
                  style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 50),
              const Text("¿Cómo vas a ingresar hoy?",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
              const SizedBox(height: 30),

              _buildRoleCard(context,
                  title: "Soy Paciente",
                  subtitle: "Registra tu ingesta y ve tu progreso",
                  icon: Icons.person,
                  color: const Color(0xFF2D6A4F),
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(
                          builder: (_) => const AuthScreen(role: "Paciente")))),

              _buildRoleCard(context,
                  title: "Soy Nutricionista",
                  subtitle: "Monitorea pacientes y asigna dietas",
                  icon: Icons.monitor_heart,
                  color: const Color(0xFF52B788),
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(
                          builder: (_) => const AuthScreen(role: "Nutricionista")))),

              _buildRoleCard(context,
                  title: "Soy Familiar / Encargado",
                  subtitle: "Alertas de consumo y estadísticas",
                  icon: Icons.family_restroom,
                  color: const Color(0xFF1B4332),
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(
                          builder: (_) => const AuthScreen(role: "Familiar / Encargado")))),
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
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: color.withOpacity(0.2), width: 1),
      ),
      color: Colors.white,
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(title,
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 18)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 13)),
        trailing: const Icon(Icons.arrow_forward_ios,
            size: 16, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}