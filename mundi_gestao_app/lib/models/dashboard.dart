import 'chamado.dart';

// DADOS DE DEMONSTRAÇÃO: serão substituídos por dados vindos da API (.NET).

class ServicoStat {
  const ServicoStat(this.nome, this.quantidade, this.horasMedias);

  final String nome;
  final int quantidade;
  final double horasMedias;
}

class ResumoArea {
  const ResumoArea({
    required this.total,
    required this.taxaResolucao,
    required this.horasMedias,
    required this.servicos,
  });

  final int total;
  final int taxaResolucao;
  final double horasMedias;
  final List<ServicoStat> servicos;
}

String formatarHoras(double h) => '${h.toStringAsFixed(1).replaceAll('.', ',')}h';

ResumoArea resumoDaArea(AreaGestao area) => switch (area) {
      AreaGestao.redes => const ResumoArea(
          total: 74,
          taxaResolucao: 82,
          horasMedias: 2.1,
          servicos: [
            ServicoStat('Suporte a Wi-Fi', 22, 1.5),
            ServicoStat('Configuração de switches', 18, 2.5),
            ServicoStat('Manutenção de firewall', 14, 4.0),
            ServicoStat('Gestão de VLAN', 11, 3.0),
            ServicoStat('Troca de cabos/patch', 9, 0.8),
          ],
        ),
      AreaGestao.bancoDados => const ResumoArea(
          total: 58,
          taxaResolucao: 85,
          horasMedias: 2.8,
          servicos: [
            ServicoStat('Otimização de consultas', 17, 3.2),
            ServicoStat('Rotinas de backup', 14, 1.8),
            ServicoStat('Criação de índices', 10, 2.4),
            ServicoStat('Restauração de dados', 9, 4.0),
            ServicoStat('Limpeza e manutenção', 8, 1.2),
          ],
        ),
      AreaGestao.acessos => const ResumoArea(
          total: 66,
          taxaResolucao: 79,
          horasMedias: 1.4,
          servicos: [
            ServicoStat('Liberação de acesso', 24, 0.9),
            ServicoStat('Redefinição de senha', 19, 0.4),
            ServicoStat('Revisão de permissões', 12, 2.2),
            ServicoStat('Licenças de software', 7, 1.5),
            ServicoStat('Desativação de usuário', 4, 0.6),
          ],
        ),
      AreaGestao.sistemas => const ResumoArea(
          total: 49,
          taxaResolucao: 88,
          horasMedias: 3.4,
          servicos: [
            ServicoStat('Correção de erros', 18, 4.5),
            ServicoStat('Atualização de versão', 11, 3.8),
            ServicoStat('Ajustes em relatórios', 9, 2.5),
            ServicoStat('Novas funcionalidades', 6, 6.0),
            ServicoStat('Integrações', 5, 3.2),
          ],
        ),
    };

enum EstadoAtivo { online, atencao, offline }

extension EstadoAtivoX on EstadoAtivo {
  String get rotulo => switch (this) {
        EstadoAtivo.online => 'Online',
        EstadoAtivo.atencao => 'Atenção',
        EstadoAtivo.offline => 'Offline',
      };
}

class Ativo {
  const Ativo(this.nome, this.detalhe, this.estado);

  final String nome;
  final String detalhe;
  final EstadoAtivo estado;
}

List<Ativo> ativosDaArea(AreaGestao area) => switch (area) {
      AreaGestao.redes => const [
          Ativo('Firewall FW-01', 'CPU 34% · 1.240 sessões', EstadoAtivo.online),
          Ativo('Switch SW-01', 'Latência 2 ms · 24 portas', EstadoAtivo.online),
          Ativo('Access Point AP-03', 'Carga 91% · 2º andar', EstadoAtivo.atencao),
          Ativo('Switch SW-03', 'Sem resposta há 12 min', EstadoAtivo.offline),
          Ativo('Link de internet', '480 Mbps de 500 Mbps', EstadoAtivo.online),
        ],
      AreaGestao.bancoDados => const [
          Ativo('Servidor SQL principal', 'CPU 52% · 61% de memória', EstadoAtivo.online),
          Ativo('Servidor de homologação', 'CPU 12% · disponível', EstadoAtivo.online),
          Ativo('Backup noturno', 'Última execução falhou', EstadoAtivo.offline),
          Ativo('Disco de dados', '87% de uso', EstadoAtivo.atencao),
        ],
      AreaGestao.acessos => const [
          Ativo('Diretório de usuários', '312 contas ativas', EstadoAtivo.online),
          Ativo('Servidor de autenticação', 'Tempo de resposta 140 ms', EstadoAtivo.online),
          Ativo('VPN corporativa', '38 conexões ativas', EstadoAtivo.online),
          Ativo('Licenças de software', '4 licenças vencem em 15 dias', EstadoAtivo.atencao),
        ],
      AreaGestao.sistemas => const [
          Ativo('ERP — módulo de vendas', 'Erros 500 intermitentes', EstadoAtivo.atencao),
          Ativo('ERP — módulo financeiro', 'Operando normalmente', EstadoAtivo.online),
          Ativo('Sistema de estoque', 'Versão 3.2 · atualização pendente', EstadoAtivo.atencao),
          Ativo('Servidor de aplicação', 'CPU 45% · 58% de memória', EstadoAtivo.online),
        ],
    };
