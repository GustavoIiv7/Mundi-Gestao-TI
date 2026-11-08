import 'package:flutter/material.dart';

import '../data/api_client.dart';
import '../data/auth_service.dart';
import '../data/chamado_repository.dart';
import '../models/area.dart';
import '../models/chamado.dart';
import '../tema.dart';
import '../widgets/componentes.dart';

class DetalheChamadoScreen extends StatefulWidget {
  const DetalheChamadoScreen({super.key, required this.chamado});

  final Chamado chamado;

  @override
  State<DetalheChamadoScreen> createState() => _DetalheChamadoScreenState();
}

class _DetalheChamadoScreenState extends State<DetalheChamadoScreen> {
  late Chamado _c;
  late double _progresso;
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    _c = widget.chamado;
    _progresso = _c.progresso.toDouble();
  }

  /// Admin edita qualquer chamado; analista, apenas os da própria área.
  bool get _podeEditar {
    final s = authService.sessao;
    return s != null && (s.admin || s.area == _c.area);
  }

  bool get _souResponsavel =>
      _c.responsavelId != null &&
      _c.responsavelId == authService.sessao?.usuarioId;

  void _aviso(String texto) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

  Future<void> _executar(Future<Chamado> Function() acao, String sucesso) async {
    if (_salvando) return;
    setState(() => _salvando = true);
    try {
      final novo = await acao();
      if (!mounted) return;
      setState(() {
        _c = novo;
        _progresso = novo.progresso.toDouble();
        _salvando = false;
      });
      _aviso(sucesso);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _salvando = false;
        _progresso = _c.progresso.toDouble();
      });
      _aviso(e.mensagem);
    }
  }

  Future<void> _resolver() async {
    if (_salvando) return;
    setState(() => _salvando = true);
    final mensagens = ScaffoldMessenger.of(context);
    final navegador = Navigator.of(context);
    try {
      await chamadoRepository.resolver(_c.id);
      mensagens.showSnackBar(
        const SnackBar(content: Text('Chamado resolvido. Veja-o na aba Relatório.')),
      );
      navegador.pop(true);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _salvando = false);
      _aviso(e.mensagem);
    }
  }

  Future<void> _excluir() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir chamado?'),
        content: const Text('Esta ação remove o chamado definitivamente.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmar != true || !mounted) return;

    setState(() => _salvando = true);
    final mensagens = ScaffoldMessenger.of(context);
    final navegador = Navigator.of(context);
    try {
      await chamadoRepository.excluir(_c.id);
      mensagens.showSnackBar(const SnackBar(content: Text('Chamado excluído.')));
      navegador.pop(true);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _salvando = false);
      _aviso(e.mensagem);
    }
  }

  Widget _linha(String rotulo, Widget valor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              rotulo,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Cores.textoSuave,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Expanded(child: valor),
        ],
      ),
    );
  }

  Widget _acoes() {
    if (!_podeEditar) {
      return const Padding(
        padding: EdgeInsets.only(top: 8),
        child: Text(
          'Somente leitura: este chamado é de outra área.',
          style: TextStyle(fontSize: 13, color: Cores.cinza),
        ),
      );
    }

    const tituloSecao = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w700,
      color: Cores.textoSuave,
      letterSpacing: 0.5,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 28, color: Cores.borda),
        const Text('GERENCIAR CHAMADO', style: tituloSecao),
        const SizedBox(height: 14),
        const Text('Status', style: TextStyle(fontSize: 13, color: Cores.texto)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final s in StatusChamado.values)
              ChoiceChip(
                label: Text(s.rotulo),
                selected: _c.status == s,
                onSelected: _salvando || _c.status == s
                    ? null
                    : (_) => _executar(
                          () => chamadoRepository.alterarStatus(_c.id, s),
                          'Status atualizado.',
                        ),
              ),
          ],
        ),
        const SizedBox(height: 18),
        Text('Progresso: ${_progresso.round()}%',
            style: const TextStyle(fontSize: 13, color: Cores.texto)),
        Slider(
          value: _progresso,
          min: 0,
          max: 100,
          divisions: 20,
          label: '${_progresso.round()}%',
          onChanged: _salvando ? null : (v) => setState(() => _progresso = v),
          onChangeEnd: _salvando
              ? null
              : (v) => _executar(
                    () => chamadoRepository.atualizarProgresso(_c.id, v.round()),
                    'Progresso atualizado.',
                  ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            if (!_souResponsavel)
              BotaoGradiente(
                texto: 'ASSUMIR CHAMADO',
                icone: Icons.person_add_alt,
                compacto: true,
                onPressed: _salvando
                    ? null
                    : () => _executar(
                          () => chamadoRepository.assumir(_c.id),
                          'Você assumiu este chamado.',
                        ),
              ),
            OutlinedButton.icon(
              onPressed: _salvando ? null : _resolver,
              icon: const Icon(Icons.check_circle_outline, size: 18),
              label: const Text('RESOLVER'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Cores.verde,
                side: const BorderSide(color: Cores.verde, width: 1.5),
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
        if (authService.sessao?.admin ?? false) ...[
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: _salvando ? null : _excluir,
            icon: const Icon(Icons.delete_outline, size: 18),
            label: const Text('EXCLUIR CHAMADO (ADMIN)'),
            style: TextButton.styleFrom(foregroundColor: Cores.vermelho),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = _c;
    const estiloValor = TextStyle(fontSize: 14, color: Cores.texto);
    return Scaffold(
      body: FundoGradiente(
        child: Column(
          children: [
            BarraNav(
              esquerda: [
                BotaoNav(
                  icone: Icons.arrow_back,
                  tooltip: 'Voltar',
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                child: ColunaCentral(
                  largura: 700,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: CartaoLateral(
                      cor: estiloDe(c.prioridade).barra,
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              c.titulo,
                              style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w700,
                                color: Cores.titulo,
                              ),
                            ),
                            const SizedBox(height: 12),
                            BadgePrioridade(c.prioridade),
                            const SizedBox(height: 20),
                            _linha(
                              'STATUS',
                              Row(
                                children: [
                                  PontoStatus(corStatus(c.status)),
                                  const SizedBox(width: 8),
                                  Text(c.status.rotulo, style: estiloValor),
                                ],
                              ),
                            ),
                            _linha('ÁREA', Text(c.area.rotulo, style: estiloValor)),
                            _linha('ABERTURA',
                                Text('${c.data} às ${c.hora}', style: estiloValor)),
                            if (c.solicitante != null)
                              _linha('SOLICITANTE',
                                  Text(c.solicitante!, style: estiloValor)),
                            _linha(
                              'RESPONSÁVEL',
                              Text(c.responsavel ?? 'Não atribuído',
                                  style: estiloValor),
                            ),
                            _linha(
                              'PROGRESSO',
                              Row(
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: c.progresso / 100,
                                        minHeight: 8,
                                        backgroundColor: Cores.borda,
                                        color: Cores.azul,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text('${c.progresso}%', style: estiloValor),
                                ],
                              ),
                            ),
                            _linha(
                              'DESCRIÇÃO',
                              Text(
                                (c.descricao == null || c.descricao!.isEmpty)
                                    ? 'Sem descrição informada.'
                                    : c.descricao!,
                                style: estiloValor,
                              ),
                            ),
                            _acoes(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
