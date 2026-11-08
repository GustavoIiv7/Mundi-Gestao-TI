using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using MundiGestaoTI.Data;
using MundiGestaoTI.DTOs;
using MundiGestaoTI.Models;

namespace MundiGestaoTI.Services
{
    public interface IAuthService
    {
        Task<LoginResponseDto?> LoginAsync(LoginRequestDto dto);
        Task<UsuarioDto> CriarUsuarioAsync(CriarUsuarioDto dto);
    }

    /// <summary>Login (gera o JWT) e cadastro de usuários.</summary>
    public class AuthService : IAuthService
    {
        private readonly AppDbContext _context;
        private readonly IConfiguration _config;

        public AuthService(AppDbContext context, IConfiguration config)
        {
            _context = context;
            _config = config;
        }

        public async Task<LoginResponseDto?> LoginAsync(LoginRequestDto dto)
        {
            var login = dto.Login.Trim().ToLower();

            var usuario = await _context.Usuarios
                .FirstOrDefaultAsync(u => u.Login == login && u.Ativo);

            // Mesma resposta para login inexistente e senha errada (não revela qual campo falhou)
            if (usuario is null || !usuario.VerificarSenha(dto.Senha))
                return null;

            var (token, expiraEm) = GerarTokenJwt(usuario);
            return new LoginResponseDto(
                token, expiraEm, usuario.Id, usuario.Nome,
                usuario.Area.ToString(), usuario.Perfil.ToString());
        }

        public async Task<UsuarioDto> CriarUsuarioAsync(CriarUsuarioDto dto)
        {
            if (!ConversorEnum.Tentar<AreaGestao>(dto.Area, out var area))
                throw new ArgumentException($"Área inválida: {dto.Area}. Use Redes, Banco, Acessos ou Sistemas.");

            var perfil = Perfil.Analista;
            if (!string.IsNullOrWhiteSpace(dto.Perfil) && !ConversorEnum.Tentar<Perfil>(dto.Perfil, out perfil))
                throw new ArgumentException($"Perfil inválido: {dto.Perfil}. Use Analista ou Admin.");

            var login = dto.Login.Trim().ToLower();
            if (await _context.Usuarios.AnyAsync(u => u.Login == login))
                throw new InvalidOperationException($"Login '{dto.Login}' já está em uso.");

            var usuario = new Usuario
            {
                Login = login,
                Nome = dto.Nome.Trim(),
                Area = area,
                Perfil = perfil
            };
            usuario.DefinirSenha(dto.Senha);

            _context.Usuarios.Add(usuario);
            await _context.SaveChangesAsync();

            return new UsuarioDto(usuario.Id, usuario.Nome, usuario.Area.ToString(),
                usuario.Perfil.ToString(), usuario.Ativo);
        }

        private (string Token, DateTime ExpiraEm) GerarTokenJwt(Usuario usuario)
        {
            var chave = _config["Jwt:Key"]
                ?? throw new InvalidOperationException("Jwt:Key não configurado.");
            var emissor = _config["Jwt:Issuer"] ?? "MundiGestaoTI";
            var horas = _config.GetValue("Jwt:ExpiracaoHoras", 8);

            var claims = new[]
            {
                new Claim(JwtRegisteredClaimNames.Sub, usuario.Id.ToString()),
                new Claim(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString()),
                new Claim("name", usuario.Nome),
                new Claim("login", usuario.Login),
                new Claim("area", usuario.Area.ToString()),
                new Claim("role", usuario.Perfil.ToString())
            };

            var credenciais = new SigningCredentials(
                new SymmetricSecurityKey(Encoding.UTF8.GetBytes(chave)),
                SecurityAlgorithms.HmacSha256);

            var expiraEm = DateTime.UtcNow.AddHours(horas);
            var jwt = new JwtSecurityToken(
                issuer: emissor,
                audience: emissor,
                claims: claims,
                expires: expiraEm,
                signingCredentials: credenciais);

            return (new JwtSecurityTokenHandler().WriteToken(jwt), expiraEm);
        }
    }
}
