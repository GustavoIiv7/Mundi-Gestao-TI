import '../models/chamado.dart';

/// Contrato de acesso aos chamados. As telas só conhecem esta interface.
/// Para integrar com a API, basta criar uma ApiChamadoRepository que
/// implemente os mesmos métodos e trocar o objeto no final deste arquivo.
abstract class ChamadoRepository {
  Future<List<Chamado>> listar();

  Future<Chamado> criar({
    required String titulo,
    required String descricao,
    required Prioridade prioridade,
    required String solicitante,
  });
}

class MockChamadoRepository implements ChamadoRepository {
  final List<Chamado> _chamados = [
    Chamado(
      id: 1,
      titulo: 'Queda de switch — 3º andar',
      descricao:
          'Switch principal do 3º andar sem resposta após reinicialização. '
          'Todos os dispositivos do andar estão sem conectividade.',
      prioridade: Prioridade.urgente,
      status: StatusChamado.emAtendimento,
      progresso: 30,
      dataAbertura: DateTime(2026, 4, 8, 9, 10),
      solicitante: 'Rafael Souza Rosendo',
      atendente: 'Isabela Aparecida Barbosa Bueno',
      historico: [
        EventoHistorico(DateTime(2026, 4, 8, 9, 10), 'Chamado aberto.'),
        EventoHistorico(DateTime(2026, 4, 8, 9, 30), 'Atendimento iniciado.'),
      ],
    ),
    Chamado(
      id: 2,
      titulo: 'VLAN financeiro inacessível',
      descricao:
          'A VLAN do setor financeiro está inacessível desde as 09h. '
          'Usuários não conseguem acessar os sistemas internos.',
      prioridade: Prioridade.urgente,
      status: StatusChamado.emAtendimento,
      progresso: 55,
      dataAbertura: DateTime(2026, 4, 8, 9, 45),
      solicitante: 'Isabela Aparecida Barbosa Bueno',
      atendente: 'Gustavo de Oliveira',
      historico: [
        EventoHistorico(DateTime(2026, 4, 8, 9, 45), 'Chamado aberto.'),
        EventoHistorico(DateTime(2026, 4, 8, 10, 0), 'Atendimento iniciado.'),
      ],
    ),
    Chamado(
      id: 3,
      titulo: 'Configuração de firewall perimetral',
      descricao:
          'Revisar e atualizar as regras do firewall perimetral para '
          'adequação à nova política de segurança.',
      prioridade: Prioridade.alta,
      status: StatusChamado.aberto,
      progresso: 0,
      dataAbertura: DateTime(2026, 4, 7, 14, 20),
      solicitante: 'Gustavo de Oliveira',
      historico: [
        EventoHistorico(DateTime(2026, 4, 7, 14, 20), 'Chamado aberto.'),
      ],
    ),
    Chamado(
      id: 4,
      titulo: 'Latência elevada na WAN',
      descricao:
          'Latência acima de 300 ms na conexão WAN, afetando o acesso '
          'aos sistemas em nuvem.',
      prioridade: Prioridade.alta,
      status: StatusChamado.emAtendimento,
      progresso: 70,
      dataAbertura: DateTime(2026, 4, 7, 11, 0),
      solicitante: 'Rafael Souza Rosendo',
      atendente: 'Gustavo de Oliveira',
      historico: [
        EventoHistorico(DateTime(2026, 4, 7, 11, 0), 'Chamado aberto.'),
        EventoHistorico(DateTime(2026, 4, 7, 11, 40), 'Atendimento iniciado.'),
      ],
    ),
    Chamado(
      id: 5,
      titulo: 'Falha no job de backup noturno',
      descricao:
          'O job de backup agendado para as 02h falhou com erro de '
          'permissão. Nenhum backup foi realizado na madrugada.',
      prioridade: Prioridade.urgente,
      status: StatusChamado.emAtendimento,
      progresso: 45,
      dataAbertura: DateTime(2026, 4, 8, 6, 15),
      solicitante: 'Isabela Aparecida Barbosa Bueno',
      atendente: 'Gustavo de Oliveira',
      historico: [
        EventoHistorico(DateTime(2026, 4, 8, 6, 15), 'Chamado aberto.'),
        EventoHistorico(DateTime(2026, 4, 8, 7, 0), 'Atendimento iniciado.'),
      ],
    ),
    Chamado(
      id: 6,
      titulo: 'Revogar acesso — colaborador desligado',
      descricao:
          'Funcionário desligado ontem ainda possui credenciais ativas '
          'em todos os sistemas. Risco de segurança.',
      prioridade: Prioridade.urgente,
      status: StatusChamado.aberto,
      progresso: 0,
      dataAbertura: DateTime(2026, 4, 8, 9, 20),
      solicitante: 'Gustavo de Oliveira',
      historico: [
        EventoHistorico(DateTime(2026, 4, 8, 9, 20), 'Chamado aberto.'),
      ],
    ),
    Chamado(
      id: 7,
      titulo: 'ERP fora do ar — instância de produção',
      descricao:
          'Sistema ERP da instância de produção fora do ar desde as 07h. '
          'Todos os setores estão afetados.',
      prioridade: Prioridade.urgente,
      status: StatusChamado.emAtendimento,
      progresso: 68,
      dataAbertura: DateTime(2026, 4, 8, 7, 5),
      solicitante: 'Gustavo de Oliveira',
      atendente: 'Rafael Souza Rosendo',
      historico: [
        EventoHistorico(DateTime(2026, 4, 8, 7, 5), 'Chamado aberto.'),
        EventoHistorico(DateTime(2026, 4, 8, 7, 20), 'Atendimento iniciado.'),
      ],
    ),
    Chamado(
      id: 8,
      titulo: 'Atualização do sistema de BI pendente',
      descricao:
          'A versão atual do BI tem vulnerabilidade conhecida. '
          'Atualização para a versão 4.2 pendente.',
      prioridade: Prioridade.normal,
      status: StatusChamado.aberto,
      progresso: 0,
      dataAbertura: DateTime(2026, 4, 7, 9, 0),
      solicitante: 'Isabela Aparecida Barbosa Bueno',
      historico: [
        EventoHistorico(DateTime(2026, 4, 7, 9, 0), 'Chamado aberto.'),
      ],
    ),
    Chamado(
      id: 9,
      titulo: 'Substituição de switch SW-02',
      descricao:
          'Switch SW-02 do 2º andar substituído após falha de hardware. '
          'Conectividade restaurada.',
      prioridade: Prioridade.baixa,
      status: StatusChamado.resolvido,
      progresso: 100,
      dataAbertura: DateTime(2026, 4, 1, 8, 0),
      solicitante: 'Rafael Souza Rosendo',
      atendente: 'Isabela Aparecida Barbosa Bueno',
      historico: [
        EventoHistorico(DateTime(2026, 4, 1, 8, 0), 'Chamado aberto.'),
        EventoHistorico(DateTime(2026, 4, 1, 8, 20), 'Atendimento iniciado.'),
        EventoHistorico(DateTime(2026, 4, 1, 9, 40), 'Chamado resolvido.'),
      ],
    ),
  ];

  @override
  Future<List<Chamado>> listar() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return List<Chamado>.unmodifiable(_chamados);
  }

  @override
  Future<Chamado> criar({
    required String titulo,
    required String descricao,
    required Prioridade prioridade,
    required String solicitante,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final proximoId =
        _chamados.fold<int>(0, (maior, c) => c.id > maior ? c.id : maior) + 1;
    final agora = DateTime.now();
    final novo = Chamado(
      id: proximoId,
      titulo: titulo,
      descricao: descricao,
      prioridade: prioridade,
      status: StatusChamado.aberto,
      progresso: 0,
      dataAbertura: agora,
      solicitante: solicitante,
      historico: [EventoHistorico(agora, 'Chamado aberto.')],
    );
    _chamados.add(novo);
    return novo;
  }
}

/// Troque aqui por ApiChamadoRepository() quando a API estiver pronta.
final ChamadoRepository chamadoRepository = MockChamadoRepository();
