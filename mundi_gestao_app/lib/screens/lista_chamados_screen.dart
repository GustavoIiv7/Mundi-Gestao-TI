import 'package:flutter/material.dart';
import '../data/chamado_repository.dart';
import '../models/chamado.dart';
import '../widgets/priority_badge.dart';
import 'detalhe_chamado_screen.dart';
import 'login_screen.dart';
import 'nova_requisicao_screen.dart';

class ListaChamadosScreen extends StatefulWidget {
  final String usuario;

  const ListaChamadosScreen({super.key, required this.usuario});

  @override
  State<ListaChamadosScreen> createState() => _ListaChamadosScreenState();
}

class _ListaChamadosScreenState extends State<ListaChamadosScreen> {
  List<Chamado> _todos = [];
  bool _carregando = true;
  Prioridade? _filtro;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() => _carregando = true);
    final lista = await chamadoRepository.listar();
    if (!mounted) return;
    setState(() {
      _todos = lista;
      _carregando = false;
    });
  }

  /// Aplica o filtro e ordena: mais urgentes primeiro, depois os mais recentes.
  List<Chamado> get _visiveis {
    final lista = _filtro == null
        ? [..._todos]
        : _todos.where((c) => c.prioridade == _filtro).toList();
    lista.sort((a, b) {
      final porPrioridade = a.prioridade.index.compareTo(b.prioridade.index);
      if (porPrioridade != 0) return porPrioridade;
      return b.dataAbertura.compareTo(a.dataAbertura);
    });
    return lista;
  }

  void _sair() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  Future<void> _novaRequisicao() async {
    final criado = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => NovaRequisicaoScreen(usuario: widget.usuario),
      ),
    );
    if (criado == true && mounted) {
      await _carregar();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Requisição criada com sucesso.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mundi Gestão TI'),
        actions: [
          IconButton(
            tooltip: 'Sair do sistema',
            icon: const Icon(Icons.logout),
            onPressed: _sair,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _novaRequisicao,
        icon: const Icon(Icons.add),
        label: const Text('Nova requisição'),
      ),
      body: Column(
        children: [
          _cabecalhoUsuario(),
          _resumo(),
          _filtros(),
          Expanded(
            child: _carregando
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(onRefresh: _carregar, child: _lista()),
          ),
        ],
      ),
    );
  }

  Widget _cabecalhoUsuario() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        'USUÁRIO: ${widget.usuario}',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _resumo() {
    final total = _todos.length;
    final urgentes =
        _todos.where((c) => c.prioridade == Prioridade.urgente).length;
    final resolvidos =
        _todos.where((c) => c.status == StatusChamado.resolvido).length;

    Widget cartao(String rotulo, int valor, Color cor) {
      return Expanded(
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              children: [
                Text(
                  '$valor',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: cor,
                  ),
                ),
                Text(rotulo, style: const TextStyle(fontSize: 11)),
              ],
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          cartao('Chamados', total, const Color(0xFF1D4ED8)),
          cartao('Urgentes', urgentes, const Color(0xFFDC2626)),
          cartao('Resolvidos', resolvidos, const Color(0xFF16A34A)),
        ],
      ),
    );
  }

  Widget _filtros() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Wrap(
        spacing: 8,
        children: [
          for (final p in Prioridade.values)
            FilterChip(
              label: Text(p.rotulo),
              selected: _filtro == p,
              // Tocar de novo no filtro ativo desativa o filtro.
              onSelected: (selecionado) =>
                  setState(() => _filtro = selecionado ? p : null),
            ),
        ],
      ),
    );
  }

  Widget _lista() {
    final itens = _visiveis;
    if (itens.isEmpty) {
      return ListView(
        children: const [
          SizedBox(height: 120),
          Center(child: Text('Nenhum chamado encontrado.')),
        ],
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 88),
      itemCount: itens.length,
      itemBuilder: (context, i) => _card(itens[i]),
    );
  }

  Widget _card(Chamado c) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => DetalheChamadoScreen(chamado: c),
          ),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 5, color: corPrioridade(c.prioridade)),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        c.titulo,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          PriorityBadge(prioridade: c.prioridade),
                          const SizedBox(width: 10),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: corStatus(c.status),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              '${c.status.rotulo} · ${formatarDataHora(c.dataAbertura)}',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
