using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace MundiGestaoTI.Models
{
    /// <summary>Mensagem do chat interno ("Chamados Internos").</summary>
    public class Mensagem
    {
        [Key]
        public int Id { get; set; }

        [Required(ErrorMessage = "Conteúdo é obrigatório")]
        [MaxLength(1000)]
        public string Conteudo { get; set; } = string.Empty;

        public DateTime EnviadaEm { get; set; } = DateTime.UtcNow;

        public bool Lida { get; set; }

        [Required]
        public int RemetenteId { get; set; }

        [Required]
        public int DestinatarioId { get; set; }

        /// <summary>Chamado relacionado (opcional).</summary>
        public int? TicketId { get; set; }

        [ForeignKey("RemetenteId")]
        public Usuario? Remetente { get; set; }

        [ForeignKey("DestinatarioId")]
        public Usuario? Destinatario { get; set; }

        [ForeignKey("TicketId")]
        public Ticket? Ticket { get; set; }

        public void MarcarComoLida()
        {
            if (!Lida)
                Lida = true;
        }
    }
}
