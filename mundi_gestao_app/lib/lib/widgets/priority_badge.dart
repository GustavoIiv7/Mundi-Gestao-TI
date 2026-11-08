import 'package:flutter/material.dart';
import '../models/chamado.dart';

Color corPrioridade(Prioridade p) => switch (p) {
      Prioridade.urgente => const Color(0xFFDC2626),
      Prioridade.alta => const Color(0xFFD97706),
      Prioridade.normal => const Color(0xFF2563EB),
      Prioridade.baixa => const Color(0xFF64748B),
    };

Color corStatus(StatusChamado s) => switch (s) {
      StatusChamado.aberto => const Color(0xFFDC2626),
      StatusChamado.emAtendimento => const Color(0xFF2563EB),
      StatusChamado.resolvido => const Color(0xFF16A34A),
    };

class PriorityBadge extends StatelessWidget {
  final Prioridade prioridade;

  const PriorityBadge({super.key, required this.prioridade});

  @override
  Widget build(BuildContext context) {
    final cor = corPrioridade(prioridade);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: cor.withAlpha(30),
        border: Border.all(color: cor.withAlpha(120)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        prioridade.rotulo,
        style: TextStyle(color: cor, fontSize: 11, fontWeight: FontWeight.w700),
      ),
    );
  }
}
