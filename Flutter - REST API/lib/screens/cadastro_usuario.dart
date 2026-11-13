import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CadastroUsuarioScreen extends StatefulWidget {
  const CadastroUsuarioScreen({super.key});

  @override
  State<CadastroUsuarioScreen> createState() => _CadastroUsuarioScreenState();
}

class _CadastroUsuarioScreenState extends State<CadastroUsuarioScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _salvarCadastro() async {
    if (!_formKey.currentState!.validate()) return;

    final prefs = await SharedPreferences.getInstance();

    // Recupera a lista de utilizadores já cadastrados (se existir)
    final String? usuariosString = prefs.getString('usuarios_cadastrados');
    List usuariosList =
        usuariosString != null ? json.decode(usuariosString) : [];

    // Verifica se o username já existe
    final novoUsername = _usernameController.text.trim();
    final existe = usuariosList.any((u) => u['username'] == novoUsername);

    if (existe) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Este username já está em uso. Escolha outro.'),
            backgroundColor: Colors.red),
      );
      return;
    }

    // Cria o novo objeto de utilizador
    final novoUsuario = {
      'userId': Random().nextInt(90000) +
          1000, // ID único seguro para isolar os anúncios
      'name': _nomeController.text.trim(),
      'username': novoUsername,
      'password': _passwordController.text.trim(),
    };

    // Adiciona à lista e guarda novamente no SharedPreferences
    usuariosList.add(novoUsuario);
    await prefs.setString('usuarios_cadastrados', json.encode(usuariosList));

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Cadastro realizado com sucesso! Faça o login.'),
          backgroundColor: Colors.green),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0086FF),
      appBar: AppBar(
        title: const Text('Criar Conta'),
        backgroundColor: const Color(0xFF0086FF),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const Icon(Icons.person_add,
                        size: 60, color: Color(0xFF0086FF)),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nomeController,
                      decoration: const InputDecoration(
                          labelText: 'Nome Completo',
                          border: OutlineInputBorder()),
                      validator: (val) =>
                          val!.isEmpty ? 'Informe seu nome' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                          labelText: 'Username', border: OutlineInputBorder()),
                      validator: (val) =>
                          val!.isEmpty ? 'Crie um username' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                          labelText: 'Senha', border: OutlineInputBorder()),
                      validator: (val) =>
                          val!.isEmpty ? 'Crie uma senha' : null,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _salvarCadastro,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0086FF),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('CADASTRAR',
                            style: TextStyle(fontWeight: FontWeight.bold)),
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
