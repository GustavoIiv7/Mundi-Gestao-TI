import '../models/area.dart';
import '../models/chamado.dart';

/// Conversões entre os textos da API e os enums do app.
extension AreaApi on AreaGestao {
  /// Valor aceito pela API: redes | banco | acessos | sistemas
  String get chaveApi => this == AreaGestao.bancoDados ? 'banco' : name;
}

AreaGestao areaDeApi(String texto) => switch (texto.toLowerCase()) {
      'redes' => AreaGestao.redes,
      'banco' => AreaGestao.bancoDados,
      'acessos' => AreaGestao.acessos,
      _ => AreaGestao.sistemas,
    };

extension PrioridadeApi on Prioridade {
  /// Urgente | Alta | Normal | Baixa
  String get textoApi => name[0].toUpperCase() + name.substring(1);
}

Prioridade prioridadeDeApi(String texto) => switch (texto.toLowerCase()) {
      'urgente' => Prioridade.urgente,
      'alta' => Prioridade.alta,
      'baixa' => Prioridade.baixa,
      _ => Prioridade.normal,
    };

extension StatusApi on StatusChamado {
  /// Aberto | EmAndamento | Agendado
  String get textoApi => name[0].toUpperCase() + name.substring(1);
}

StatusChamado statusDeApi(String texto) => switch (texto.toLowerCase()) {
      'emandamento' => StatusChamado.emAndamento,
      'agendado' => StatusChamado.agendado,
      _ => StatusChamado.aberto,
    };

/// A API devolve UTC (com "Z"); o app mostra no fuso do aparelho.
DateTime dataLocal(String iso) => DateTime.parse(iso).toLocal();
