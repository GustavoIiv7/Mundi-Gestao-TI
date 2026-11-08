using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MundiGestaoTI.DTOs;
using MundiGestaoTI.Services;

namespace MundiGestaoTI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class TicketsController : ControllerBase
    {
        private readonly ITicketService _ticketService;

        public TicketsController(ITicketService ticketService)
        {
            _ticketService = ticketService;
        }

        // ID do usuário logado, lido do token JWT (claim "sub")
        private int UsuarioLogadoId => int.Parse(User.FindFirst("sub")!.Value);

        /// <summary>
        /// GET /api/tickets?area=redes&amp;prioridade=Urgente&amp;status=Aberto&amp;ativos=true
        /// "ativos=true" esconde os chamados resolvidos/fechados (lista da aba Requisições).
        /// </summary>
        [HttpGet]
        public async Task<IActionResult> Listar(
            [FromQuery] string? area,
            [FromQuery] string? prioridade,
            [FromQuery] string? status,
            [FromQuery] int? responsavelId,
            [FromQuery] bool ativos = false)
        {
            try
            {
                var filtro = new TicketFiltro(area, prioridade, status, responsavelId, ativos);
                return Ok(await _ticketService.ListarAsync(filtro));
            }
            catch (ArgumentException ex)
            {
                return BadRequest(new { mensagem = ex.Message });
            }
        }

        /// <summary>GET /api/tickets/{id}</summary>
        [HttpGet("{id:int}")]
        public async Task<IActionResult> ObterPorId(int id)
        {
            var ticket = await _ticketService.ObterPorIdAsync(id);
            return ticket is null ? NotFound() : Ok(ticket);
        }

        /// <summary>POST /api/tickets — o criador é o usuário autenticado.</summary>
        [HttpPost]
        public async Task<IActionResult> Criar([FromBody] CriarTicketDto dto)
        {
            try
            {
                var ticket = await _ticketService.CriarAsync(dto, UsuarioLogadoId);
                return CreatedAtAction(nameof(ObterPorId), new { id = ticket.Id }, ticket);
            }
            catch (ArgumentException ex)
            {
                return BadRequest(new { mensagem = ex.Message });
            }
        }

        /// <summary>PUT /api/tickets/{id} — atualiza status, responsável ou progresso.</summary>
        [HttpPut("{id:int}")]
        public async Task<IActionResult> Atualizar(int id, [FromBody] AtualizarTicketDto dto)
        {
            try
            {
                var ticket = await _ticketService.AtualizarAsync(id, dto);
                return ticket is null ? NotFound() : Ok(ticket);
            }
            catch (ArgumentException ex)
            {
                return BadRequest(new { mensagem = ex.Message });
            }
        }

        /// <summary>DELETE /api/tickets/{id} — somente Admin.</summary>
        [HttpDelete("{id:int}")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> Deletar(int id)
        {
            var removido = await _ticketService.DeletarAsync(id);
            return removido ? NoContent() : NotFound();
        }
    }
}
