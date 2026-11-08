import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() => runApp(const MundiApp());

class MundiApp extends StatelessWidget {
  const MundiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mundi Gestão TI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF1D4ED8),
        scaffoldBackgroundColor: const Color(0xFFEFF3FA),
      ),
      home: const LoginScreen(),
    );
  }
}
