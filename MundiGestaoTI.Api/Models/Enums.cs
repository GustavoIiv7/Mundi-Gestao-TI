namespace MundiGestaoTI.Models
{
    /// <summary>Prioridades do chamado (filtros da tela de requisições).</summary>
    public enum Prioridade
    {
        Baixa = 0,
        Normal = 1,
        Alta = 2,
        Urgente = 3
    }

    /// <summary>Status do chamado (bolinhas de status da tela de requisições).</summary>
    public enum StatusTicket
    {
        Aberto = 0,
        EmAndamento = 1,
        Agendado = 2,
        Resolvido = 3,
        Fechado = 4
    }

    /// <summary>As quatro áreas de gestão do portal.</summary>
    public enum AreaGestao
    {
        Redes = 0,
        Banco = 1,
        Acessos = 2,
        Sistemas = 3
    }

    /// <summary>Perfil de acesso do usuário.</summary>
    public enum Perfil
    {
        Analista = 0,
        Admin = 1
    }

    /// <summary>Converte texto em enum aceitando apenas nomes válidos (ignora maiúsculas).</summary>
    public static class ConversorEnum
    {
        public static bool Tentar<T>(string? texto, out T valor) where T : struct, Enum
        {
            valor = default;
            return !string.IsNullOrWhiteSpace(texto)
                && Enum.TryParse(texto.Trim(), true, out valor)
                && Enum.IsDefined(valor);
        }
    }
}
