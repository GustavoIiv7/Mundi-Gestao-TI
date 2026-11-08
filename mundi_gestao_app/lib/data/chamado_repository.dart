import 'package:flutter/foundation.dart';

import '../models/area.dart';
import '../models/chamado.dart';
import '../models/dados_gestao.dart';
import 'api_client.dart';
import 'auth_service.dart';
import 'mapeamentos.dart';

/// Avisa as telas que a lista de chamados mudou.
final ValueNotifier<int> chamadosAlterados = ValueNotifier<int>(0);

abstract class ChamadoRepository {
  Future<List<Chamado>> listar(AreaGestao area);

  Future<Chamado> criar({
    required AreaGestao area,
    required String titulo,
    required String descricao,
    required Prioridade prioridade,
    required String solicitante,
  });

  /// O usuário logado assume o chamado (se estava aberto, passa a "em andamento").
  Future<Chamado> assumir(int id);

  Future<Chamado> alterarStatus(int id, StatusChamado status);

  Future<Chamado> atualizarProgresso(int id, int progresso);

  /// Marca como resolvido (progresso 100%); o chamado sai da lista e vai para o Relatório.
  Future<void> resolver(int id);

  /// Somente Admin.
  Future<void> excluir(int id);
}

/// Implementação real: chamados vêm da API .NET (a lista já vem ordenada por prioridade e data).
class ApiChamadoRepository implements ChamadoRepository {
  Chamado _paraChamado(Map<String, dynamic> t) {
    final criado = dataLocal(t['criadoEm'] as String);
    return Chamado(
      id: t['id'] as int,
      area: areaDeApi(t['area'] as String),
      titulo: t['titulo'] as String,
      prioridade: prioridadeDeApi(t['prioridade'] as String),
      status: statusDeApi(t['status'] as String),
      data: formatarData(criado),
      hora: formatarHora(criado),
      descricao: t['descricao'] as String?,
      solicitante: t['nomeCriador'] as String?,
      responsavel: t['nomeResponsavel'] as String?,
      responsavelId: t['responsavelId'] as int?,
      progresso: t['progresso'] as int? ?? 0,
    );
  }

  @override
  Future<List<Chamado>> listar(AreaGestao area) async {
    final lista = await api.get('/api/tickets',
        query: {'area': area.chaveApi, 'ativos': 'true'}) as List;
    return lista.cast<Map<String, dynamic>>().map(_paraChamado).toList();
  }

  @override
  Future<Chamado> criar({
    required AreaGestao area,
    required String titulo,
    required String descricao,
    required Prioridade prioridade,
    required String solicitante,
  }) async {
    // O criador é o usuário do token; "solicitante" não precisa ir no corpo.
    final json = await api.post('/api/tickets', {
      'titulo': titulo,
      'descricao': descricao,
      'prioridade': prioridade.textoApi,
      'area': area.chaveApi,
    }) as Map<String, dynamic>;
    chamadosAlterados.value++;
    return _paraChamado(json);
  }

  Future<Chamado> _atualizar(int id, Map<String, Object?> corpo) async {
    final json = await api.put('/api/tickets/$id', corpo) as Map<String, dynamic>;
    chamadosAlterados.value++;
    return _paraChamado(json);
  }

  @override
  Future<Chamado> assumir(int id) =>
      _atualizar(id, {'responsavelId': authService.sessao!.usuarioId});

  @override
  Future<Chamado> alterarStatus(int id, StatusChamado status) =>
      _atualizar(id, {'status': status.textoApi});

  @override
  Future<Chamado> atualizarProgresso(int id, int progresso) =>
      _atualizar(id, {'progresso': progresso});

  @override
  Future<void> resolver(int id) async {
    await _atualizar(id, {'status': 'Resolvido'});
  }

  @override
  Future<void> excluir(int id) async {
    await api.delete('/api/tickets/$id');
    chamadosAlterados.value++;
  }
}

/// Implementação com dados em memória (os mesmos do portal web). Útil para demonstrar o app sem a API.
class MockChamadoRepository implements ChamadoRepository {
  MockChamadoRepository() {
    for (final area in AreaGestao.values) {
      for (final t in dadosDaArea(area).tickets) {
        _dados.add(Chamado(
          id: _proximoId++,
          area: area,
          titulo: t.titulo,
          prioridade: t.prioridade,
          status: t.status,
          data: t.data,
          hora: t.hora,
        ));
      }
    }
  }

  final List<Chamado> _dados = [];
  int _proximoId = 1;

  @override
  Future<List<Chamado>> listar(AreaGestao area) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    final lista = _dados.where((c) => c.area == area).toList();
    lista.sort((a, b) {
      final p = a.prioridade.peso.compareTo(b.prioridade.peso);
      if (p != 0) return p;
      if (a.nova != b.nova) return a.nova ? -1 : 1;
      if (a.nova && b.nova) return b.id.compareTo(a.id);
      return a.id.compareTo(b.id);
    });
    return lista;
  }

  @override
  Future<Chamado> criar({
    required AreaGestao area,
    required String titulo,
    required String descricao,
    required Prioridade prioridade,
    required String solicitante,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final agora = DateTime.now();
    final chamado = Chamado(
      id: _proximoId++,
      area: area,
      titulo: titulo,
      prioridade: prioridade,
      status: StatusChamado.aberto,
      data: formatarData(agora),
      hora: formatarHora(agora),
      descricao: descricao,
      solicitante: solicitante,
      nova: true,
    );
    _dados.add(chamado);
    chamadosAlterados.value++;
    return chamado;
  }

  static ApiException get _offline =>
      ApiException('Ação indisponível no modo sem API.');

  @override
  Future<Chamado> assumir(int id) => throw _offline;

  @override
  Future<Chamado> alterarStatus(int id, StatusChamado status) => throw _offline;

  @override
  Future<Chamado> atualizarProgresso(int id, int progresso) => throw _offline;

  @override
  Future<void> resolver(int id) => throw _offline;

  @override
  Future<void> excluir(int id) => throw _offline;
}

final ChamadoRepository chamadoRepository = ApiChamadoRepository();
