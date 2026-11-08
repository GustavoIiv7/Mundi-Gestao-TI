using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace MundiGestaoTI.Models
{
    /// <summary>
    /// Requisição/chamado do portal. Concentra as regras de negócio de status e atribuição.
    /// </summary>
    public class Ticket
    {
        [Key]
        public int Id { get; set; }

        [Required(ErrorMessage = "Título é obrigatório")]
        [MaxLength(200)]
        public string Titulo { get; set; } = string.Empty;

        [MaxLength(2000)]
        public string Descricao { get; set; } = string.Empty;

        public Prioridade Prioridade { get; set; } = Prioridade.Normal;

        public StatusTicket Status { get; set; } = StatusTicket.Aberto;

        /// <summary>Área de gestão responsável pelo chamado.</summary>
        public AreaGestao Area { get; set; } = AreaGestao.Redes;

        /// <summary>Tipo de serviço (ex.: "Suporte a Wi-Fi"). Alimenta o gráfico do dashboard.</summary>
        [MaxLength(100)]
        public string? Categoria { get; set; }

        /// <summary>Andamento de 0 a 100 (barra da aba Monitoramento).</summary>
        [Range(0, 100)]
        public int Progresso { get; set; }

        public DateTime CriadoEm { get; set; } = DateTime.UtcNow;

        public DateTime? AtualizadoEm { get; set; }

        public DateTime? ResolvidoEm { get; set; }

        [Required]
        public int CriadorId { get; set; }

        public int? ResponsavelId { get; set; }

        [ForeignKey("CriadorId")]
        public Usuario? Criador { get; set; }

        [ForeignKey("ResponsavelId")]
        public Usuario? Responsavel { get; set; }

        [NotMapped]
        public bool Concluido => Status == StatusTicket.Resolvido || Status == StatusTicket.Fechado;

        [NotMapped]
        public bool EmAtraso =>
            !Concluido &&
            CriadoEm < DateTime.UtcNow.AddDays(-2) &&
            Prioridade >= Prioridade.Alta;

        /// <summary>Tempo entre a abertura e a resolução (nulo se ainda não resolvido).</summary>
        [NotMapped]
        public TimeSpan? DuracaoAtendimento => ResolvidoEm.HasValue ? ResolvidoEm.Value - CriadoEm : null;

        /// <summary>Muda o status mantendo coerentes ResolvidoEm, AtualizadoEm e Progresso.</summary>
        public void DefinirStatus(StatusTicket novo)
        {
            Status = novo;
            AtualizadoEm = DateTime.UtcNow;

            if (novo == StatusTicket.Resolvido)
            {
                ResolvidoEm ??= DateTime.UtcNow;
                Progresso = 100;
            }
            else
            {
                ResolvidoEm = null;
            }
        }

        /// <summary>Atribui o chamado a um responsável; chamados abertos passam a "em andamento".</summary>
        public void AtribuirPara(Usuario responsavel)
        {
            ArgumentNullException.ThrowIfNull(responsavel);
            ResponsavelId = responsavel.Id;
            Responsavel = responsavel;

            if (Status == StatusTicket.Aberto)
                Status = StatusTicket.EmAndamento;

            AtualizadoEm = DateTime.UtcNow;
        }
    }
}
