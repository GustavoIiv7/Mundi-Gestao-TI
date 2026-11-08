using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MundiGestaoTI.Models;
using MundiGestaoTI.Services;

namespace MundiGestaoTI.Controllers
{
    /// <summary>Abas Dashboard, Monitoramento e Relatório de cada área de gestão.</summary>
    [ApiController]
    [Route("api/areas/{area}")]
    [Authorize]
    public class AreasController : ControllerBase
    {
        private readonly IAreaService _areaService;

        public AreasController(IAreaService areaService)
        {
            _areaService = areaService;
        }

        /// <summary>GET /api/areas/redes/dashboard — indicadores dos últimos 30 dias.</summary>
        [HttpGet("dashboard")]
        public async Task<IActionResult> Dashboard(string area)
        {
            if (!ConversorEnum.Tentar<AreaGestao>(area, out var a))
                return BadRequest(new { mensagem = $"Área inválida: {area}" });

            return Ok(await _areaService.DashboardAsync(a));
        }

        /// <summary>GET /api/areas/redes/monitoramento — chamados abertos/em andamento com progresso.</summary>
        [HttpGet("monitoramento")]
        public async Task<IActionResult> Monitoramento(string area)
        {
            if (!ConversorEnum.Tentar<AreaGestao>(area, out var a))
                return BadRequest(new { mensagem = $"Área inválida: {area}" });

            return Ok(await _areaService.MonitoramentoAsync(a));
        }

        /// <summary>GET /api/areas/redes/relatorio?limite=5 — últimos chamados concluídos.</summary>
        [HttpGet("relatorio")]
        public async Task<IActionResult> Relatorio(string area, [FromQuery] int limite = 5)
        {
            if (!ConversorEnum.Tentar<AreaGestao>(area, out var a))
                return BadRequest(new { mensagem = $"Área inválida: {area}" });

            return Ok(await _areaService.RelatorioAsync(a, limite));
        }
    }
}
