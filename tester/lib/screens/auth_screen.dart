import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';

class AuthScreen extends StatefulWidget {
  final String role;
  const AuthScreen({super.key, required this.role});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  static const _verde     = Color(0xFF2D6A4F);
  static const _verdeSoft = Color(0xFFF0FFF0);

  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();

  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _nameCtrl     = TextEditingController();
  final _ageCtrl      = TextEditingController();
  final _weightCtrl   = TextEditingController();
  final _goalCtrl     = TextEditingController();
  final _cedulaCtrl   = TextEditingController();
  final _especialidadCtrl = TextEditingController();
  final _parentescoCtrl   = TextEditingController();
  final _codigoCtrl       = TextEditingController();

  bool _isLogin      = true;
  bool _isLoading    = false;
  bool _showPassword = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _nameCtrl.dispose();
    _ageCtrl.dispose();
    _weightCtrl.dispose();
    _goalCtrl.dispose();
    _cedulaCtrl.dispose();
    _especialidadCtrl.dispose();
    _parentescoCtrl.dispose();
    _codigoCtrl.dispose();
    super.dispose();
  }

  // ── Acción principal: login o registro ──
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    String? error;

    if (_isLogin) {
      error = await _authService.login(
        email: _emailCtrl.text,
        password: _passwordCtrl.text,
      );
    } else {
      // Datos extra según el rol
      Map<String, dynamic> extraData = {};
      if (widget.role == 'Paciente') {
        extraData = {
          'age': int.tryParse(_ageCtrl.text) ?? 0,
          'weight': double.tryParse(_weightCtrl.text) ?? 0,
          'goal': _goalCtrl.text.trim(),
        };
      } else if (widget.role == 'Nutricionista') {
        extraData = {
          'cedula': _cedulaCtrl.text.trim(),
          'especialidad': _especialidadCtrl.text.trim(),
        };
      } else if (widget.role == 'Familiar / Encargado') {
        extraData = {
          'parentesco': _parentescoCtrl.text.trim(),
          'codigoGrupo': _codigoCtrl.text.trim(),
        };
      }

      error = await _authService.register(
        email: _emailCtrl.text,
        password: _passwordCtrl.text,
        name: _nameCtrl.text,
        role: widget.role,
        extraData: extraData,
      );
    }

    setState(() => _isLoading = false);
    if (!mounted) return;

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(error)),
          ]),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      );
    } else {
      // Éxito → ir al Home y limpiar historial de navegación
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    }
  }

  void _toggleMode() {
    setState(() => _isLogin = !_isLogin);
    _formKey.currentState?.reset();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _verdeSoft,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // ── Título ──
              Text(
                _isLogin ? "Bienvenido de nuevo" : "Crear cuenta",
                style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: _verde),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: _verde.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "Ingresando como: ${widget.role}",
                  style: const TextStyle(color: _verde, fontSize: 13),
                ),
              ),
              const SizedBox(height: 30),

              // ── Nombre (solo en registro) ──
              if (!_isLogin) ...[
                _field(
                  controller: _nameCtrl,
                  label: "Nombre completo",
                  icon: Icons.person,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Escribe tu nombre'
                      : null,
                ),
                const SizedBox(height: 15),
              ],

              // ── Correo ──
              _field(
                controller: _emailCtrl,
                label: "Correo electrónico",
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Escribe tu correo';
                  if (!v.contains('@')) return 'Correo inválido';
                  return null;
                },
              ),
              const SizedBox(height: 15),

              // ── Contraseña ──
              _field(
                controller: _passwordCtrl,
                label: "Contraseña",
                icon: Icons.lock,
                obscure: !_showPassword,
                suffix: IconButton(
                  icon: Icon(
                    _showPassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: Colors.grey,
                    size: 20,
                  ),
                  onPressed: () =>
                      setState(() => _showPassword = !_showPassword),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Escribe tu contraseña';
                  if (v.length < 6) return 'Mínimo 6 caracteres';
                  return null;
                },
              ),

              // ── Campos extra según rol (solo en registro) ──
              if (!_isLogin) ...[
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 10),

                // Paciente
                if (widget.role == "Paciente") ...[
                  Row(children: [
                    Expanded(
                      child: _field(
                        controller: _ageCtrl,
                        label: "Edad",
                        icon: Icons.cake,
                        keyboardType: TextInputType.number,
                        validator: (v) =>
                            (v == null || v.isEmpty) ? 'Requerido' : null,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _field(
                        controller: _weightCtrl,
                        label: "Peso (kg)",
                        icon: Icons.monitor_weight,
                        keyboardType: TextInputType.number,
                        validator: (v) =>
                            (v == null || v.isEmpty) ? 'Requerido' : null,
                      ),
                    ),
                  ]),
                  const SizedBox(height: 15),
                  _field(
                    controller: _goalCtrl,
                    label: "Objetivo nutricional",
                    icon: Icons.flag,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Escribe tu objetivo'
                        : null,
                  ),
                ],

                // Nutricionista
                if (widget.role == "Nutricionista") ...[
                  _field(
                    controller: _cedulaCtrl,
                    label: "Número de Cédula Profesional",
                    icon: Icons.badge,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Requerido'
                        : null,
                  ),
                  const SizedBox(height: 15),
                  _field(
                    controller: _especialidadCtrl,
                    label: "Especialidad",
                    icon: Icons.medical_services,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Requerido'
                        : null,
                  ),
                ],

                // Familiar
                if (widget.role == "Familiar / Encargado") ...[
                  _field(
                    controller: _parentescoCtrl,
                    label: "Parentesco o Cargo",
                    icon: Icons.family_restroom,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Requerido'
                        : null,
                  ),
                  const SizedBox(height: 15),
                  _field(
                    controller: _codigoCtrl,
                    label: "Código de grupo / Familia",
                    icon: Icons.group,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Requerido'
                        : null,
                  ),
                ],
              ],

              const SizedBox(height: 30),

              // ── Botón principal ──
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _verde,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading
                      ? const SizedBox(
                          width: 22, height: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : Text(
                          _isLogin ? "Entrar" : "Registrarme",
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                ),
              ),

              // ── Toggle login/registro ──
              TextButton(
                onPressed: _toggleMode,
                child: Text(
                  _isLogin
                      ? "¿No tienes cuenta? Regístrate"
                      : "¿Ya tienes cuenta? Inicia sesión",
                  style: const TextStyle(color: _verde),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Helper de campo de texto ──
  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscure = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    Widget? suffix,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: _verde),
        suffixIcon: suffix,
      ),
    );
  }
}