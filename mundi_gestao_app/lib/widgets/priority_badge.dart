import 'package:flutter/material.dart';

import '../models/chamado.dart';

Color corPrioridade(Prioridade p) => switch (p) {
      Prioridade.alta => const Color(0xFFDC2626),
      Prioridade.media => const Color(0xFFD97706),
      Prioridade.baixa => const Color(0xFF16A34A),
    };

Color corStatus(StatusChamado s) => switch (s) {
      StatusChamado.aberto => const Color(0xFF2563EB),
      StatusChamado.emAndamento => const Color(0xFF7C3AED),
      StatusChamado.resolvido => const Color(0xFF16A34A),
    };

class _Etiqueta extends StatelessWidget {
  const _Etiqueta(this.texto, this.cor);

  final String texto;
  final Color cor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: cor.withAlpha(30),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        texto,
        style: TextStyle(color: cor, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class PriorityBadge extends StatelessWidget {
  const PriorityBadge(this.prioridade, {super.key});

  final Prioridade prioridade;

  @override
  Widget build(BuildContext context) =>
      _Etiqueta(prioridade.rotulo, corPrioridade(prioridade));
}

class StatusBadge extends StatelessWidget {
  const StatusBadge(this.status, {super.key});

  final StatusChamado status;

  @override
  Widget build(BuildContext context) =>
      _Etiqueta(status.rotulo, corStatus(status));
}
