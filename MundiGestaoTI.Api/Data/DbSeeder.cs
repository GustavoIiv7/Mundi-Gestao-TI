using MundiGestaoTI.Models;

namespace MundiGestaoTI.Data
{
    /// <summary>
    /// Dados iniciais. Só roda se o banco estiver vazio e se "Seed:Habilitar" estiver ligado.
    /// "Seed:DadosDemo" cria também chamados de demonstração (os mesmos do portal web)
    /// e um histórico de chamados concluídos para alimentar o Dashboard.
    /// TODOS os dados criados aqui são fictícios, apenas para demonstração.
    /// </summary>
    public static class DbSeeder
    {
        private const string SenhaDemo = "senha123";

        private sealed record Ativo(
            string Titulo, Prioridade Prioridade, StatusTicket Status,
            string Categoria, int Progresso, int DiasAtras, string Hora);

        private sealed record Concluido(string Titulo, string Categoria, int Minutos);

        private sealed record Servico(string Nome, int Requisicoes, double Horas);

        private sealed record DadosArea(
            AreaGestao Area, Ativo[] Ativos, Concluido[] Concluidos, Servico[] Servicos);

        public static void Semear(AppDbContext db, bool dadosDemo)
        {
            if (db.Usuarios.Any()) return;

            var rafael = NovoUsuario("rafael.souza", "Rafael Souza Rosendo", AreaGestao.Redes, Perfil.Analista);
            var anderson = NovoUsuario("anderson.souza", "Anderson Souza da Silva", AreaGestao.Banco, Perfil.Analista);
            var isabela = NovoUsuario("isabela.aparecida", "Isabela Aparecida Barbosa Bueno", AreaGestao.Acessos, Perfil.Analista);
            var gustavo = NovoUsuario("gustavo.de", "Gustavo de Oliveira", AreaGestao.Sistemas, Perfil.Admin);

            db.Usuarios.AddRange(rafael, anderson, isabela, gustavo);
            db.SaveChanges();

            if (!dadosDemo) return;

            var equipe = new[] { rafael, anderson, isabela, gustavo };
            var tickets = new List<Ticket>();
            var indiceArea = 0;

            foreach (var dados in Dados())
            {
                // Chamados ativos (lista de requisições e monitoramento)
                for (var i = 0; i < dados.Ativos.Length; i++)
                {
                    var a = dados.Ativos[i];
                    var hora = int.Parse(a.Hora[..2]);
                    var minuto = int.Parse(a.Hora[3..]);
                    var emAndamento = a.Status == StatusTicket.EmAndamento;

                    tickets.Add(new Ticket
                    {
                        Titulo = a.Titulo,
                        Descricao = "Chamado de demonstração.",
                        Prioridade = a.Prioridade,
                        Status = a.Status,
                        Area = dados.Area,
                        Categoria = a.Categoria,
                        Progresso = a.Progresso,
                        CriadoEm = LocalParaUtc(a.DiasAtras, hora, minuto),
                        CriadorId = equipe[(indiceArea + i) % 4].Id,
                        ResponsavelId = emAndamento ? equipe[(indiceArea + i + 1) % 4].Id : null
                    });
                }

                // Últimos concluídos (aba Relatório): ficam como os mais recentes
                var diasRelatorio = new[] { 1, 2, 4, 6, 8 };
                for (var i = 0; i < dados.Concluidos.Length; i++)
                {
                    var c = dados.Concluidos[i];
                    var criado = LocalParaUtc(diasRelatorio[i], 9, 0);

                    tickets.Add(ConcluidoDe(
                        dados.Area, c.Titulo, c.Categoria, Prioridade.Normal, criado,
                        TimeSpan.FromMinutes(c.Minutos),
                        equipe[(indiceArea + i) % 4].Id,
                        equipe[(indiceArea + i + 2) % 4].Id));
                }

                // Histórico: um chamado concluído por requisição de cada serviço (9 a 29 dias atrás)
                var prioridadesCiclo = new[] { Prioridade.Normal, Prioridade.Alta, Prioridade.Baixa, Prioridade.Normal };
                var fatores = new[] { 0.6, 0.8, 1.0, 1.2, 1.4 };
                var sequencia = 0;

                foreach (var servico in dados.Servicos)
                {
                    for (var i = 0; i < servico.Requisicoes; i++)
                    {
                        sequencia++;
                        var dias = 9 + (sequencia * 7) % 21;
                        var criado = LocalParaUtc(dias, 8 + sequencia % 9, 0);
                        var duracao = TimeSpan.FromMinutes(Math.Round(servico.Horas * 60 * fatores[i % 5]));

                        tickets.Add(ConcluidoDe(
                            dados.Area,
                            $"{servico.Nome} — atendimento #{i + 1}",
                            servico.Nome,
                            prioridadesCiclo[sequencia % 4],
                            criado,
                            duracao,
                            equipe[sequencia % 4].Id,
                            equipe[(sequencia + 1) % 4].Id));
                    }
                }

                indiceArea++;
            }

            db.Tickets.AddRange(tickets);
            db.SaveChanges();

            // Conversa de exemplo para o chat
            var agora = DateTime.UtcNow;
            db.Mensagens.AddRange(
                new Mensagem
                {
                    Conteudo = "Olá, temos uma queda no switch do 3º andar.",
                    RemetenteId = anderson.Id,
                    DestinatarioId = rafael.Id,
                    EnviadaEm = agora.AddMinutes(-30),
                    Lida = true
                },
                new Mensagem
                {
                    Conteudo = "Claro! Qual o problema específico?",
                    RemetenteId = rafael.Id,
                    DestinatarioId = anderson.Id,
                    EnviadaEm = agora.AddMinutes(-28),
                    Lida = true
                },
                new Mensagem
                {
                    Conteudo = "A VLAN do setor financeiro também está inacessível.",
                    RemetenteId = anderson.Id,
                    DestinatarioId = rafael.Id,
                    EnviadaEm = agora.AddMinutes(-27)
                });
            db.SaveChanges();
        }

        private static Usuario NovoUsuario(string login, string nome, AreaGestao area, Perfil perfil)
        {
            var usuario = new Usuario { Login = login, Nome = nome, Area = area, Perfil = perfil };
            usuario.DefinirSenha(SenhaDemo);
            return usuario;
        }

        private static Ticket ConcluidoDe(
            AreaGestao area, string titulo, string categoria, Prioridade prioridade,
            DateTime criadoEm, TimeSpan duracao, int criadorId, int responsavelId)
        {
            return new Ticket
            {
                Titulo = titulo,
                Descricao = "Atendimento concluído (dado de demonstração).",
                Prioridade = prioridade,
                Status = StatusTicket.Resolvido,
                Area = area,
                Categoria = categoria,
                Progresso = 100,
                CriadoEm = criadoEm,
                AtualizadoEm = criadoEm + duracao,
                ResolvidoEm = criadoEm + duracao,
                CriadorId = criadorId,
                ResponsavelId = responsavelId
            };
        }

        /// <summary>Data/hora local (de "dias atrás") convertida para UTC.</summary>
        private static DateTime LocalParaUtc(int diasAtras, int hora, int minuto) =>
            DateTime.Today.AddDays(-diasAtras).AddHours(hora).AddMinutes(minuto).ToUniversalTime();

        private static DadosArea[] Dados()
        {
            const Prioridade U = Prioridade.Urgente;
            const Prioridade A = Prioridade.Alta;
            const Prioridade N = Prioridade.Normal;
            const Prioridade B = Prioridade.Baixa;
            const StatusTicket Ab = StatusTicket.Aberto;
            const StatusTicket An = StatusTicket.EmAndamento;
            const StatusTicket Ag = StatusTicket.Agendado;

            return new[]
            {
                new DadosArea(AreaGestao.Redes,
                    new[]
                    {
                        new Ativo("Queda de switch — 3º andar", U, Ab, "Configuração de switches", 30, 0, "09:10"),
                        new Ativo("VLAN financeiro inacessível", U, An, "Gestão de VLAN", 55, 0, "09:45"),
                        new Ativo("Configuração de firewall perimetral", A, Ab, "Manutenção de firewall", 20, 1, "14:20"),
                        new Ativo("Latência elevada na WAN", A, An, "Configuração de switches", 70, 1, "11:00"),
                        new Ativo("Renovação de certificado SSL", N, Ag, "Manutenção de firewall", 0, 2, "10:30"),
                        new Ativo("Atualização de firmware dos APs", N, Ag, "Suporte a Wi-Fi", 0, 3, "16:00"),
                        new Ativo("Documentação de topologia de rede", B, Ab, "Configuração de switches", 10, 5, "08:00"),
                    },
                    new[]
                    {
                        new Concluido("Substituição de switch SW-02", "Configuração de switches", 100),
                        new Concluido("Reconfiguração de VLAN corporativa", "Gestão de VLAN", 190),
                        new Concluido("Atualização firmware roteador RT-01", "Manutenção de firewall", 55),
                        new Concluido("Instalação de AP — sala de reuniões", "Suporte a Wi-Fi", 80),
                        new Concluido("Diagnóstico e reparo cabo par-trançado", "Troca de cabos / patch", 45),
                    },
                    new[]
                    {
                        new Servico("Configuração de switches", 18, 2.5),
                        new Servico("Manutenção de firewall", 14, 4.0),
                        new Servico("Suporte a Wi-Fi", 22, 1.5),
                        new Servico("Gestão de VLAN", 11, 3.0),
                        new Servico("Troca de cabos / patch", 9, 0.8),
                    }),

                new DadosArea(AreaGestao.Banco,
                    new[]
                    {
                        new Ativo("Falha no job de backup noturno", U, An, "Backup e restauração", 45, 0, "06:15"),
                        new Ativo("Fragmentação crítica — tabela pedidos", A, Ab, "Gestão de índices", 60, 0, "08:30"),
                        new Ativo("Lentidão nas queries do ERP", A, An, "Otimização de queries", 80, 1, "15:00"),
                        new Ativo("Upgrade SQL Server 2022", N, Ag, "Atualização de BD", 0, 2, "09:00"),
                        new Ativo("Revisão de permissões de acesso ao BD", N, Ab, "Criação de usuários", 25, 3, "11:30"),
                        new Ativo("Criação de usuário de leitura para BI", B, Ag, "Criação de usuários", 0, 4, "14:00"),
                        new Ativo("Documentação de stored procedures", B, Ab, "Otimização de queries", 15, 6, "10:00"),
                    },
                    new[]
                    {
                        new Concluido("Restauração BD-PROD após falha de disco", "Backup e restauração", 150),
                        new Concluido("Rebuild de índices — tabela clientes", "Gestão de índices", 65),
                        new Concluido("Criação de usuário leitura — equipe BI", "Criação de usuários", 20),
                        new Concluido("Migração BD homologação para nova VM", "Atualização de BD", 255),
                        new Concluido("Ajuste de plano de execução — ERP", "Otimização de queries", 110),
                    },
                    new[]
                    {
                        new Servico("Backup e restauração", 20, 1.8),
                        new Servico("Otimização de queries", 15, 3.5),
                        new Servico("Gestão de índices", 17, 2.2),
                        new Servico("Criação de usuários", 10, 0.5),
                        new Servico("Atualização de BD", 8, 5.0),
                    }),

                new DadosArea(AreaGestao.Acessos,
                    new[]
                    {
                        new Ativo("Desbloqueio urgente — sistema RH", U, An, "Criação / bloqueio de contas", 65, 0, "08:55"),
                        new Ativo("Revogar acesso — colaborador desligado", U, Ab, "Criação / bloqueio de contas", 20, 0, "09:20"),
                        new Ativo("Criação de perfil — novo gerente TI", A, Ab, "Criação / bloqueio de contas", 40, 1, "13:00"),
                        new Ativo("Revisão de permissões — setor fiscal", A, An, "Revisão de permissões", 75, 2, "10:00"),
                        new Ativo("Habilitação de 2FA para diretoria", N, Ag, "Ativação de 2FA", 0, 3, "09:30"),
                        new Ativo("Auditoria de acessos inativos", N, An, "Auditoria de acessos", 50, 4, "14:30"),
                        new Ativo("Atualização de política de senhas", B, Ag, "Redefinição de senhas", 0, 6, "11:00"),
                    },
                    new[]
                    {
                        new Concluido("Revogação de acessos — lote de desligamentos", "Criação / bloqueio de contas", 70),
                        new Concluido("Ativação de 2FA — equipe diretoria", "Ativação de 2FA", 50),
                        new Concluido("Auditoria de contas inativas — trimestre", "Auditoria de acessos", 220),
                        new Concluido("Criação de perfis — novos colaboradores", "Criação / bloqueio de contas", 60),
                        new Concluido("Revisão geral de permissões — setor financeiro", "Revisão de permissões", 140),
                    },
                    new[]
                    {
                        new Servico("Criação / bloqueio de contas", 24, 0.4),
                        new Servico("Revisão de permissões", 16, 1.5),
                        new Servico("Ativação de 2FA", 18, 0.3),
                        new Servico("Auditoria de acessos", 8, 3.0),
                        new Servico("Redefinição de senhas", 30, 0.2),
                    }),

                new DadosArea(AreaGestao.Sistemas,
                    new[]
                    {
                        new Ativo("ERP fora do ar — instância produção", U, An, "Suporte ao ERP", 68, 0, "07:05"),
                        new Ativo("Serviço de e-mail com intermitências", U, Ab, "Gestão de e-mail", 35, 0, "07:40"),
                        new Ativo("Atualização do sistema de BI pendente", A, Ag, "Atualizações e patches", 0, 1, "09:00"),
                        new Ativo("Patch de segurança — 14 servidores", A, An, "Atualizações e patches", 43, 2, "11:00"),
                        new Ativo("Migração de licenças Office 365", N, Ag, "Licenças de software", 0, 3, "14:00"),
                        new Ativo("Revisão de scripts de inicialização", N, Ab, "Monitoramento servidores", 30, 4, "10:30"),
                        new Ativo("Inventário de softwares instalados", B, An, "Licenças de software", 60, 5, "09:00"),
                    },
                    new[]
                    {
                        new Concluido("Restauração ERP via snapshot", "Suporte ao ERP", 130),
                        new Concluido("Aplicação de patches KB — lote mensal", "Atualizações e patches", 210),
                        new Concluido("Migração Office 365 — grupo financeiro", "Licenças de software", 105),
                        new Concluido("Atualização antivírus — 80 estações", "Monitoramento servidores", 40),
                        new Concluido("Inventário de licenças — trimestre", "Licenças de software", 120),
                    },
                    new[]
                    {
                        new Servico("Suporte ao ERP", 26, 4.2),
                        new Servico("Atualizações e patches", 20, 2.8),
                        new Servico("Gestão de e-mail", 15, 1.2),
                        new Servico("Monitoramento servidores", 12, 0.9),
                        new Servico("Licenças de software", 9, 1.5),
                    }),
            };
        }
    }
}
