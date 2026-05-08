import 'package:flutter/material.dart';
import 'dart:ui';

void main() {
  runApp(const WiseVeggieApp());
}

class WiseVeggieApp extends StatelessWidget {
  const WiseVeggieApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Wise Veggie',
      theme: ThemeData(
        fontFamily: 'Arial',
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF8EE4AF)),
      ),
      // La app inicia en el Index (Login)
      home: const IndexPage(),
    );
  }
}

// --- COMPONENTE REUTILIZABLE: FONDO CON GRADIENTE Y OVERLAY ---
class SharedBackground extends StatelessWidget {
  final Widget child;
  const SharedBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Gradiente de fondo 
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFD8FFD8), Color(0xFFB7F5C5), Color(0xFFE8FFE8)],
              ),
            ),
          ),
          // Imagen de fondo con opacidad y desenfoque (plaidgreen.png)
          Opacity(
            opacity: 0.12,
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/plaidgreen.png'), 
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SafeArea(child: child),
        ],
      ),
    );
  }
}

// --- 1. INDEX PAGE (LOGIN) ---
class IndexPage extends StatelessWidget {
  const IndexPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SharedBackground(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                width: 900,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Column(
                  children: [
                    // Sección Logo
                    Container(
                      padding: const EdgeInsets.all(40),
                      width: double.infinity,
                      color: Colors.white.withOpacity(0.25),
                      child: Column(
                        children: [
                          // Aquí mandamos llamar tu logo
                          Image.asset(
                            'assets/logoWV.png',
                            width: 180,
                            height: 180,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(height: 10),
                          const Text('WISE VEGGIE', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 1)),
                        ],
                      ),
                    ),
                    // Formulario Login
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 50),
                      child: Column(
                        children: [
                          const Text('INICIAR SESIÓN', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 30),
                          _buildInput('Nombre de Usuario'),
                          const SizedBox(height: 18),
                          _buildInput('Contraseña', isPassword: true),
                          const SizedBox(height: 25),
                          _buildButton('ENTRAR', () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const BienvenidaPage()));
                          }),
                          const SizedBox(height: 25),
                          const Text('Accede a tu cuenta para continuar.', textAlign: TextAlign.center),
                          TextButton(
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const RegistroPage()));
                            },
                            child: const Text('CREAR CUENTA', style: TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.underline, color: Colors.black)),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// --- 2. REGISTRO PAGE (CREAR CUENTA) ---
class RegistroPage extends StatelessWidget {
  const RegistroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SharedBackground(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.35),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Column(
              children: [
                const Text('CREAR CUENTA', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                _buildInput('Nombre de Usuario'),
                const SizedBox(height: 10),
                _buildInput('Correo Electrónico'),
                const SizedBox(height: 10),
                _buildInput('Edad'),
                const SizedBox(height: 10),
                _buildInput('Estatura'),
                const SizedBox(height: 10),
                _buildInput('Contraseña', isPassword: true),
                const SizedBox(height: 20),
                _buildButton('CREAR CUENTA', () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const BienvenidaPage()));
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- 3. BIENVENIDA PAGE ---
class BienvenidaPage extends StatelessWidget {
  const BienvenidaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SharedBackground(
      child: Center(
        child: Container(
          width: 500,
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(50),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.35),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Tu logo en la página de bienvenida
              Image.asset(
                'assets/logoWV.png',
                width: 140,
                height: 140,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 20),
              const Text('¡Bienvenido!', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold)),
              const Text(
                'Gracias por formar parte de Wise Veggie 🌱\nTu camino saludable comienza hoy.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 30),
              _buildButton('SIGUIENTE', () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const DashboardPage()));
              }),
            ],
          ),
        ),
      ),
    );
  }
}

// --- 4. DASHBOARD PAGE (INICIO) ---
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SharedBackground(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            // Card de Bienvenida
            _buildCard(
              child: Column(
                children: [
                  const Text('¡Hola de nuevo! 🌱', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                  const Text('Te sugerimos registrar la comida de hoy.'),
                  const SizedBox(height: 15),
                  _buildButton('Registrar comida', () {}),
                ],
              ),
            ),
            const SizedBox(height: 25),
            // Calendario (Simulado)
            _buildCard(
              child: Column(
                children: [
                  const Text('Registros anteriores', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5, mainAxisSpacing: 10, crossAxisSpacing: 10),
                    itemCount: 30,
                    itemBuilder: (context, index) => Container(
                      decoration: BoxDecoration(color: const Color(0xFFDFF7DF), borderRadius: BorderRadius.circular(12)),
                      child: Center(child: Text('${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold))),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
            // Gráfica Plato del Buen Comer
            _buildCard(
              child: Column(
                children: [
                  const Text('Plato del Buen Comer', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  Container(
                    width: 200,
                    height: 200,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: SweepGradient(
                        colors: [Color(0xFF7ED957), Color(0xFFF4D35E), Color(0xFFFF9F1C), Color(0xFF4EA8DE), Color(0xFF7ED957)],
                        stops: [0.0, 0.25, 0.5, 0.75, 1.0],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('🥬 Verduras | 🌾 Cereales | 🫘 Leguminosas'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- HELPERS DE UI ---

Widget _buildInput(String hint, {bool isPassword = false}) {
  return TextField(
    obscureText: isPassword,
    decoration: InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFBFEBB3).withOpacity(0.85),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    ),
  );
}

Widget _buildButton(String text, VoidCallback onPressed) {
  return Container(
    width: double.infinity,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(30),
      gradient: const LinearGradient(colors: [Color(0xFFB7EFC5), Color(0xFF8EE4AF)]),
    ),
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        padding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      child: Text(text, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
    ),
  );
}

Widget _buildCard({required Widget child}) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(30),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.35),
      borderRadius: BorderRadius.circular(25),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))],
    ),
    child: child,
  );
}