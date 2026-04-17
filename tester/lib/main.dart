import 'package:flutter/material.dart';

void main() {
  runApp(const NutriApp());
}

class NutriApp extends StatelessWidget {
  const NutriApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vida Sana',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      // Ahora la pantalla principal es nuestro "Controlador" de navegación
      home: const ControladorNavegacion(),
    );
  }
}

// =======================================================
// CONTROLADOR DE NAVEGACIÓN (El que cambia las pantallas)
// =======================================================
class ControladorNavegacion extends StatefulWidget {
  const ControladorNavegacion({super.key});

  @override
  State<ControladorNavegacion> createState() => _ControladorNavegacionState();
}

class _ControladorNavegacionState extends State<ControladorNavegacion> {
  int _indiceActual = 0; // Empezamos en la pantalla 0 (Inicio)

  // Esta es la lista de nuestras 3 secciones (pantallas)
  final List<Widget> _pantallas = [
    const PantallaInicio(),
    const PantallaRecetas(),
    const PantallaPerfil(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // El 'body' va a cambiar dependiendo del botón que toques
      body: _pantallas[_indiceActual],
      
      // Aquí construimos la barra de abajo
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _indiceActual,
        onTap: (int nuevoIndice) {
          setState(() {
            _indiceActual = nuevoIndice; // Cambiamos de pantalla
          });
        },
        selectedItemColor: Colors.green[700], // Color cuando está seleccionado
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.restaurant_menu), label: 'Recetas'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}

// =======================================================
// SECCIÓN 1: INICIO (La que ya conocías)
// =======================================================
class PantallaInicio extends StatefulWidget {
  const PantallaInicio({super.key});

  @override
  State<PantallaInicio> createState() => _PantallaInicioState();
}

class _PantallaInicioState extends State<PantallaInicio> {
  int _vasosDeAgua = 0;

  void _tomarAgua() {
    setState(() { _vasosDeAgua++; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Nutrición', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green[600],
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('¡Hola! 👋', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(20)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.water_drop, color: Colors.blue, size: 40),
                      const SizedBox(width: 15),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Agua consumida', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          Text('$_vasosDeAgua / 8 vasos', style: const TextStyle(color: Colors.blueGrey)),
                        ],
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: _tomarAgua,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, shape: const CircleBorder(), padding: const EdgeInsets.all(12)),
                    child: const Icon(Icons.add, color: Colors.white),
                  )
                ],
              ),
            ),
            const SizedBox(height: 30),
            const Text('Menú del Día', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            _crearTarjetaComida('Desayuno', 'Avena con frutas', Icons.breakfast_dining, Colors.orange),
            _crearTarjetaComida('Almuerzo', 'Ensalada de pollo', Icons.lunch_dining, Colors.green),
          ],
        ),
      ),
    );
  }

  Widget _crearTarjetaComida(String titulo, String desc, IconData icono, MaterialColor color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: color[100], child: Icon(icono, color: color[700])),
        title: Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(desc),
      ),
    );
  }
}

// =======================================================
// SECCIÓN 2: RECETAS (¡Nueva!)
// =======================================================
class PantallaRecetas extends StatelessWidget {
  const PantallaRecetas({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recetas Saludables', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.orange[600],
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _crearReceta('Smoothie Verde', 'Espina, plátano y manzana', '10 min', Icons.local_drink),
          _crearReceta('Bowl de Quinoa', 'Quinoa, aguacate y garbanzos', '20 min', Icons.rice_bowl),
          _crearReceta('Wrap de Pavo', 'Tortilla integral con pavo y lechuga', '15 min', Icons.bakery_dining),
        ],
      ),
    );
  }

  Widget _crearReceta(String titulo, String desc, String tiempo, IconData icono) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 15),
      child: ListTile(
        contentPadding: const EdgeInsets.all(15),
        leading: Icon(icono, size: 40, color: Colors.orange),
        title: Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        subtitle: Text(desc),
        trailing: Text(tiempo, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

// =======================================================
// SECCIÓN 3: PERFIL (¡Nueva!)
// =======================================================
class PantallaPerfil extends StatelessWidget {
  const PantallaPerfil({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.purple[600],
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 60,
              backgroundColor: Colors.purple,
              child: Icon(Icons.person, size: 80, color: Colors.white),
            ),
            const SizedBox(height: 20),
            const Text('Usuario POCO X6', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const Text('Objetivo: Perder peso', style: TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _crearEstadistica('Peso', '70 kg'),
                _crearEstadistica('Racha', '5 días'),
                _crearEstadistica('IMC', '22.5'),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _crearEstadistica(String titulo, String valor) {
    return Column(
      children: [
        Text(valor, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.purple)),
        Text(titulo, style: const TextStyle(fontSize: 16, color: Colors.grey)),
      ],
    );
  }
}