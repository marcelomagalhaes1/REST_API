import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'login.dart';

class CommentsScreen extends StatefulWidget {
  final int postId;

  const CommentsScreen({super.key, required this.postId});

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  List _comments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _verificarSessao();
  }

  Future<void> _verificarSessao() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getInt('userId') == null) {
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false);
    } else {
      _carregarComentarios();
    }
  }

  Future<void> _carregarComentarios() async {
    try {
      final url = Uri.parse(
          'https://jsonplaceholder.typicode.com/comments?postId=${widget.postId}');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        setState(() {
          _comments = json.decode(response.body);
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comentários'),
        backgroundColor: const Color(0xFF0086FF),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              itemCount: _comments.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final comment = _comments[index];
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(comment['name'],
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(comment['email'],
                          style: const TextStyle(
                              color: Colors.blue, fontSize: 12)),
                      const SizedBox(height: 8),
                      Text(comment['body']),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
