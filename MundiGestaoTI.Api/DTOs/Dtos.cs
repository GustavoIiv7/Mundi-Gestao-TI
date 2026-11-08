using System.ComponentModel.DataAnnotations;

namespace MundiGestaoTI.DTOs
{
    // ── AUTH ─────────────────────────────────────────────────────────────────

    public sealed class LoginRequestDto
    {
        [Required(ErrorMessage = "Informe o login.")]
        [StringLength(50)]
        public string Login { get; init; } = string.Empty;

        [Required(ErrorMessage = "Informe a senha.")]
        [StringLength(100)]
        public string Senha { get; init; } = string.Empty;
    }

    public record LoginResponseDto(
        string Token,
        DateTime ExpiraEm,
        int UsuarioId,
        string Nome,
        string Area,
        string Perfil);

    // ── USUÁRIO ───────────────────────────────────────────────────────────────

    public record UsuarioDto(int Id, string Nome, string Area, string Perfil, bool Ativo);

    public sealed class CriarUsuarioDto
    {
        [Required, StringLength(50, MinimumLength = 3)]
        public string Login { get; init; } = string.Empty;

        [Required, StringLength(100, MinimumLength = 6, ErrorMessage = "A senha deve ter pelo menos 6 caracteres.")]
        public string Senha { get; init; } = string.Empty;

        [Required, StringLength(100)]
        public string Nome { get; init; } = string.Empty;

        /// <summary>Redes | Banco | Acessos | Sistemas</summary>
        [Required]
        public string Area { get; init; } = string.Empty;

        /// <summary>Analista (padrão) | Admin</summary>
        public string? Perfil { get; init; }
    }

    // ── TICKET ────────────────────────────────────────────────────────────────

    public record TicketDto(
        int Id,
        string Titulo,
        string Descricao,
        string Prioridade,
        string Status,
        string Area,
        string? Categoria,
        int Progresso,
        DateTime CriadoEm,
        DateTime? ResolvidoEm,
        string NomeCriador,
        string? NomeResponsavel);

    public sealed class CriarTicketDto
    {
        [Required, StringLength(200, MinimumLength = 5, ErrorMessage = "O título deve ter entre 5 e 200 caracteres.")]
        public string Titulo { get; init; } = string.Empty;

        [StringLength(2000)]
        public string Descricao { get; init; } = string.Empty;

        /// <summary>Baixa | Normal | Alta | Urgente</summary>
        [Required]
        public string Prioridade { get; init; } = string.Empty;

        /// <summary>Redes | Banco | Acessos | Sistemas</summary>
        [Required]
        public string Area { get; init; } = string.Empty;

        [StringLength(100)]
        public string? Categoria { get; init; }
    }

    public sealed class AtualizarTicketDto
    {
        /// <summary>Aberto | EmAndamento | Agendado | Resolvido | Fechado</summary>
        public string? Status { get; init; }

        public int? ResponsavelId { get; init; }

        [Range(0, 100)]
        public int? Progresso { get; init; }
    }

    // ── ÁREAS (dashboard, monitoramento, relatório) ───────────────────────────

    public record ServicoStatDto(string Servico, int Requisicoes, double TempoMedioHoras);

    public record DashboardAreaDto(
        string Area,
        int Total,
        int Concluidos,
        int TaxaResolucao,
        double TempoMedioHoras,
        IReadOnlyList<ServicoStatDto> Servicos);

    public record MonitorItemDto(int Id, string Titulo, string Prioridade, DateTime AbertoEm, int Progresso);

    public record RelatorioItemDto(int Id, string Titulo, string Tecnico, DateTime ConcluidoEm, int DuracaoMinutos);

    // ── MENSAGEM ──────────────────────────────────────────────────────────────

    public record MensagemDto(
        int Id,
        string Conteudo,
        DateTime EnviadaEm,
        bool Lida,
        int RemetenteId,
        string NomeRemetente,
        int? TicketId);

    public sealed class EnviarMensagemDto
    {
        [Required, StringLength(1000, MinimumLength = 1)]
        public string Conteudo { get; init; } = string.Empty;

        [Required]
        public int? DestinatarioId { get; init; }

        public int? TicketId { get; init; }
    }
}
