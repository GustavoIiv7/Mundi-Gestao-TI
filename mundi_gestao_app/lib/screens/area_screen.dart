import 'package:flutter/material.dart';

import '../data/auth_service.dart';
import '../models/area.dart';
import '../models/dados_gestao.dart';
import '../tema.dart';
import '../widgets/componentes.dart';
import 'admin_screen.dart';
import 'login_screen.dart';
import 'portal_screen.dart';

class AreaScreen extends StatelessWidget {
  const AreaScreen({super.key, required this.usuario});

  final String usuario;

  void _sair(BuildContext context) {
    authService.sair();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FundoGradiente(
        child: Column(
          children: [
            BarraNav(
              direita: [
                BotaoNav(
                  icone: Icons.notifications_none,
                  tooltip: 'Notificações',
                  alerta: true,
                  onPressed: () {},
                ),
                BotaoNav(
                  icone: Icons.mail_outline,
                  tooltip: 'Mensagens',
                  onPressed: () {},
                ),
                BotaoNav(
                  icone: Icons.logout,
                  tooltip: 'Sair',
                  onPressed: () => _sair(context),
                ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    CabecalhoBranco(
                      child: Row(
                        children: [
                          const Expanded(child: TituloMundi()),
                          const SizedBox(width: 12),
                          SizedBox(
                            width: 64,
                            height: 64,
                            child: Image.asset(
                              'assets/LOGO.png',
                              fit: BoxFit.contain,
                              errorBuilder: (context, erro, pilha) =>
                                  const Icon(Icons.public,
                                      color: Cores.azul, size: 40),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ColunaCentral(
                      largura: 1100,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Olá, $usuario',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Cores.textoSuave,
                              ),
                            ),
                            const SizedBox(height: 16),
                            for (final area in AreaGestao.values) ...[
                              _CartaoArea(
                                area: area,
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => PortalScreen(
                                          area: area, usuario: usuario),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 20),
                            ],
                            if (authService.sessao?.admin ?? false) ...[
                              CartaoLateral(
                                cor: Cores.azulEscuro,
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (_) => const AdminScreen()),
                                  );
                                },
                                child: const Row(
                                  children: [
                                    Icon(Icons.admin_panel_settings_outlined,
                                        color: Cores.azul),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        'ADMINISTRAÇÃO · Cadastro de usuários',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: Cores.titulo,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    ),
                                    Icon(Icons.chevron_right,
                                        color: Cores.cinza),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(16, 16, 16, 24),
                      child: Text(
                        '© 2026 Mundi Gestão TI - Todos os direitos reservados',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13.5, color: Cores.cinza),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartaoArea extends StatelessWidget {
  const _CartaoArea({required this.area, required this.onTap});

  final AreaGestao area;
  final VoidCallback onTap;

  Widget _imagem() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          area.imagem,
          fit: BoxFit.cover,
          errorBuilder: (context, erro, pilha) =>
              Container(color: const Color(0xFF93C5FD)),
          loadingBuilder: (context, filho, progresso) => progresso == null
              ? filho
              : Container(color: const Color(0xFFBFDBFE)),
        ),
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Color(0xCC2563EB), Color(0x662563EB)],
            ),
          ),
        ),
        Center(
          child: Icon(area.icone, size: 56, color: Colors.white.withAlpha(230)),
        ),
      ],
    );
  }

  Widget _conteudo() {
    final itens = dadosDaArea(area).itensCartao;
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            area.tituloCartao,
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w300,
              color: Cores.textoSuave,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 14),
          for (final item in itens)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(_iconeItem(item.tipo),
                      size: 17, color: _corItem(item.tipo)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item.texto,
                      style: const TextStyle(
                          fontSize: 14, color: Cores.cinza),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 4),
          Row(
            children: [
              Column(
                children: [
                  for (var i = 0; i < 3; i++)
                    Container(
                      width: 48,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 4),
                      decoration: BoxDecoration(
                        color: Cores.borda,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                ],
              ),
              const Spacer(),
              const Icon(Icons.chevron_right, color: Cores.cinzaClaro),
            ],
          ),
        ],
      ),
    );
  }

  IconData _iconeItem(TipoItem t) => switch (t) {
        TipoItem.ativo => Icons.check_circle_outline,
        TipoItem.alerta => Icons.error_outline,
        TipoItem.pendente => Icons.schedule,
      };

  Color _corItem(TipoItem t) => switch (t) {
        TipoItem.ativo => const Color(0xFF22C55E),
        TipoItem.alerta => const Color(0xFFEAB308),
        TipoItem.pendente => const Color(0xFF3B82F6),
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Cores.borda),
        boxShadow: sombraCartao,
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.white,
        child: InkWell(
          onTap: onTap,
          child: LayoutBuilder(
            builder: (context, c) {
              if (c.maxWidth >= 700) {
                return SizedBox(
                  height: 200,
                  child: Row(
                    children: [
                      SizedBox(width: 256, child: _imagem()),
                      Expanded(child: _conteudo()),
                    ],
                  ),
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 150, child: _imagem()),
                  _conteudo(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
