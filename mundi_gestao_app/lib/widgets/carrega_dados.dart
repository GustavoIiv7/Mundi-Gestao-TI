import 'package:flutter/material.dart';

import '../data/api_client.dart';
import '../tema.dart';

/// Carrega dados assíncronos e mostra: carregando, erro (com "Tentar novamente") ou o conteúdo.
class CarregaDados<T> extends StatefulWidget {
  const CarregaDados({super.key, required this.carregar, required this.construir});

  final Future<T> Function() carregar;
  final Widget Function(BuildContext context, T dados) construir;

  @override
  State<CarregaDados<T>> createState() => _CarregaDadosState<T>();
}

class _CarregaDadosState<T> extends State<CarregaDados<T>> {
  late Future<T> _futuro;

  @override
  void initState() {
    super.initState();
    _futuro = widget.carregar();
  }

  void _recarregar() => setState(() => _futuro = widget.carregar());

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: _futuro,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snap.hasError) {
          final e = snap.error;
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Text(
                  e is ApiException ? e.mensagem : 'Erro inesperado.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Cores.vermelho, fontSize: 14),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: _recarregar,
                  child: const Text('Tentar novamente'),
                ),
              ],
            ),
          );
        }
        return widget.construir(context, snap.data as T);
      },
    );
  }
}
