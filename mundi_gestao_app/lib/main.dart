import 'package:flutter/material.dart';

import 'data/api_client.dart';
import 'data/auth_service.dart';
import 'screens/login_screen.dart';
import 'tema.dart';

final GlobalKey<NavigatorState> navegadorKey = GlobalKey<NavigatorState>();

void main() {
  // Token vencido (401): volta para o login.
  api.aoExpirarSessao = () {
    authService.sair();
    navegadorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  };
  runApp(const MundiApp());
}

class MundiApp extends StatelessWidget {
  const MundiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navegadorKey,
      title: 'Mundi Gestão TI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Cores.azul,
        scaffoldBackgroundColor: Cores.fundoCartao,
      ),
      home: const LoginScreen(),
    );
  }
}
