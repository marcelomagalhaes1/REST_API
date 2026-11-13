import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'home.dart';
import 'cadastro_usuario.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _fazerLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();
    final prefs = await SharedPreferences.getInstance();

    // 1. Procura na lista de utilizadores cadastrados localmente
    final String? usuariosString = prefs.getString('usuarios_cadastrados');
    if (usuariosString != null) {
      List usuariosList = json.decode(usuariosString);

      final usuarioEncontrado = usuariosList.firstWhere(
        (u) => u['username'] == username && u['password'] == password,
        orElse: () => null,
      );

      if (usuarioEncontrado != null) {
        await prefs.setInt('userId', usuarioEncontrado['userId']);
        await prefs.setString('name', usuarioEncontrado['name']);

        if (!mounted) return;
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const HomeScreen()));
        return;
      }
    }

    // 2. Fallback: Consulta a API JSONPlaceholder caso não esteja nos cadastros locais
    try {
      final url = Uri.parse(
          'https://jsonplaceholder.typicode.com/users?username=$username');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List usuariosApi = json.decode(response.body);

        if (usuariosApi.isNotEmpty) {
          final usuario = usuariosApi[0];
          await prefs.setInt('userId', usuario['id']);
          await prefs.setString('name', usuario['name']);

          if (!mounted) return;
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const HomeScreen()));
          return;
        }
      }
    } catch (_) {}

    // Se falhar em ambos
    _mostrarErro('Utilizador ou senha incorretos.');
    if (mounted) setState(() => _isLoading = false);
  }

  void _mostrarErro(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mensagem), backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0086FF),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('magalu ',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic)),
                  Icon(Icons.shopping_bag_outlined,
                      color: Colors.yellow, size: 40),
                ],
              ),
              const SizedBox(height: 40),
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _usernameController,
                          decoration: const InputDecoration(
                              labelText: 'Username',
                              prefixIcon: Icon(Icons.person),
                              border: OutlineInputBorder()),
                          validator: (val) =>
                              val!.isEmpty ? 'Informe o username' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                              labelText: 'Senha',
                              prefixIcon: Icon(Icons.lock),
                              border: OutlineInputBorder()),
                          validator: (val) =>
                              val!.isEmpty ? 'Informe a senha' : null,
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _fazerLogin,
                            style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0086FF),
                                foregroundColor: Colors.white),
                            child: _isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white)
                                : const Text('ENTRAR',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const CadastroUsuarioScreen())),
                          child:
                              const Text('Não possui conta? Cadastre-se aqui'),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
