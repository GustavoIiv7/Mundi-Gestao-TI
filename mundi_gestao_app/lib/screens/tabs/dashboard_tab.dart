import 'package:flutter/material.dart';

import '../../data/area_repository.dart';
import '../../models/area.dart';
import '../../models/chamado.dart';
import '../../models/dados_gestao.dart';
import '../../tema.dart';
import '../../widgets/carrega_dados.dart';

class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key, required this.area});

  final AreaGestao area;

  @override
  Widget build(BuildContext context) {
    return CarregaDados<DashboardDados>(
      carregar: () => areaRepository.dashboard(area),
      construir: _corpo,
    );
  }

  Widget _corpo(BuildContext context, DashboardDados dados) {
    final resumo = dados.resumo;

    final estatisticas = [
      _Estatistica(
        icone: Icons.confirmation_number_outlined,
        corIcone: Cores.azul,
        fundoIcone: const Color(0xFFEFF6FF),
        valor: '${resumo.total}',
        rotulo: 'Requisições no mês',
      ),
      _Estatistica(
        icone: Icons.check_circle_outline,
        corIcone: Cores.verde,
        fundoIcone: const Color(0xFFF0FDF4),
        valor: '${resumo.taxa}%',
        rotulo: 'Taxa de resolução',
      ),
      _Estatistica(
        icone: Icons.schedule,
        corIcone: const Color(0xFFD97706),
        fundoIcone: const Color(0xFFFFFBEB),
        valor: resumo.tempoMedio,
        rotulo: 'Tempo médio de atend.',
      ),
    ];

    final ordenados = [...dados.chart]..sort((a, b) => b.req.compareTo(a.req));
    final maxReq = dados.chart.fold<int>(1, (m, d) => d.req > m ? d.req : m);
    final maxTempo =
        dados.chart.fold<double>(0.1, (m, d) => d.tempo > m ? d.tempo : m);
    final agora = formatarHora(DateTime.now());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(
          builder: (context, c) {
            if (c.maxWidth >= 520) {
              return Row(
                children: [
                  for (var i = 0; i < estatisticas.length; i++) ...[
                    if (i > 0) const SizedBox(width: 12),
                    Expanded(child: estatisticas[i]),
                  ],
                ],
              );
            }
            return Column(
              children: [
                for (var i = 0; i < estatisticas.length; i++) ...[
                  if (i > 0) const SizedBox(height: 10),
                  estatisticas[i],
                ],
              ],
            );
          },
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
          decoration: BoxDecoration(
            color: Cores.fundoCartao,
            border: Border.all(color: Cores.borda),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'SERVIÇOS MAIS REQUISITADOS E TEMPO MÉDIO',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: Cores.textoSuave,
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(height: 2),
              const Text('Últimos 30 dias',
                  style: TextStyle(fontSize: 12, color: Cores.cinzaClaro)),
              const SizedBox(height: 18),
              for (final d in dados.chart)
                _LinhaGrafico(
                  dado: d,
                  rank: ordenados.indexOf(d) + 1,
                  fracReq: d.req / maxReq,
                  fracTempo: d.tempo / maxTempo,
                ),
              const Divider(color: Cores.borda, height: 24),
              Wrap(
                spacing: 18,
                runSpacing: 8,
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _Legenda(Cores.azul, 'Nº de requisições'),
                      SizedBox(width: 16),
                      _Legenda(Color(0xFFCBD5E1), 'Tempo médio (h)'),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check, size: 14, color: Cores.verde),
                      const SizedBox(width: 4),
                      Text(
                        'Atualizado às $agora',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Cores.verde,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Estatistica extends StatelessWidget {
  const _Estatistica({
    required this.icone,
    required this.corIcone,
    required this.fundoIcone,
    required this.valor,
    required this.rotulo,
  });

  final IconData icone;
  final Color corIcone;
  final Color fundoIcone;
  final String valor;
  final String rotulo;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Cores.borda),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: fundoIcone,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icone, size: 19, color: corIcone),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  valor,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Cores.titulo,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(rotulo,
                    style:
                        const TextStyle(fontSize: 12, color: Cores.cinza)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LinhaGrafico extends StatelessWidget {
  const _LinhaGrafico({
    required this.dado,
    required this.rank,
    required this.fracReq,
    required this.fracTempo,
  });

  final ServicoStat dado;
  final int rank;
  final double fracReq;
  final double fracTempo;

  (Color, Color) get _coresRank => switch (rank) {
        1 => (const Color(0xFFFEF9C3), const Color(0xFFA16207)),
        2 => (const Color(0xFFF1F5F9), const Color(0xFF475569)),
        3 => (const Color(0xFFFEF3E2), const Color(0xFF92400E)),
        _ => (const Color(0xFFF8FAFC), const Color(0xFF94A3B8)),
      };

  Widget _trilha(double fracao, List<Color> cores) {
    return Container(
      height: 8,
      decoration: BoxDecoration(
        color: Cores.borda,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: fracao.clamp(0.0, 1.0),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: cores),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final (fundo, texto) = _coresRank;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 22,
                height: 22,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: fundo, shape: BoxShape.circle),
                child: Text(
                  '$rank',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: texto,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  dado.servico,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Cores.texto,
                  ),
                ),
              ),
              Text(
                '${dado.req} req',
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: Cores.azul,
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 36,
                child: Text(
                  formatarTempo(dado.tempo),
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                      fontSize: 12, color: Cores.cinzaClaro),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _trilha(fracReq, const [Cores.azul, Color(0xFF60A5FA)]),
          const SizedBox(height: 5),
          _trilha(fracTempo, const [Cores.cinzaClaro, Color(0xFFCBD5E1)]),
        ],
      ),
    );
  }
}

class _Legenda extends StatelessWidget {
  const _Legenda(this.cor, this.texto);

  final Color cor;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: cor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(texto,
            style: const TextStyle(fontSize: 12, color: Cores.cinza)),
      ],
    );
  }
}
