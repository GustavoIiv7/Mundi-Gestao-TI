import 'package:flutter/material.dart';

import '../data/api_client.dart';
import '../data/auth_service.dart';
import '../tema.dart';
import '../widgets/componentes.dart';
import 'area_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _login = TextEditingController();
  final _senha = TextEditingController();
  String? _erro;
  bool _carregando = false;

  @override
  void dispose() {
    _login.dispose();
    _senha.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });
    String? nome;
    try {
      nome = await authService.entrar(_login.text, _senha.text);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _carregando = false;
        _erro = e.mensagem;
      });
      return;
    }
    if (!mounted) return;
    if (nome == null) {
      setState(() {
        _carregando = false;
        _erro = 'Usuário ou senha inválidos.';
      });
      return;
    }
    final usuario = nome;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => AreaScreen(usuario: usuario)),
    );
  }

  Widget _rotulo(String texto) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          texto,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Cores.textoSuave,
            letterSpacing: 0.6,
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FundoGradiente(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Center(child: TituloMundi(tamanho: 32)),
                    const SizedBox(height: 8),
                    const Text(
                      'PORTAL INTERNO DE FUNCIONÁRIO',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Cores.cinza,
                        letterSpacing: 0.7,
                      ),
                    ),
                    const SizedBox(height: 28),
                    const Center(child: LogoCircular(tamanho: 140)),
                    const SizedBox(height: 16),
                    const Text(
                      'ACESSO INTERNO',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: Cores.textoSuave,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 28),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Cores.borda, width: 2),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x1A000000),
                            blurRadius: 25,
                            spreadRadius: -5,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _rotulo('LOGIN'),
                          TextField(
                            controller: _login,
                            textInputAction: TextInputAction.next,
                            decoration: decoracaoCampo('Digite seu usuário'),
                          ),
                          const SizedBox(height: 20),
                          _rotulo('SENHA'),
                          TextField(
                            controller: _senha,
                            obscureText: true,
                            onSubmitted: (_) => _carregando ? null : _entrar(),
                            decoration: decoracaoCampo('Digite sua senha'),
                          ),
                          const SizedBox(height: 20),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              decoration: const BoxDecoration(
                                color: Cores.azulClaro,
                                border: Border(
                                  left: BorderSide(color: Cores.azul, width: 4),
                                ),
                              ),
                              child: const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Esqueci Minha Senha',
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: Cores.azulEscuro)),
                                  SizedBox(height: 2),
                                  Text('Chave de Acesso',
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: Cores.azulEscuro)),
                                ],
                              ),
                            ),
                          ),
                          if (_erro != null) ...[
                            const SizedBox(height: 14),
                            Text(
                              _erro!,
                              style: const TextStyle(
                                color: Cores.vermelho,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                          const SizedBox(height: 22),
                          BotaoGradiente(
                            texto: _carregando ? 'ENTRANDO...' : 'ENTRAR',
                            icone: Icons.login,
                            onPressed: _carregando ? null : _entrar,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFFFEF2F2), Color(0xFFFEE2E2)],
                        ),
                        border: Border.all(
                            color: const Color(0xFFFECACA), width: 2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.warning_amber_rounded,
                              color: Cores.vermelho, size: 30),
                          SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              'ACESSO RESTRITO SOMENTE FUNCIONÁRIOS AUTORIZADOS',
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF991B1B),
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
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
