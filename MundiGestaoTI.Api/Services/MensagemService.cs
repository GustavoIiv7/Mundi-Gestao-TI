using Microsoft.EntityFrameworkCore;
using MundiGestaoTI.Data;
using MundiGestaoTI.DTOs;
using MundiGestaoTI.Models;

namespace MundiGestaoTI.Services
{
    public interface IMensagemService
    {
        Task<IReadOnlyList<MensagemDto>> ObterConversaAsync(int usuarioAId, int usuarioBId);
        Task<MensagemDto> EnviarAsync(EnviarMensagemDto dto, int remetenteId);
        Task<bool> MarcarComoLidaAsync(int mensagemId, int destinatarioId);
    }

    /// <summary>Chat interno entre funcionários.</summary>
    public class MensagemService : IMensagemService
    {
        private readonly AppDbContext _context;

        public MensagemService(AppDbContext context)
        {
            _context = context;
        }

        /// <summary>Conversa entre dois usuários em ordem cronológica; marca as recebidas como lidas.</summary>
        public async Task<IReadOnlyList<MensagemDto>> ObterConversaAsync(int usuarioAId, int usuarioBId)
        {
            var mensagens = await _context.Mensagens
                .Include(m => m.Remetente)
                .Where(m =>
                    (m.RemetenteId == usuarioAId && m.DestinatarioId == usuarioBId) ||
                    (m.RemetenteId == usuarioBId && m.DestinatarioId == usuarioAId))
                .OrderBy(m => m.EnviadaEm)
                .ToListAsync();

            var naoLidas = mensagens
                .Where(m => m.DestinatarioId == usuarioAId && !m.Lida)
                .ToList();

            foreach (var m in naoLidas)
                m.MarcarComoLida();

            if (naoLidas.Count > 0)
                await _context.SaveChangesAsync();

            return mensagens
                .Select(m => new MensagemDto(
                    m.Id,
                    m.Conteudo,
                    m.EnviadaEm,
                    m.Lida,
                    m.RemetenteId,
                    m.Remetente?.Nome ?? "Desconhecido",
                    m.TicketId))
                .ToList();
        }

        public async Task<MensagemDto> EnviarAsync(EnviarMensagemDto dto, int remetenteId)
        {
            var destinatarioId = dto.DestinatarioId
                ?? throw new ArgumentException("Informe o destinatário.");

            if (destinatarioId == remetenteId)
                throw new ArgumentException("Não é possível enviar mensagem para si mesmo.");

            var destinatario = await _context.Usuarios.FindAsync(destinatarioId);
            if (destinatario is null || !destinatario.Ativo)
                throw new KeyNotFoundException("Destinatário não encontrado.");

            var remetente = await _context.Usuarios.FindAsync(remetenteId)
                ?? throw new KeyNotFoundException("Remetente não encontrado.");

            var mensagem = new Mensagem
            {
                Conteudo = dto.Conteudo.Trim(),
                RemetenteId = remetenteId,
                DestinatarioId = destinatarioId,
                TicketId = dto.TicketId
            };

            _context.Mensagens.Add(mensagem);
            await _context.SaveChangesAsync();

            return new MensagemDto(
                mensagem.Id,
                mensagem.Conteudo,
                mensagem.EnviadaEm,
                mensagem.Lida,
                remetenteId,
                remetente.Nome,
                mensagem.TicketId);
        }

        public async Task<bool> MarcarComoLidaAsync(int mensagemId, int destinatarioId)
        {
            var mensagem = await _context.Mensagens
                .FirstOrDefaultAsync(m => m.Id == mensagemId && m.DestinatarioId == destinatarioId);

            if (mensagem is null) return false;

            mensagem.MarcarComoLida();
            await _context.SaveChangesAsync();
            return true;
        }
    }
}
