import 'package:flutter/material.dart';
import '../models/chamado.dart';
import '../widgets/priority_badge.dart';

class DetalheChamadoScreen extends StatelessWidget {
  final Chamado chamado;

  const DetalheChamadoScreen({super.key, required this.chamado});

  Widget _linha(String rotulo, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              rotulo,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
          ),
          Expanded(child: Text(valor)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final corProgresso = corPrioridade(chamado.prioridade);

    return Scaffold(
      appBar: AppBar(title: Text('Chamado #${chamado.id}')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            chamado.titulo,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              PriorityBadge(prioridade: chamado.prioridade),
              const SizedBox(width: 10),
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: corStatus(chamado.status),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(chamado.status.rotulo),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Progresso do atendimento',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: chamado.progresso / 100,
                    minHeight: 10,
                    color: corProgresso,
                    backgroundColor: corProgresso.withAlpha(40),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text('${chamado.progresso}%'),
            ],
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Descrição',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Text(chamado.descricao),
                  const Divider(height: 28),
                  _linha('Solicitante', chamado.solicitante),
                  _linha('Atendente', chamado.atendente ?? 'Não atribuído'),
                  _linha('Abertura', formatarDataHora(chamado.dataAbertura)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Histórico de atendimento',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          const SizedBox(height: 8),
          for (final e in chamado.historico)
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.history, size: 20),
              title: Text(e.descricao),
              subtitle: Text(formatarDataHora(e.data)),
            ),
        ],
      ),
    );
  }
}
