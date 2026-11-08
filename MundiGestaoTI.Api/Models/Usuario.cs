using System.ComponentModel.DataAnnotations;

namespace MundiGestaoTI.Models
{
    /// <summary>
    /// Funcionário autorizado a acessar o sistema.
    /// Encapsulamento: login normalizado no setter e senha só alterável por métodos de domínio.
    /// </summary>
    public class Usuario
    {
        private string _login = string.Empty;
        private string _senhaHash = string.Empty;

        [Key]
        public int Id { get; set; }

        [Required(ErrorMessage = "Login é obrigatório")]
        [MaxLength(50)]
        public string Login
        {
            get => _login;
            set => _login = value?.Trim().ToLower() ?? string.Empty;
        }

        [Required]
        public string SenhaHash
        {
            get => _senhaHash;
            private set => _senhaHash = value;
        }

        [Required(ErrorMessage = "Nome é obrigatório")]
        [MaxLength(100)]
        public string Nome { get; set; } = string.Empty;

        /// <summary>Área de origem do funcionário.</summary>
        public AreaGestao Area { get; set; } = AreaGestao.Redes;

        /// <summary>Perfil de acesso (Admin pode cadastrar usuários e excluir chamados).</summary>
        public Perfil Perfil { get; set; } = Perfil.Analista;

        public bool Ativo { get; set; } = true;

        public DateTime CriadoEm { get; set; } = DateTime.UtcNow;

        public ICollection<Ticket> TicketsCriados { get; set; } = new List<Ticket>();
        public ICollection<Ticket> TicketsAtribuidos { get; set; } = new List<Ticket>();
        public ICollection<Mensagem> Mensagens { get; set; } = new List<Mensagem>();

        public void DefinirSenha(string senhaPlana)
        {
            if (string.IsNullOrWhiteSpace(senhaPlana))
                throw new ArgumentException("Senha não pode ser vazia.");

            _senhaHash = BCrypt.Net.BCrypt.HashPassword(senhaPlana);
        }

        public bool VerificarSenha(string senhaPlana)
        {
            if (string.IsNullOrEmpty(_senhaHash)) return false;
            return BCrypt.Net.BCrypt.Verify(senhaPlana, _senhaHash);
        }
    }
}
