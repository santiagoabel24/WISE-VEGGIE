import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class NutriBotChatScreen extends StatefulWidget {
  @override
  _NutriBotChatScreenState createState() => _NutriBotChatScreenState();
}

class _NutriBotChatScreenState extends State<NutriBotChatScreen> {

  final String apiKey = "";
  
  final String systemPrompt = "Eres NutriBot, un asistente virtual amigable, empatico y confiable especializado en salud general, alimentacion saludable y recetas nutritivas. Tu conocimiento se basa en las guias de la OMS. SIEMPRE aclara que no eres medico.";

  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  List<Map<String, String>> messages = [];
  bool isTyping = false;

  @override
  void initState() {
    super.initState();
    // Mensaje de bienvenida inicial
    messages.add({
      "role": "bot",
      "content": "¡Hola! 👋 Soy NutriBot, tu asistente de salud y alimentación.\n\nPuedo ayudarte con consejos, recetas, calcular tu IMC o ingesta de agua.\n\nRecuerda que soy un asistente educativo y no reemplazo a tu médico. ¿En qué te ayudo hoy?"
    });
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      messages.add({"role": "user", "content": text});
      isTyping = true;
    });

    _controller.clear();
    _scrollToBottom();

    // Preparamos el historial para Groq
    List<Map<String, String>> apiMessages = [
      {"role": "system", "content": systemPrompt}
    ];
    
    // MEJORA: Ventana de memoria deslizante (Solo toma los últimos 10 mensajes)
    var mensajesRecientes = messages.length > 10 
        ? messages.sublist(messages.length - 10) 
        : messages;

    // Convertimos nuestros mensajes al formato que pide la API
    for (var msg in mensajesRecientes) {
      if (msg["role"] == "user") {
        apiMessages.add({"role": "user", "content": msg["content"]!});
      } else if (msg["role"] == "bot") {
        apiMessages.add({"role": "assistant", "content": msg["content"]!});
      }
    }

    try {
      final response = await http.post(
        Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'llama-3.3-70b-versatile',
          'messages': apiMessages,
          'temperature': 0.7,
          'max_tokens': 1024,
        }),
      );

      if (response.statusCode == 200) {
        // Decodificando con soporte para acentos y emojis (UTF-8)
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final botReply = data['choices'][0]['message']['content'];
        
        setState(() {
          messages.add({"role": "bot", "content": botReply});
          isTyping = false;
        });
      } else {
        setState(() {
          messages.add({"role": "bot", "content": "Hubo un error de conexión. Intenta de nuevo."});
          isTyping = false;
        });
      }
    } catch (e) {
      setState(() {
        messages.add({"role": "bot", "content": "No pude conectarme. Revisa tu internet."});
        isTyping = false;
      });
    }
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Colores basados en tu diseño web
    const Color colorFondo = Color(0xFFFAF7F2); // Crema
    const Color colorVerde = Color(0xFF1A6B4A);
    const Color colorVerdeClaro = Color(0xFFE8F5EE);
    const Color colorCafe = Color(0xFF3D2B1F);

    return Scaffold(
      backgroundColor: colorFondo,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Row(
          children: [
            Text("🥗", style: TextStyle(fontSize: 24)),
            SizedBox(width: 8),
            Text(
              "NutriBot",
              style: TextStyle(
                color: colorVerde,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        iconTheme: IconThemeData(color: colorVerde),
      ),
      body: Column(
        children: [
          // Área de los mensajes
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final isUser = messages[index]["role"] == "user";
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.only(bottom: 12),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isUser ? colorVerde : colorVerdeClaro,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                        bottomLeft: isUser ? Radius.circular(16) : Radius.circular(4),
                        bottomRight: isUser ? Radius.circular(4) : Radius.circular(16),
                      ),
                    ),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    child: Text(
                      messages[index]["content"]!,
                      style: TextStyle(
                        color: isUser ? Colors.white : colorCafe,
                        fontSize: 15,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Indicador de "Escribiendo..."
          if (isTyping)
            Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text("NutriBot está escribiendo...", style: TextStyle(color: Colors.grey, fontSize: 12)),
              ),
            ),

          // Caja de texto inferior
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade300)),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: "Escribe tu pregunta...",
                        hintStyle: TextStyle(color: Colors.grey.shade400),
                        filled: true,
                        fillColor: colorFondo,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (text) => sendMessage(text),
                    ),
                  ),
                  SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: colorVerde,
                    radius: 24,
                    child: IconButton(
                      icon: Icon(Icons.send, color: Colors.white),
                      onPressed: () => sendMessage(_controller.text),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
