using Microsoft.EntityFrameworkCore;
using MundiGestaoTI.Data;
using MundiGestaoTI.DTOs;
using MundiGestaoTI.Models;

namespace MundiGestaoTI.Services
{
    public interface IAreaService
    {
        Task<DashboardAreaDto> DashboardAsync(AreaGestao area);
        Task<IReadOnlyList<MonitorItemDto>> MonitoramentoAsync(AreaGestao area);
        Task<IReadOnlyList<RelatorioItemDto>> RelatorioAsync(AreaGestao area, int limite);
    }

    /// <summary>Dados agregados das abas Dashboard, Monitoramento e Relatório.</summary>
    public class AreaService : IAreaService
    {
        private const int JanelaDias = 30;
        private static readonly string[] Particulas = { "de", "da", "do", "dos", "das", "e" };

        private readonly AppDbContext _context;

        public AreaService(AppDbContext context)
        {
            _context = context;
        }

        public async Task<DashboardAreaDto> DashboardAsync(AreaGestao area)
        {
            var desde = DateTime.UtcNow.AddDays(-JanelaDias);

            var tickets = await _context.Tickets
                .AsNoTracking()
                .Where(t => t.Area == area && t.CriadoEm >= desde)
                .ToListAsync();

            var total = tickets.Count;
            var concluidos = tickets.Count(t => t.Concluido);
            var taxa = total == 0 ? 0 : (int)Math.Round(concluidos * 100.0 / total);

            var servicos = tickets
                .GroupBy(t => string.IsNullOrWhiteSpace(t.Categoria) ? "Outros" : t.Categoria!)
                .Select(g => new ServicoStatDto(g.Key, g.Count(), MediaHoras(g)))
                .OrderByDescending(s => s.Requisicoes)
                .ThenBy(s => s.Servico)
                .Take(5)
                .ToList();

            return new DashboardAreaDto(area.ToString(), total, concluidos, taxa, MediaHoras(tickets), servicos);
        }

        public async Task<IReadOnlyList<MonitorItemDto>> MonitoramentoAsync(AreaGestao area)
        {
            var tickets = await _context.Tickets
                .AsNoTracking()
                .Where(t => t.Area == area &&
                            (t.Status == StatusTicket.Aberto || t.Status == StatusTicket.EmAndamento))
                .ToListAsync();

            return tickets
                .OrderByDescending(t => t.Prioridade)
                .ThenByDescending(t => t.CriadoEm)
                .Take(20)
                .Select(t => new MonitorItemDto(t.Id, t.Titulo, t.Prioridade.ToString(), t.CriadoEm, t.Progresso))
                .ToList();
        }

        public async Task<IReadOnlyList<RelatorioItemDto>> RelatorioAsync(AreaGestao area, int limite)
        {
            limite = Math.Clamp(limite, 1, 50);

            var tickets = await _context.Tickets
                .AsNoTracking()
                .Include(t => t.Responsavel)
                .Where(t => t.Area == area && t.Status == StatusTicket.Resolvido && t.ResolvidoEm != null)
                .ToListAsync();

            return tickets
                .OrderByDescending(t => t.ResolvidoEm)
                .Take(limite)
                .Select(t => new RelatorioItemDto(
                    t.Id,
                    t.Titulo,
                    Abreviar(t.Responsavel?.Nome),
                    t.ResolvidoEm!.Value,
                    (int)Math.Round(t.DuracaoAtendimento!.Value.TotalMinutes)))
                .ToList();
        }

        /// <summary>Média (em horas, 1 casa) do tempo de atendimento dos chamados já resolvidos.</summary>
        private static double MediaHoras(IEnumerable<Ticket> tickets)
        {
            var duracoes = tickets
                .Where(t => t.DuracaoAtendimento.HasValue)
                .Select(t => t.DuracaoAtendimento!.Value.TotalHours)
                .ToList();

            return duracoes.Count == 0 ? 0 : Math.Round(duracoes.Average(), 1);
        }

        /// <summary>"Rafael Souza Rosendo" → "Rafael S."</summary>
        private static string Abreviar(string? nome)
        {
            if (string.IsNullOrWhiteSpace(nome)) return "Não atribuído";

            var partes = nome.Split(' ', StringSplitOptions.RemoveEmptyEntries);
            if (partes.Length < 2) return partes[0];

            var sobrenome = partes.Skip(1)
                .FirstOrDefault(p => !Particulas.Contains(p.ToLower())) ?? partes[1];

            return $"{partes[0]} {char.ToUpper(sobrenome[0])}.";
        }
    }
}
