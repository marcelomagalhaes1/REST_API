import 'package:flutter/material.dart';
import 'screens/login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Magalu Anúncios',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0086FF),
          primary: const Color(0xFF0086FF),
          secondary: const Color(0xFFFFB800),
        ),
        scaffoldBackgroundColor: const Color(0xFFF2F4F7),
        useMaterial3: true,
      ),
      // A aplicação inicia sempre na tela de login conforme solicitado
      home: const LoginScreen(),
    );
  }
}
