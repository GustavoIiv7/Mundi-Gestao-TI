import 'area.dart';
import 'chamado.dart';

// Dados de demonstração iguais aos do portal web (ex3.html).
// Na integração, virão da API .NET.

class TicketSeed {
  const TicketSeed(this.titulo, this.prioridade, this.status, this.data, this.hora);

  final String titulo;
  final Prioridade prioridade;
  final StatusChamado status;
  final String data;
  final String hora;
}

class ServicoStat {
  const ServicoStat(this.servico, this.req, this.tempo);

  final String servico;
  final int req;
  final double tempo;
}

class ResumoDashboard {
  const ResumoDashboard(this.total, this.concluidos, this.tempoMedio);

  final int total;
  final int concluidos;
  final String tempoMedio;

  int get taxa => total == 0 ? 0 : (concluidos * 100 / total).round();
}

class ItemMonitor {
  const ItemMonitor(this.titulo, this.prioridade, this.data, this.prog);

  final String titulo;
  final Prioridade prioridade;
  final String data;
  final int prog;
}

class ItemRelatorio {
  const ItemRelatorio(this.titulo, this.tecnico, this.data, this.tempo);

  final String titulo;
  final String tecnico;
  final String data;
  final String tempo;
}

class ContatoChat {
  const ContatoChat(this.nome, this.msg1, this.msg2);

  final String nome;
  final String msg1;
  final String msg2;
}

enum TipoItem { ativo, alerta, pendente }

class ItemCartao {
  const ItemCartao(this.texto, this.tipo);

  final String texto;
  final TipoItem tipo;
}

class DadosArea {
  const DadosArea({
    required this.itensCartao,
    required this.contato,
    required this.resumo,
    required this.tickets,
    required this.chart,
    required this.monitor,
    required this.relatorio,
  });

  final List<ItemCartao> itensCartao;
  final ContatoChat contato;
  final ResumoDashboard resumo;
  final List<TicketSeed> tickets;
  final List<ServicoStat> chart;
  final List<ItemMonitor> monitor;
  final List<ItemRelatorio> relatorio;
}

/// Formata como no portal web: 2.5h, 4h, 0.8h.
String formatarTempo(double t) => t == t.roundToDouble() ? '${t.round()}h' : '${t}h';

const _urgente = Prioridade.urgente;
const _alta = Prioridade.alta;
const _normal = Prioridade.normal;
const _baixa = Prioridade.baixa;
const _aberto = StatusChamado.aberto;
const _andamento = StatusChamado.emAndamento;
const _agendado = StatusChamado.agendado;

DadosArea dadosDaArea(AreaGestao area) => switch (area) {
      AreaGestao.redes => const DadosArea(
          itensCartao: [
            ItemCartao('Monitoramento de Rede', TipoItem.ativo),
            ItemCartao('Configuração de Switches', TipoItem.alerta),
            ItemCartao('Firewall e Segurança', TipoItem.ativo),
          ],
          contato: ContatoChat(
            'Anderson Silva',
            'Olá, temos uma queda no switch do 3º andar.',
            'A VLAN do setor financeiro também está inacessível.',
          ),
          resumo: ResumoDashboard(74, 61, '2,1h'),
          tickets: [
            TicketSeed('Queda de switch — 3º andar', _urgente, _aberto, '08/04/2026', '09:10'),
            TicketSeed('VLAN financeiro inacessível', _urgente, _andamento, '08/04/2026', '09:45'),
            TicketSeed('Configuração de firewall perimetral', _alta, _aberto, '07/04/2026', '14:20'),
            TicketSeed('Latência elevada na WAN', _alta, _andamento, '07/04/2026', '11:00'),
            TicketSeed('Renovação de certificado SSL', _normal, _agendado, '06/04/2026', '10:30'),
            TicketSeed('Atualização de firmware dos APs', _normal, _agendado, '05/04/2026', '16:00'),
            TicketSeed('Documentação de topologia de rede', _baixa, _aberto, '03/04/2026', '08:00'),
          ],
          chart: [
            ServicoStat('Configuração de switches', 18, 2.5),
            ServicoStat('Manutenção de firewall', 14, 4.0),
            ServicoStat('Suporte a Wi-Fi', 22, 1.5),
            ServicoStat('Gestão de VLAN', 11, 3.0),
            ServicoStat('Troca de cabos / patch', 9, 0.8),
          ],
          monitor: [
            ItemMonitor('Queda de switch — 3º andar', _urgente, '08/04/2026', 30),
            ItemMonitor('VLAN financeiro inacessível', _urgente, '08/04/2026', 55),
            ItemMonitor('Configuração de firewall perimetral', _alta, '07/04/2026', 20),
            ItemMonitor('Latência elevada na WAN', _alta, '07/04/2026', 70),
            ItemMonitor('Documentação de topologia de rede', _baixa, '03/04/2026', 10),
          ],
          relatorio: [
            ItemRelatorio('Substituição de switch SW-02', 'Rafael S.', '01/04/2026', '1h 40min'),
            ItemRelatorio('Reconfiguração de VLAN corporativa', 'Ana P.', '29/03/2026', '3h 10min'),
            ItemRelatorio('Atualização firmware roteador RT-01', 'Rafael S.', '26/03/2026', '0h 55min'),
            ItemRelatorio('Instalação de AP — sala de reuniões', 'Carlos M.', '22/03/2026', '1h 20min'),
            ItemRelatorio('Diagnóstico e reparo cabo par-trançado', 'Ana P.', '18/03/2026', '0h 45min'),
          ],
        ),
      AreaGestao.bancoDados => const DadosArea(
          itensCartao: [
            ItemCartao('Backup Automático', TipoItem.ativo),
            ItemCartao('Otimização de Queries', TipoItem.pendente),
            ItemCartao('Replicação de Dados', TipoItem.ativo),
          ],
          contato: ContatoChat(
            'Anderson Souza',
            'O job de backup da madrugada falhou novamente.',
            'O índice da tabela de pedidos está fragmentado acima de 85%.',
          ),
          resumo: ResumoDashboard(70, 58, '2,6h'),
          tickets: [
            TicketSeed('Falha no job de backup noturno', _urgente, _andamento, '08/04/2026', '06:15'),
            TicketSeed('Fragmentação crítica — tabela pedidos', _alta, _aberto, '08/04/2026', '08:30'),
            TicketSeed('Lentidão nas queries do ERP', _alta, _andamento, '07/04/2026', '15:00'),
            TicketSeed('Upgrade SQL Server 2022', _normal, _agendado, '06/04/2026', '09:00'),
            TicketSeed('Revisão de permissões de acesso ao BD', _normal, _aberto, '05/04/2026', '11:30'),
            TicketSeed('Criação de usuário de leitura para BI', _baixa, _agendado, '04/04/2026', '14:00'),
            TicketSeed('Documentação de stored procedures', _baixa, _aberto, '02/04/2026', '10:00'),
          ],
          chart: [
            ServicoStat('Backup e restauração', 20, 1.8),
            ServicoStat('Otimização de queries', 15, 3.5),
            ServicoStat('Gestão de índices', 17, 2.2),
            ServicoStat('Criação de usuários', 10, 0.5),
            ServicoStat('Atualização de BD', 8, 5.0),
          ],
          monitor: [
            ItemMonitor('Falha no job de backup noturno', _urgente, '08/04/2026', 45),
            ItemMonitor('Fragmentação crítica — tabela pedidos', _alta, '08/04/2026', 60),
            ItemMonitor('Lentidão nas queries do ERP', _alta, '07/04/2026', 80),
            ItemMonitor('Revisão de permissões de acesso ao BD', _normal, '05/04/2026', 25),
            ItemMonitor('Documentação de stored procedures', _baixa, '02/04/2026', 15),
          ],
          relatorio: [
            ItemRelatorio('Restauração BD-PROD após falha de disco', 'Carla M.', '02/04/2026', '2h 30min'),
            ItemRelatorio('Rebuild de índices — tabela clientes', 'Diego T.', '30/03/2026', '1h 05min'),
            ItemRelatorio('Criação de usuário leitura — equipe BI', 'Carla M.', '27/03/2026', '0h 20min'),
            ItemRelatorio('Migração BD homologação para nova VM', 'Diego T.', '24/03/2026', '4h 15min'),
            ItemRelatorio('Ajuste de plano de execução — ERP', 'Carla M.', '20/03/2026', '1h 50min'),
          ],
        ),
      AreaGestao.acessos => const DadosArea(
          itensCartao: [
            ItemCartao('Controle de Permissões', TipoItem.ativo),
            ItemCartao('Autenticação 2FA', TipoItem.ativo),
            ItemCartao('Auditoria de Logs', TipoItem.alerta),
          ],
          contato: ContatoChat(
            'Anderson Souza',
            'Um colaborador bloqueado precisa de acesso urgente ao sistema de RH.',
            'Também temos um ex-funcionário com credencial ainda ativa.',
          ),
          resumo: ResumoDashboard(96, 89, '0,9h'),
          tickets: [
            TicketSeed('Desbloqueio urgente — sistema RH', _urgente, _andamento, '08/04/2026', '08:55'),
            TicketSeed('Revogar acesso — colaborador desligado', _urgente, _aberto, '08/04/2026', '09:20'),
            TicketSeed('Criação de perfil — novo gerente TI', _alta, _aberto, '07/04/2026', '13:00'),
            TicketSeed('Revisão de permissões — setor fiscal', _alta, _andamento, '06/04/2026', '10:00'),
            TicketSeed('Habilitação de 2FA para diretoria', _normal, _agendado, '05/04/2026', '09:30'),
            TicketSeed('Auditoria de acessos inativos', _normal, _andamento, '04/04/2026', '14:30'),
            TicketSeed('Atualização de política de senhas', _baixa, _agendado, '02/04/2026', '11:00'),
          ],
          chart: [
            ServicoStat('Criação / bloqueio de contas', 24, 0.4),
            ServicoStat('Revisão de permissões', 16, 1.5),
            ServicoStat('Ativação de 2FA', 18, 0.3),
            ServicoStat('Auditoria de acessos', 8, 3.0),
            ServicoStat('Redefinição de senhas', 30, 0.2),
          ],
          monitor: [
            ItemMonitor('Desbloqueio urgente — sistema RH', _urgente, '08/04/2026', 65),
            ItemMonitor('Revogar acesso — colaborador desligado', _urgente, '08/04/2026', 20),
            ItemMonitor('Criação de perfil — novo gerente TI', _alta, '07/04/2026', 40),
            ItemMonitor('Revisão de permissões — setor fiscal', _alta, '06/04/2026', 75),
            ItemMonitor('Auditoria de acessos inativos', _normal, '04/04/2026', 50),
          ],
          relatorio: [
            ItemRelatorio('Revogação de acessos — lote desligamentos mar/26', 'Lucas F.', '03/04/2026', '1h 10min'),
            ItemRelatorio('Ativação de 2FA — equipe diretoria', 'Mariana L.', '31/03/2026', '0h 50min'),
            ItemRelatorio('Auditoria de contas inativas — Q1 2026', 'Lucas F.', '28/03/2026', '3h 40min'),
            ItemRelatorio('Criação de perfis — novos colaboradores fev/26', 'Mariana L.', '25/03/2026', '1h 00min'),
            ItemRelatorio('Revisão geral de permissões — setor financeiro', 'Lucas F.', '19/03/2026', '2h 20min'),
          ],
        ),
      AreaGestao.sistemas => const DadosArea(
          itensCartao: [
            ItemCartao('Atualizações de Software', TipoItem.pendente),
            ItemCartao('Monitoramento de Servidores', TipoItem.ativo),
            ItemCartao('Gerenciamento de Licenças', TipoItem.ativo),
          ],
          contato: ContatoChat(
            'Anderson Souza',
            'O sistema de ERP está fora do ar desde às 07h.',
            'O serviço de e-mail também está com intermitências.',
          ),
          resumo: ResumoDashboard(82, 68, '2,9h'),
          tickets: [
            TicketSeed('ERP fora do ar — instância produção', _urgente, _andamento, '08/04/2026', '07:05'),
            TicketSeed('Serviço de e-mail com intermitências', _urgente, _aberto, '08/04/2026', '07:40'),
            TicketSeed('Atualização do sistema de BI pendente', _alta, _agendado, '07/04/2026', '09:00'),
            TicketSeed('Patch de segurança — 14 servidores', _alta, _andamento, '06/04/2026', '11:00'),
            TicketSeed('Migração de licenças Office 365', _normal, _agendado, '05/04/2026', '14:00'),
            TicketSeed('Revisão de scripts de inicialização', _normal, _aberto, '04/04/2026', '10:30'),
            TicketSeed('Inventário de softwares instalados', _baixa, _andamento, '03/04/2026', '09:00'),
          ],
          chart: [
            ServicoStat('Suporte ao ERP', 26, 4.2),
            ServicoStat('Atualizações e patches', 20, 2.8),
            ServicoStat('Gestão de e-mail', 15, 1.2),
            ServicoStat('Monitoramento servidores', 12, 0.9),
            ServicoStat('Licenças de software', 9, 1.5),
          ],
          monitor: [
            ItemMonitor('ERP fora do ar — instância produção', _urgente, '08/04/2026', 68),
            ItemMonitor('Serviço de e-mail com intermitências', _urgente, '08/04/2026', 35),
            ItemMonitor('Patch de segurança — 14 servidores', _alta, '06/04/2026', 43),
            ItemMonitor('Revisão de scripts de inicialização', _normal, '04/04/2026', 30),
            ItemMonitor('Inventário de softwares instalados', _baixa, '03/04/2026', 60),
          ],
          relatorio: [
            ItemRelatorio('Restauração ERP via snapshot 03/04', 'Priya S.', '08/04/2026', '2h 10min'),
            ItemRelatorio('Aplicação de patches KB — lote mar/26', 'Fernando O.', '01/04/2026', '3h 30min'),
            ItemRelatorio('Migração Office 365 — grupo financeiro', 'Priya S.', '28/03/2026', '1h 45min'),
            ItemRelatorio('Atualização antivírus — 80 estações', 'Fernando O.', '25/03/2026', '0h 40min'),
            ItemRelatorio('Inventário de licenças — trimestre Q1', 'Priya S.', '20/03/2026', '2h 00min'),
          ],
        ),
    };
