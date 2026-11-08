import 'package:flutter/material.dart';

import '../data/api_client.dart';
import '../data/chamado_repository.dart';
import '../models/area.dart';
import '../models/chamado.dart';
import '../tema.dart';
import '../widgets/componentes.dart';

class NovaRequisicaoScreen extends StatefulWidget {
  const NovaRequisicaoScreen({
    super.key,
    required this.area,
    required this.usuario,
  });

  final AreaGestao area;
  final String usuario;

  @override
  State<NovaRequisicaoScreen> createState() => _NovaRequisicaoScreenState();
}

class _NovaRequisicaoScreenState extends State<NovaRequisicaoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titulo = TextEditingController();
  final _descricao = TextEditingController();
  Prioridade _prioridade = Prioridade.normal;
  bool _salvando = false;

  @override
  void dispose() {
    _titulo.dispose();
    _descricao.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _salvando = true);
    try {
      await chamadoRepository.criar(
        area: widget.area,
        titulo: _titulo.text.trim(),
        descricao: _descricao.text.trim(),
        prioridade: _prioridade,
        solicitante: widget.usuario,
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _salvando = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.mensagem)));
      return;
    }
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  Widget _rotulo(String texto) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          texto,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Cores.textoSuave,
            letterSpacing: 0.6,
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
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
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Cores.borda),
                        boxShadow: sombraCartao,
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'NOVA REQUISIÇÃO',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Cores.titulo,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.area.rotulo.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Cores.cinza,
                                letterSpacing: 0.6,
                              ),
                            ),
                            const SizedBox(height: 24),
                            _rotulo('TÍTULO'),
                            TextFormField(
                              controller: _titulo,
                              decoration: decoracaoCampo('Resuma o problema'),
                              validator: (v) =>
                                  (v == null || v.trim().length < 5)
                                      ? 'Informe um título com pelo menos 5 caracteres.'
                                      : null,
                            ),
                            const SizedBox(height: 20),
                            _rotulo('DESCRIÇÃO'),
                            TextFormField(
                              controller: _descricao,
                              minLines: 4,
                              maxLines: 6,
                              decoration:
                                  decoracaoCampo('Descreva a solicitação'),
                              validator: (v) =>
                                  (v == null || v.trim().isEmpty)
                                      ? 'Descreva o problema ou a solicitação.'
                                      : null,
                            ),
                            const SizedBox(height: 20),
                            _rotulo('PRIORIDADE'),
                            GradeColunas(
                              colunas: 2,
                              filhos: [
                                for (final p in Prioridade.values)
                                  BotaoPrioridade(
                                    prioridade: p,
                                    destaque: _prioridade == p,
                                    onTap: () =>
                                        setState(() => _prioridade = p),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 28),
                            BotaoGradiente(
                              texto:
                                  _salvando ? 'ENVIANDO...' : 'CRIAR REQUISIÇÃO',
                              onPressed: _salvando ? null : _salvar,
                            ),
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
