using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MundiGestaoTI.DTOs;
using MundiGestaoTI.Services;

namespace MundiGestaoTI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class MensagensController : ControllerBase
    {
        private readonly IMensagemService _mensagemService;

        public MensagensController(IMensagemService mensagemService)
        {
            _mensagemService = mensagemService;
        }

        private int UsuarioLogadoId => int.Parse(User.FindFirst("sub")!.Value);

        /// <summary>GET /api/mensagens/conversa/{outroUsuarioId} — histórico do chat.</summary>
        [HttpGet("conversa/{outroUsuarioId:int}")]
        public async Task<IActionResult> ObterConversa(int outroUsuarioId)
        {
            return Ok(await _mensagemService.ObterConversaAsync(UsuarioLogadoId, outroUsuarioId));
        }

        /// <summary>POST /api/mensagens — envia uma mensagem.</summary>
        [HttpPost]
        public async Task<IActionResult> Enviar([FromBody] EnviarMensagemDto dto)
        {
            try
            {
                var mensagem = await _mensagemService.EnviarAsync(dto, UsuarioLogadoId);
                return Created($"/api/mensagens/{mensagem.Id}", mensagem);
            }
            catch (ArgumentException ex)
            {
                return BadRequest(new { mensagem = ex.Message });
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new { mensagem = ex.Message });
            }
        }

        /// <summary>PATCH /api/mensagens/{id}/lida</summary>
        [HttpPatch("{id:int}/lida")]
        public async Task<IActionResult> MarcarComoLida(int id)
        {
            var sucesso = await _mensagemService.MarcarComoLidaAsync(id, UsuarioLogadoId);
            return sucesso ? NoContent() : NotFound();
        }
    }
}
