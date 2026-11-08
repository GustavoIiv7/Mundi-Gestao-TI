import 'package:flutter/material.dart';
import '../data/chamado_repository.dart';
import '../models/chamado.dart';

class NovaRequisicaoScreen extends StatefulWidget {
  final String usuario;

  const NovaRequisicaoScreen({super.key, required this.usuario});

  @override
  State<NovaRequisicaoScreen> createState() => _NovaRequisicaoScreenState();
}

class _NovaRequisicaoScreenState extends State<NovaRequisicaoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tituloCtrl = TextEditingController();
  final _descricaoCtrl = TextEditingController();
  Prioridade _prioridade = Prioridade.normal;
  bool _salvando = false;

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _descricaoCtrl.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _salvando = true);

    await chamadoRepository.criar(
      titulo: _tituloCtrl.text.trim(),
      descricao: _descricaoCtrl.text.trim(),
      prioridade: _prioridade,
      solicitante: widget.usuario,
    );
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nova requisição')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _tituloCtrl,
                enabled: !_salvando,
                decoration: const InputDecoration(
                  labelText: 'Título',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Informe o título.' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descricaoCtrl,
                enabled: !_salvando,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Descrição do serviço',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Descreva o problema.'
                    : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<Prioridade>(
                initialValue: _prioridade,
                decoration: const InputDecoration(
                  labelText: 'Prioridade',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                items: [
                  for (final p in Prioridade.values)
                    DropdownMenuItem(value: p, child: Text(p.rotulo)),
                ],
                onChanged: _salvando
                    ? null
                    : (v) {
                        if (v != null) setState(() => _prioridade = v);
                      },
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _salvando ? null : _enviar,
                child: _salvando
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('ENVIAR REQUISIÇÃO'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
