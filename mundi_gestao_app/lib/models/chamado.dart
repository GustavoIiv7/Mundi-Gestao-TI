import 'area.dart';

enum Prioridade { urgente, alta, normal, baixa }

extension PrioridadeX on Prioridade {
  String get rotulo => switch (this) {
        Prioridade.urgente => 'URGENTE',
        Prioridade.alta => 'ALTA',
        Prioridade.normal => 'NORMAL',
        Prioridade.baixa => 'BAIXA',
      };

  int get peso => index;
}

enum StatusChamado { aberto, emAndamento, agendado }

extension StatusChamadoX on StatusChamado {
  String get rotulo => switch (this) {
        StatusChamado.aberto => 'Aberto',
        StatusChamado.emAndamento => 'Em andamento',
        StatusChamado.agendado => 'Agendado',
      };
}

class Chamado {
  const Chamado({
    required this.id,
    required this.area,
    required this.titulo,
    required this.prioridade,
    required this.status,
    required this.data,
    required this.hora,
    this.descricao,
    this.solicitante,
    this.responsavel,
    this.responsavelId,
    this.progresso = 0,
    this.nova = false,
  });

  final int id;
  final AreaGestao area;
  final String titulo;
  final Prioridade prioridade;
  final StatusChamado status;
  final String data;
  final String hora;
  final String? descricao;
  final String? solicitante;
  final String? responsavel;
  final int? responsavelId;

  /// Andamento de 0 a 100.
  final int progresso;

  /// true para requisições criadas dentro do app (aparecem primeiro na sua prioridade).
  final bool nova;
}

String _dois(int n) => n.toString().padLeft(2, '0');

String formatarData(DateTime d) => '${_dois(d.day)}/${_dois(d.month)}/${d.year}';

String formatarHora(DateTime d) => '${_dois(d.hour)}:${_dois(d.minute)}';
