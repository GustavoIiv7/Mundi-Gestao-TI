using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MundiGestaoTI.DTOs;
using MundiGestaoTI.Services;

namespace MundiGestaoTI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class AuthController : ControllerBase
    {
        private readonly IAuthService _authService;

        public AuthController(IAuthService authService)
        {
            _authService = authService;
        }

        /// <summary>POST /api/auth/login — devolve o token JWT.</summary>
        [HttpPost("login")]
        [AllowAnonymous]
        public async Task<IActionResult> Login([FromBody] LoginRequestDto dto)
        {
            var resultado = await _authService.LoginAsync(dto);

            if (resultado is null)
                return Unauthorized(new { mensagem = "Login ou senha incorretos." });

            return Ok(resultado);
        }

        /// <summary>POST /api/auth/cadastrar — cadastra funcionário (somente Admin).</summary>
        [HttpPost("cadastrar")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> Cadastrar([FromBody] CriarUsuarioDto dto)
        {
            try
            {
                var usuario = await _authService.CriarUsuarioAsync(dto);
                return Created($"/api/usuarios/{usuario.Id}", usuario);
            }
            catch (ArgumentException ex)
            {
                return BadRequest(new { mensagem = ex.Message });
            }
            catch (InvalidOperationException ex)
            {
                return Conflict(new { mensagem = ex.Message });
            }
        }
    }
}
