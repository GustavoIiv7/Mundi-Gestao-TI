import 'package:flutter/material.dart';

import '../data/auth_service.dart';
import '../models/area.dart';
import '../tema.dart';
import '../widgets/componentes.dart';
import 'chat_screen.dart';
import 'login_screen.dart';
import 'tabs/dashboard_tab.dart';
import 'tabs/monitoramento_tab.dart';
import 'tabs/relatorio_tab.dart';
import 'tabs/requisicoes_tab.dart';

class PortalScreen extends StatefulWidget {
  const PortalScreen({super.key, required this.area, required this.usuario});

  final AreaGestao area;
  final String usuario;

  @override
  State<PortalScreen> createState() => _PortalScreenState();
}

class _PortalScreenState extends State<PortalScreen> {
  static const _abas = ['REQUISIÇÕES', 'DASHBOARD', 'MONITORAMENTO', 'RELATÓRIO'];
  int _aba = 0;

  void _abrirChat() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ChatScreen(area: widget.area)),
    );
  }

  void _sair() {
    authService.sair();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  Widget _linhaUsuario(String rotulo, String valor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            rotulo,
            style: const TextStyle(
              color: Color(0xE6FFFFFF),
              fontWeight: FontWeight.w700,
              fontSize: 12,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              valor,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _botaoAba(int i) {
    final ativo = _aba == i;
    return GestureDetector(
      onTap: () => setState(() => _aba = i),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: ativo ? gradienteAzul : null,
          color: ativo ? null : Colors.white,
          border: Border.all(
            color: ativo ? Cores.azul : Cores.borda,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
          boxShadow: ativo
              ? const [
                  BoxShadow(
                    color: Color(0x4D2563EB),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            _abas[i],
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
              color: ativo ? Colors.white : Cores.cinza,
            ),
          ),
        ),
      ),
    );
  }

  Widget _barraAbas() {
    return LayoutBuilder(
      builder: (context, c) {
        return GradeColunas(
          colunas: c.maxWidth >= 620 ? 4 : 2,
          espaco: 8,
          filhos: [for (var i = 0; i < _abas.length; i++) _botaoAba(i)],
        );
      },
    );
  }

  Widget _conteudoAba() {
    return switch (_aba) {
      0 => RequisicoesTab(area: widget.area, usuario: widget.usuario),
      1 => DashboardTab(area: widget.area),
      2 => MonitoramentoTab(area: widget.area),
      _ => RelatorioTab(area: widget.area),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FundoGradiente(
        child: Column(
          children: [
            BarraNav(
              esquerda: [
                BotaoNav(
                  icone: Icons.home_outlined,
                  tooltip: 'Trocar de área',
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
              direita: [
                BotaoNav(
                  icone: Icons.notifications_none,
                  tooltip: 'Notificações',
                  alerta: true,
                  onPressed: () {},
                ),
                BotaoNav(
                  icone: Icons.chat_bubble_outline,
                  tooltip: 'Chamados internos',
                  onPressed: _abrirChat,
                ),
                BotaoNav(
                  icone: Icons.person_outline,
                  tooltip: 'Perfil',
                  onPressed: () {},
                ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    CabecalhoBranco(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const TituloMundi(),
                          const SizedBox(height: 4),
                          Text(
                            widget.area.rotulo.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Cores.cinza,
                              letterSpacing: 0.7,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 14),
                            decoration: BoxDecoration(
                              gradient: gradienteAzul,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x4D2563EB),
                                  blurRadius: 6,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                _linhaUsuario('USUÁRIO:', widget.usuario),
                                _linhaUsuario('ÁREA:', widget.area.rotulo),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    ColunaCentral(
                      largura: 1100,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Cores.borda),
                            boxShadow: sombraCartao,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _barraAbas(),
                              const SizedBox(height: 20),
                              _conteudoAba(),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: _sair,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 28, vertical: 14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                    color: const Color(0xFFEF4444), width: 2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.logout,
                                      color: Cores.vermelho, size: 18),
                                  SizedBox(width: 8),
                                  Text(
                                    'SAIR DO SISTEMA',
                                    style: TextStyle(
                                      color: Cores.vermelho,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            '© 2026 Mundi Gestão TI - Todos os direitos reservados',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 13.5, color: Cores.cinza),
                          ),
                        ],
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
