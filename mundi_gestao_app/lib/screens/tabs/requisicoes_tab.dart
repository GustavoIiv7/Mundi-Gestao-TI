import 'package:flutter/material.dart';

import '../../data/api_client.dart';
import '../../data/chamado_repository.dart';
import '../../models/area.dart';
import '../../models/chamado.dart';
import '../../tema.dart';
import '../../widgets/componentes.dart';
import '../detalhe_chamado_screen.dart';
import '../nova_requisicao_screen.dart';

class RequisicoesTab extends StatefulWidget {
  const RequisicoesTab({super.key, required this.area, required this.usuario});

  final AreaGestao area;
  final String usuario;

  @override
  State<RequisicoesTab> createState() => _RequisicoesTabState();
}

class _RequisicoesTabState extends State<RequisicoesTab> {
  List<Chamado>? _todos;
  Prioridade? _filtro;
  String? _erro;

  @override
  void initState() {
    super.initState();
    chamadosAlterados.addListener(_carregar);
    _carregar();
  }

  @override
  void dispose() {
    chamadosAlterados.removeListener(_carregar);
    super.dispose();
  }

  Future<void> _carregar() async {
    try {
      final lista = await chamadoRepository.listar(widget.area);
      if (!mounted) return;
      setState(() {
        _todos = lista;
        _erro = null;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _erro = e.mensagem);
    }
  }

  Future<void> _nova() async {
    final criada = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) =>
            NovaRequisicaoScreen(area: widget.area, usuario: widget.usuario),
      ),
    );
    if (criada == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Requisição criada com sucesso.')),
      );
    }
  }

  Widget _cartao(BuildContext context, Chamado c) {
    return CartaoLateral(
      cor: estiloDe(c.prioridade).barra,
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => DetalheChamadoScreen(chamado: c),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  c.titulo,
                  style: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w600,
                    color: Cores.titulo,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              BadgePrioridade(c.prioridade),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              PontoStatus(corStatus(c.status)),
              Text('Status: ${c.status.rotulo}', style: _meta),
              const Text('•', style: _sep),
              Text(c.data, style: _meta),
              const Text('•', style: _sep),
              Text(c.hora, style: _meta),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final todos = _todos;
    if (todos == null && _erro != null) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(_erro!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Cores.vermelho, fontSize: 14)),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () {
                setState(() => _erro = null);
                _carregar();
              },
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }
    if (todos == null) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final visiveis =
        todos.where((c) => _filtro == null || c.prioridade == _filtro).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: BotaoGradiente(
            texto: 'NOVA REQUISIÇÃO',
            icone: Icons.add,
            compacto: true,
            onPressed: _nova,
          ),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, c) => GradeColunas(
            colunas: c.maxWidth >= 520 ? 4 : 2,
            filhos: [
              for (final p in Prioridade.values)
                BotaoPrioridade(
                  prioridade: p,
                  destaque: _filtro == null || _filtro == p,
                  onTap: () =>
                      setState(() => _filtro = _filtro == p ? null : p),
                ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        if (visiveis.isEmpty)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Center(
              child: Text('Nenhuma requisição encontrada.',
                  style: TextStyle(color: Cores.cinza)),
            ),
          ),
        LayoutBuilder(
          builder: (context, caixa) {
            final duas = caixa.maxWidth >= 760;
            final largura = duas ? (caixa.maxWidth - 12) / 2 : caixa.maxWidth;
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final c in visiveis)
                  SizedBox(
                    width: largura,
                    child: _cartao(context, c),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

const TextStyle _meta = TextStyle(fontSize: 13, color: Cores.cinza);
const TextStyle _sep = TextStyle(fontSize: 13, color: Color(0xFFCBD5E1));
