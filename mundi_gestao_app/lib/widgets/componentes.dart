import 'package:flutter/material.dart';

import '../models/chamado.dart';
import '../tema.dart';

/// Fundo em degradê cinza-azulado do portal.
class FundoGradiente extends StatelessWidget {
  const FundoGradiente({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: gradienteFundo),
      child: child,
    );
  }
}

/// Centraliza o conteúdo com largura máxima (bom para o Chrome).
class ColunaCentral extends StatelessWidget {
  const ColunaCentral({super.key, required this.child, this.largura = 1000});

  final Widget child;
  final double largura;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: largura),
        child: child,
      ),
    );
  }
}

/// Barra superior branca (top-nav do portal).
class BarraNav extends StatelessWidget {
  const BarraNav({super.key, this.esquerda = const [], this.direita = const []});

  final List<Widget> esquerda;
  final List<Widget> direita;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Cores.borda)),
        boxShadow: sombraSuave,
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            children: [
              ...esquerda,
              const Spacer(),
              ...direita,
            ],
          ),
        ),
      ),
    );
  }
}

class BotaoNav extends StatelessWidget {
  const BotaoNav({
    super.key,
    required this.icone,
    required this.tooltip,
    required this.onPressed,
    this.alerta = false,
  });

  final IconData icone;
  final String tooltip;
  final VoidCallback onPressed;
  final bool alerta;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        IconButton(
          tooltip: tooltip,
          icon: Icon(icone, size: 22, color: Cores.cinza),
          onPressed: onPressed,
        ),
        if (alerta)
          Positioned(
            top: 10,
            right: 10,
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Color(0xFFEF4444),
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }
}

/// Faixa branca com o título (header do portal).
class CabecalhoBranco extends StatelessWidget {
  const CabecalhoBranco({super.key, required this.child, this.largura = 1100});

  final Widget child;
  final double largura;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Cores.borda)),
        boxShadow: sombraSuave,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: largura),
          child: child,
        ),
      ),
    );
  }
}

class TituloMundi extends StatelessWidget {
  const TituloMundi({super.key, this.tamanho = 26});

  final double tamanho;

  @override
  Widget build(BuildContext context) {
    return Text(
      'MUNDI GESTÃO TI',
      style: TextStyle(
        fontSize: tamanho,
        fontWeight: FontWeight.w700,
        color: Cores.titulo,
        letterSpacing: 0.7,
      ),
    );
  }
}

/// Logo dentro de um círculo branco com sombra.
class LogoCircular extends StatelessWidget {
  const LogoCircular({super.key, this.tamanho = 130});

  final double tamanho;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: tamanho,
      height: tamanho,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 25,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: ClipOval(
        child: Padding(
          padding: EdgeInsets.all(tamanho * 0.04),
          child: Image.asset(
            'assets/LOGO.png',
            fit: BoxFit.contain,
            errorBuilder: (context, erro, pilha) =>
                Icon(Icons.public, color: Cores.azul, size: tamanho * 0.5),
          ),
        ),
      ),
    );
  }
}

/// Botão com degradê azul (ENTRAR, NOVA REQUISIÇÃO, enviar...).
class BotaoGradiente extends StatelessWidget {
  const BotaoGradiente({
    super.key,
    required this.texto,
    required this.onPressed,
    this.icone,
    this.compacto = false,
  });

  final String texto;
  final VoidCallback? onPressed;
  final IconData? icone;
  final bool compacto;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: onPressed == null ? 0.6 : 1,
      child: Container(
        decoration: BoxDecoration(
          gradient: gradienteAzul,
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(
              color: Color(0x4D2563EB),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: onPressed,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: compacto ? 18 : 28,
                vertical: compacto ? 11 : 16,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icone != null && compacto) ...[
                    Icon(icone, color: Colors.white, size: 16),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    texto,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: compacto ? 12.5 : 15,
                      letterSpacing: 0.6,
                    ),
                  ),
                  if (icone != null && !compacto) ...[
                    const SizedBox(width: 12),
                    Icon(icone, color: Colors.white, size: 20),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Cartão cinza claro com barra colorida à esquerda (tickets e monitoramento).
class CartaoLateral extends StatelessWidget {
  const CartaoLateral({
    super.key,
    required this.cor,
    required this.child,
    this.onTap,
  });

  final Color cor;
  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Cores.fundoCartao,
          border: Border.all(color: Cores.borda, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
            decoration: BoxDecoration(
              border: Border(left: BorderSide(color: cor, width: 4)),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class BadgePrioridade extends StatelessWidget {
  const BadgePrioridade(this.prioridade, {super.key});

  final Prioridade prioridade;

  @override
  Widget build(BuildContext context) {
    final e = estiloDe(prioridade);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: e.fundo,
        border: Border.all(color: e.borda),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        prioridade.rotulo,
        style: TextStyle(
          color: e.texto,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

/// Bolinha de status com halo (como no portal web).
class PontoStatus extends StatelessWidget {
  const PontoStatus(this.cor, {super.key});

  final Color cor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: cor,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: cor.withAlpha(50), spreadRadius: 2)],
      ),
    );
  }
}

/// Botão de prioridade (filtro e formulário): borda colorida de 2px.
class BotaoPrioridade extends StatelessWidget {
  const BotaoPrioridade({
    super.key,
    required this.prioridade,
    required this.destaque,
    required this.onTap,
  });

  final Prioridade prioridade;
  final bool destaque;
  final VoidCallback onTap;

  IconData get _icone => switch (prioridade) {
        Prioridade.urgente => Icons.error_outline,
        Prioridade.alta => Icons.keyboard_arrow_up,
        Prioridade.normal => Icons.remove,
        Prioridade.baixa => Icons.keyboard_arrow_down,
      };

  @override
  Widget build(BuildContext context) {
    final e = estiloDe(prioridade);
    return Opacity(
      opacity: destaque ? 1 : 0.4,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            color: destaque ? e.fundo : Colors.white,
            border: Border.all(color: e.barra, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(_icone, size: 16, color: e.texto),
              const SizedBox(width: 8),
              Text(
                prioridade.rotulo,
                style: TextStyle(
                  color: e.texto,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Distribui widgets em grade de N colunas (sem rolagem própria).
class GradeColunas extends StatelessWidget {
  const GradeColunas({
    super.key,
    required this.filhos,
    required this.colunas,
    this.espaco = 12,
  });

  final List<Widget> filhos;
  final int colunas;
  final double espaco;

  @override
  Widget build(BuildContext context) {
    final linhas = <Widget>[];
    for (var i = 0; i < filhos.length; i += colunas) {
      final linha = <Widget>[];
      for (var j = i; j < i + colunas; j++) {
        if (j > i) linha.add(SizedBox(width: espaco));
        linha.add(Expanded(
          child: j < filhos.length ? filhos[j] : const SizedBox.shrink(),
        ));
      }
      if (i > 0) linhas.add(SizedBox(height: espaco));
      linhas.add(Row(children: linha));
    }
    return Column(children: linhas);
  }
}
