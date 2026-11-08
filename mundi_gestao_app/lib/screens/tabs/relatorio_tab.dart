import 'package:flutter/material.dart';

import '../../data/area_repository.dart';
import '../../models/area.dart';
import '../../models/dados_gestao.dart';
import '../../tema.dart';
import '../../widgets/carrega_dados.dart';

class RelatorioTab extends StatelessWidget {
  const RelatorioTab({super.key, required this.area});

  final AreaGestao area;

  @override
  Widget build(BuildContext context) {
    return CarregaDados<List<ItemRelatorio>>(
      carregar: () => areaRepository.relatorio(area),
      construir: _corpo,
    );
  }

  Widget _corpo(BuildContext context, List<ItemRelatorio> itens) {
    return Column(
      children: [
        if (itens.isEmpty)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Text('Nenhum item no momento.',
                style: TextStyle(color: Cores.textoSuave, fontSize: 14)),
          ),
        for (final item in itens)
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Cores.fundoCartao,
              border: Border.all(color: Cores.borda),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Cores.azulClaro,
                    border: Border.all(
                        color: const Color(0xFFBFDBFE), width: 1.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.description_outlined,
                      size: 19, color: Cores.azul),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.titulo,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Cores.titulo,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(item.tecnico, style: _meta),
                          const Text('•', style: _sep),
                          Text(item.data, style: _meta),
                          const Text('•', style: _sep),
                          Text(item.tempo, style: _meta),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 9, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDCFCE7),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: const Text(
                              'CONCLUÍDO',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF15803D),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Color(0xFFCBD5E1)),
              ],
            ),
          ),
      ],
    );
  }
}

const TextStyle _meta = TextStyle(fontSize: 12, color: Cores.cinza);
const TextStyle _sep = TextStyle(fontSize: 12, color: Color(0xFFCBD5E1));
