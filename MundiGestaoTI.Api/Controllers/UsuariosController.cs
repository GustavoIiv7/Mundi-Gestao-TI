using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MundiGestaoTI.Models;
using MundiGestaoTI.Services;

namespace MundiGestaoTI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class UsuariosController : ControllerBase
    {
        private readonly IUsuarioService _usuarioService;

        public UsuariosController(IUsuarioService usuarioService)
        {
            _usuarioService = usuarioService;
        }

        private int UsuarioLogadoId => int.Parse(User.FindFirst("sub")!.Value);

        /// <summary>GET /api/usuarios?area=redes — funcionários ativos (filtro de área opcional).</summary>
        [HttpGet]
        public async Task<IActionResult> Listar([FromQuery] string? area)
        {
            AreaGestao? filtro = null;
            if (!string.IsNullOrWhiteSpace(area))
            {
                if (!ConversorEnum.Tentar<AreaGestao>(area, out var a))
                    return BadRequest(new { mensagem = $"Área inválida: {area}" });
                filtro = a;
            }

            return Ok(await _usuarioService.ListarAsync(filtro));
        }

        /// <summary>GET /api/usuarios/contato/{area} — contato do chat daquela área.</summary>
        [HttpGet("contato/{area}")]
        public async Task<IActionResult> ContatoDaArea(string area)
        {
            if (!ConversorEnum.Tentar<AreaGestao>(area, out var a))
                return BadRequest(new { mensagem = $"Área inválida: {area}" });

            var contato = await _usuarioService.ObterContatoDaAreaAsync(a, UsuarioLogadoId);
            return contato is null ? NotFound() : Ok(contato);
        }
    }
}
