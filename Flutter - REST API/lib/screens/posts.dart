import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'login.dart';
import 'comments.dart';

class PostsScreen extends StatefulWidget {
  const PostsScreen({super.key});

  @override
  State<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> {
  List _posts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _verificarSessao();
  }

  Future<void> _verificarSessao() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');

    if (userId == null) {
      if (!mounted) return;
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => const LoginScreen()));
    } else {
      _carregarPosts(userId);
    }
  }

  Future<void> _carregarPosts(int userId) async {
    try {
      final url = Uri.parse(
          'https://jsonplaceholder.typicode.com/posts?userId=$userId');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        setState(() {
          _posts = json.decode(response.body);
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
        title: const Text('Fórum de Posts da API'),
        backgroundColor: const Color(0xFF0086FF),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _posts.length,
              itemBuilder: (context, index) {
                final post = _posts[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    title: Text(post['title'],
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(post['body'],
                        maxLines: 2, overflow: TextOverflow.ellipsis),
                    trailing: const Icon(Icons.comment),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  CommentsScreen(postId: post['id'])));
                    },
                  ),
                );
              },
            ),
    );
  }
}
