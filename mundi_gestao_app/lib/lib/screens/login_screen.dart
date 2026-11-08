import 'package:flutter/material.dart';
import '../data/auth_service.dart';
import 'lista_chamados_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _loginCtrl = TextEditingController();
  final _senhaCtrl = TextEditingController();
  bool _carregando = false;
  String? _erro;

  @override
  void dispose() {
    _loginCtrl.dispose();
    _senhaCtrl.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    if (_carregando) return;
    setState(() {
      _carregando = true;
      _erro = null;
    });

    final nome =
        await authService.entrar(_loginCtrl.text.trim(), _senhaCtrl.text);
    if (!mounted) return;

    if (nome == null) {
      setState(() {
        _carregando = false;
        // Não revela se o erro foi no login ou na senha.
        _erro = 'Credenciais inválidas. Verifique login e senha.';
      });
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => ListaChamadosScreen(usuario: nome)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'MUNDI GESTÃO TI',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'PORTAL INTERNO DE FUNCIONÁRIOS',
                    style: TextStyle(
                      fontSize: 12,
                      letterSpacing: 1.2,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 24),
                  CircleAvatar(
                    radius: 44,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.public,
                      size: 48,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'ACESSO INTERNO',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 24),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextField(
                            controller: _loginCtrl,
                            enabled: !_carregando,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              labelText: 'LOGIN',
                              hintText: 'Digite seu usuário',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _senhaCtrl,
                            enabled: !_carregando,
                            obscureText: true,
                            onSubmitted: (_) => _entrar(),
                            decoration: const InputDecoration(
                              labelText: 'SENHA',
                              hintText: 'Digite sua senha',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          if (_erro != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Text(
                                _erro!,
                                style: const TextStyle(
                                  color: Color(0xFFDC2626),
                                ),
                              ),
                            ),
                          const SizedBox(height: 20),
                          FilledButton(
                            onPressed: _carregando ? null : _entrar,
                            child: _carregando
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('ENTRAR'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Demonstração: Rafael.Souza / senha123',
                    style: TextStyle(fontSize: 12, color: Colors.black45),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
