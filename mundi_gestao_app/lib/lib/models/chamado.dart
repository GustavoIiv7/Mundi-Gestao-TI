enum Prioridade { urgente, alta, normal, baixa }

extension PrioridadeRotulo on Prioridade {
  String get rotulo => switch (this) {
        Prioridade.urgente => 'URGENTE',
        Prioridade.alta => 'ALTA',
        Prioridade.normal => 'NORMAL',
        Prioridade.baixa => 'BAIXA',
      };
}

enum StatusChamado { aberto, emAtendimento, resolvido }

extension StatusRotulo on StatusChamado {
  String get rotulo => switch (this) {
        StatusChamado.aberto => 'Aberto',
        StatusChamado.emAtendimento => 'Em atendimento',
        StatusChamado.resolvido => 'Resolvido',
      };
}

class EventoHistorico {
  final DateTime data;
  final String descricao;

  const EventoHistorico(this.data, this.descricao);
}

class Chamado {
  final int id;
  final String titulo;
  final String descricao;
  final Prioridade prioridade;
  final StatusChamado status;
  final int progresso; // 0 a 100
  final DateTime dataAbertura;
  final String solicitante;
  final String? atendente;
  final List<EventoHistorico> historico;

  const Chamado({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.prioridade,
    required this.status,
    required this.progresso,
    required this.dataAbertura,
    required this.solicitante,
    this.atendente,
    this.historico = const [],
  });
}

String formatarDataHora(DateTime d) {
  String dois(int n) => n.toString().padLeft(2, '0');
  return '${dois(d.day)}/${dois(d.month)}/${d.year} ${dois(d.hour)}:${dois(d.minute)}';
}
