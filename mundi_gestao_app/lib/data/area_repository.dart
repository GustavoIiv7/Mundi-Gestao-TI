import '../models/area.dart';
import '../models/chamado.dart';
import '../models/dados_gestao.dart';
import 'api_client.dart';
import 'mapeamentos.dart';

class DashboardDados {
  const DashboardDados(this.resumo, this.chart);

  final ResumoDashboard resumo;
  final List<ServicoStat> chart;
}

/// Abas Dashboard, Monitoramento e Relatório (dados calculados pela API).
class AreaRepository {
  double _umaCasa(num v) => (v * 10).round() / 10;

  Future<DashboardDados> dashboard(AreaGestao area) async {
    final j = await api.get('/api/areas/${area.chaveApi}/dashboard')
        as Map<String, dynamic>;
    final servicos = (j['servicos'] as List)
        .cast<Map<String, dynamic>>()
        .map((s) => ServicoStat(
              s['servico'] as String,
              s['requisicoes'] as int,
              _umaCasa(s['tempoMedioHoras'] as num),
            ))
        .toList();
    final resumo = ResumoDashboard(
      j['total'] as int,
      j['concluidos'] as int,
      formatarTempo(_umaCasa(j['tempoMedioHoras'] as num)),
    );
    return DashboardDados(resumo, servicos);
  }

  Future<List<ItemMonitor>> monitoramento(AreaGestao area) async {
    final lista = await api.get('/api/areas/${area.chaveApi}/monitoramento')
        as List;
    return lista.cast<Map<String, dynamic>>().map((m) {
      return ItemMonitor(
        m['titulo'] as String,
        prioridadeDeApi(m['prioridade'] as String),
        formatarData(dataLocal(m['abertoEm'] as String)),
        m['progresso'] as int,
      );
    }).toList();
  }

  Future<List<ItemRelatorio>> relatorio(AreaGestao area) async {
    final lista = await api.get('/api/areas/${area.chaveApi}/relatorio',
        query: {'limite': '5'}) as List;
    return lista.cast<Map<String, dynamic>>().map((r) {
      return ItemRelatorio(
        r['titulo'] as String,
        r['tecnico'] as String,
        formatarData(dataLocal(r['concluidoEm'] as String)),
        _duracao(r['duracaoMinutos'] as int),
      );
    }).toList();
  }

  /// 100 -> "1h 40min", 45 -> "45min", 120 -> "2h"
  String _duracao(int minutos) {
    final h = minutos ~/ 60;
    final m = minutos % 60;
    if (h == 0) return '${m}min';
    if (m == 0) return '${h}h';
    return '${h}h ${m}min';
  }
}

final AreaRepository areaRepository = AreaRepository();
