import 'package:flutter/material.dart';

import '../../data/area_repository.dart';
import '../../models/area.dart';
import '../../models/dados_gestao.dart';
import '../../tema.dart';
import '../../widgets/carrega_dados.dart';
import '../../widgets/componentes.dart';

class MonitoramentoTab extends StatelessWidget {
  const MonitoramentoTab({super.key, required this.area});

  final AreaGestao area;

  @override
  Widget build(BuildContext context) {
    return CarregaDados<List<ItemMonitor>>(
      carregar: () => areaRepository.monitoramento(area),
      construir: _corpo,
    );
  }

  Widget _corpo(BuildContext context, List<ItemMonitor> itens) {
    return Column(
      children: [
        if (itens.isEmpty)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Text('Nenhum item no momento.',
                style: TextStyle(color: Cores.textoSuave, fontSize: 14)),
          ),
        for (final item in itens)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: CartaoLateral(
              cor: estiloDe(item.prioridade).barra,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          item.titulo,
                          style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w600,
                            color: Cores.titulo,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      BadgePrioridade(item.prioridade),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const PontoStatus(Color(0xFFEF4444)),
                      const SizedBox(width: 8),
                      Text(
                        'Aberto em ${item.data}',
                        style: const TextStyle(
                            fontSize: 12.5, color: Cores.cinza),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 7,
                          decoration: BoxDecoration(
                            color: Cores.borda,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: FractionallySizedBox(
                              widthFactor: item.prog / 100,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors:
                                        estiloDe(item.prioridade).progresso,
                                  ),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 44,
                        child: Text(
                          '${item.prog}%',
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: Cores.textoSuave,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
