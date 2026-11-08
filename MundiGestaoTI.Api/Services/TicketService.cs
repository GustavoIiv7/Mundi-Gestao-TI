using Microsoft.EntityFrameworkCore;
using MundiGestaoTI.Data;
using MundiGestaoTI.DTOs;
using MundiGestaoTI.Models;

namespace MundiGestaoTI.Services
{
    /// <summary>Filtros aceitos na listagem de chamados.</summary>
    public record TicketFiltro(
        string? Area,
        string? Prioridade,
        string? Status,
        int? ResponsavelId,
        bool SomenteAtivos);

    public interface ITicketService
    {
        Task<IReadOnlyList<TicketDto>> ListarAsync(TicketFiltro filtro);
        Task<TicketDto?> ObterPorIdAsync(int id);
        Task<TicketDto> CriarAsync(CriarTicketDto dto, int criadorId);
        Task<TicketDto?> AtualizarAsync(int id, AtualizarTicketDto dto);
        Task<bool> DeletarAsync(int id);
    }

    public class TicketService : ITicketService
    {
        private readonly AppDbContext _context;

        public TicketService(AppDbContext context)
        {
            _context = context;
        }

        public async Task<IReadOnlyList<TicketDto>> ListarAsync(TicketFiltro filtro)
        {
            var query = _context.Tickets
                .AsNoTracking()
                .Include(t => t.Criador)
                .Include(t => t.Responsavel)
                .AsQueryable();

            if (!string.IsNullOrWhiteSpace(filtro.Area))
            {
                if (!ConversorEnum.Tentar<AreaGestao>(filtro.Area, out var area))
                    throw new ArgumentException($"Área inválida: {filtro.Area}");
                query = query.Where(t => t.Area == area);
            }

            if (!string.IsNullOrWhiteSpace(filtro.Prioridade))
            {
                if (!ConversorEnum.Tentar<Prioridade>(filtro.Prioridade, out var prioridade))
                    throw new ArgumentException($"Prioridade inválida: {filtro.Prioridade}");
                query = query.Where(t => t.Prioridade == prioridade);
            }

            if (!string.IsNullOrWhiteSpace(filtro.Status))
            {
                if (!ConversorEnum.Tentar<StatusTicket>(filtro.Status, out var status))
                    throw new ArgumentException($"Status inválido: {filtro.Status}");
                query = query.Where(t => t.Status == status);
            }

            if (filtro.ResponsavelId.HasValue)
                query = query.Where(t => t.ResponsavelId == filtro.ResponsavelId);

            if (filtro.SomenteAtivos)
                query = query.Where(t => t.Status != StatusTicket.Resolvido && t.Status != StatusTicket.Fechado);

            var lista = await query.ToListAsync();

            // Ordenação em memória: as enums ficam gravadas como texto no banco,
            // então ordenar no SQL seria em ordem alfabética (Urgente, Normal, Baixa, Alta).
            return lista
                .OrderByDescending(t => t.Prioridade)
                .ThenByDescending(t => t.CriadoEm)
                .Select(Mapear)
                .ToList();
        }

        public async Task<TicketDto?> ObterPorIdAsync(int id)
        {
            var ticket = await _context.Tickets
                .AsNoTracking()
                .Include(t => t.Criador)
                .Include(t => t.Responsavel)
                .FirstOrDefaultAsync(t => t.Id == id);

            return ticket is null ? null : Mapear(ticket);
        }

        public async Task<TicketDto> CriarAsync(CriarTicketDto dto, int criadorId)
        {
            if (!ConversorEnum.Tentar<Prioridade>(dto.Prioridade, out var prioridade))
                throw new ArgumentException($"Prioridade inválida: {dto.Prioridade}");

            if (!ConversorEnum.Tentar<AreaGestao>(dto.Area, out var area))
                throw new ArgumentException($"Área inválida: {dto.Area}");

            var ticket = new Ticket
            {
                Titulo = dto.Titulo.Trim(),
                Descricao = dto.Descricao?.Trim() ?? string.Empty,
                Prioridade = prioridade,
                Area = area,
                Categoria = string.IsNullOrWhiteSpace(dto.Categoria) ? null : dto.Categoria.Trim(),
                Status = StatusTicket.Aberto,
                CriadorId = criadorId
            };

            _context.Tickets.Add(ticket);
            await _context.SaveChangesAsync();

            return (await ObterPorIdAsync(ticket.Id))!;
        }

        public async Task<TicketDto?> AtualizarAsync(int id, AtualizarTicketDto dto)
        {
            var ticket = await _context.Tickets.FirstOrDefaultAsync(t => t.Id == id);
            if (ticket is null) return null;

            if (!string.IsNullOrWhiteSpace(dto.Status))
            {
                if (!ConversorEnum.Tentar<StatusTicket>(dto.Status, out var novoStatus))
                    throw new ArgumentException($"Status inválido: {dto.Status}");
                ticket.DefinirStatus(novoStatus);
            }

            if (dto.ResponsavelId.HasValue)
            {
                var responsavel = await _context.Usuarios.FindAsync(dto.ResponsavelId.Value);
                if (responsavel is null || !responsavel.Ativo)
                    throw new ArgumentException("Responsável não encontrado.");
                ticket.AtribuirPara(responsavel);
            }

            if (dto.Progresso.HasValue)
            {
                ticket.Progresso = dto.Progresso.Value;
                ticket.AtualizadoEm = DateTime.UtcNow;
            }

            await _context.SaveChangesAsync();
            return await ObterPorIdAsync(id);
        }

        public async Task<bool> DeletarAsync(int id)
        {
            var ticket = await _context.Tickets.FindAsync(id);
            if (ticket is null) return false;

            // Mensagens vinculadas ao chamado ficam sem vínculo (não são apagadas)
            var mensagens = await _context.Mensagens.Where(m => m.TicketId == id).ToListAsync();
            foreach (var m in mensagens)
                m.TicketId = null;

            _context.Tickets.Remove(ticket);
            await _context.SaveChangesAsync();
            return true;
        }

        private static TicketDto Mapear(Ticket t) => new(
            t.Id,
            t.Titulo,
            t.Descricao,
            t.Prioridade.ToString(),
            t.Status.ToString(),
            t.Area.ToString(),
            t.Categoria,
            t.Progresso,
            t.CriadoEm,
            t.ResolvidoEm,
            t.Criador?.Nome ?? "Desconhecido",
            t.Responsavel?.Nome);
    }
}
