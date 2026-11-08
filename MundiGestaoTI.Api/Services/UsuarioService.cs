using Microsoft.EntityFrameworkCore;
using MundiGestaoTI.Data;
using MundiGestaoTI.DTOs;
using MundiGestaoTI.Models;

namespace MundiGestaoTI.Services
{
    public interface IUsuarioService
    {
        Task<IReadOnlyList<UsuarioDto>> ListarAsync(AreaGestao? area);
        Task<UsuarioDto?> ObterContatoDaAreaAsync(AreaGestao area, int usuarioLogadoId);
    }

    public class UsuarioService : IUsuarioService
    {
        private readonly AppDbContext _context;

        public UsuarioService(AppDbContext context)
        {
            _context = context;
        }

        public async Task<IReadOnlyList<UsuarioDto>> ListarAsync(AreaGestao? area)
        {
            var usuarios = await _context.Usuarios
                .AsNoTracking()
                .Where(u => u.Ativo)
                .ToListAsync();

            return usuarios
                .Where(u => area is null || u.Area == area)
                .OrderBy(u => u.Nome)
                .Select(Mapear)
                .ToList();
        }

        /// <summary>
        /// Contato do chat para a área: prefere alguém da própria área (que não seja o usuário logado);
        /// se não houver, usa qualquer outro usuário ativo.
        /// </summary>
        public async Task<UsuarioDto?> ObterContatoDaAreaAsync(AreaGestao area, int usuarioLogadoId)
        {
            var candidatos = await _context.Usuarios
                .AsNoTracking()
                .Where(u => u.Ativo && u.Id != usuarioLogadoId)
                .ToListAsync();

            var contato = candidatos
                .OrderByDescending(u => u.Area == area)
                .ThenBy(u => u.Nome)
                .FirstOrDefault();

            return contato is null ? null : Mapear(contato);
        }

        private static UsuarioDto Mapear(Usuario u) =>
            new(u.Id, u.Nome, u.Area.ToString(), u.Perfil.ToString(), u.Ativo);
    }
}
