import 'package:flutter/material.dart';

import '../data/api_client.dart';
import '../data/usuario_repository.dart';
import '../models/area.dart';
import '../tema.dart';
import '../widgets/carrega_dados.dart';
import '../widgets/componentes.dart';

/// Área administrativa (somente Admin): consulta e cadastro de usuários.
class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  int _versao = 0;

  Future<void> _novo() async {
    final criado = await showDialog<bool>(
      context: context,
      builder: (_) => const _NovoUsuarioDialog(),
    );
    if (criado == true && mounted) {
      setState(() => _versao++);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuário cadastrado com sucesso.')),
      );
    }
  }

  Widget _cartao(UsuarioResumo u) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: CartaoLateral(
        cor: u.admin ? Cores.azul : Cores.cinza,
        child: Row(
          children: [
            Icon(u.area.icone, size: 22, color: Cores.azul),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(u.nome,
                      style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          color: Cores.titulo)),
                  const SizedBox(height: 4),
                  Text(u.area.rotulo,
                      style:
                          const TextStyle(fontSize: 13, color: Cores.textoSuave)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: u.admin ? Cores.azulClaro : Cores.fundoCartao,
                border: Border.all(
                    color: u.admin ? const Color(0xFFBFDBFE) : Cores.borda),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                u.perfil.toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: u.admin ? Cores.azul : Cores.cinza,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'ADMINISTRAÇÃO DE USUÁRIOS',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Cores.titulo,
                            letterSpacing: 0.6,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Align(
                          alignment: Alignment.centerRight,
                          child: BotaoGradiente(
                            texto: 'NOVO USUÁRIO',
                            icone: Icons.person_add_alt,
                            compacto: true,
                            onPressed: _novo,
                          ),
                        ),
                        const SizedBox(height: 16),
                        CarregaDados<List<UsuarioResumo>>(
                          key: ValueKey(_versao),
                          carregar: usuarioRepository.listar,
                          construir: (context, lista) =>
                              Column(children: [for (final u in lista) _cartao(u)]),
                        ),
                      ],
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

class _NovoUsuarioDialog extends StatefulWidget {
  const _NovoUsuarioDialog();

  @override
  State<_NovoUsuarioDialog> createState() => _NovoUsuarioDialogState();
}

class _NovoUsuarioDialogState extends State<_NovoUsuarioDialog> {
  final _form = GlobalKey<FormState>();
  final _nome = TextEditingController();
  final _login = TextEditingController();
  final _senha = TextEditingController();
  AreaGestao _area = AreaGestao.redes;
  String _perfil = 'Analista';
  bool _salvando = false;
  String? _erro;

  @override
  void dispose() {
    _nome.dispose();
    _login.dispose();
    _senha.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _salvando = true;
      _erro = null;
    });
    try {
      await usuarioRepository.criar(
        login: _login.text,
        senha: _senha.text,
        nome: _nome.text,
        area: _area,
        perfil: _perfil,
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _salvando = false;
        _erro = e.mensagem;
      });
    }
  }

  Widget _rotulo(String texto) => Padding(
        padding: const EdgeInsets.only(top: 14, bottom: 8),
        child: Text(
          texto,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Cores.textoSuave,
            letterSpacing: 0.6,
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Novo usuário'),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Form(
            key: _form,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _rotulo('NOME COMPLETO'),
                TextFormField(
                  controller: _nome,
                  decoration: decoracaoCampo('Nome do funcionário'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Informe o nome.' : null,
                ),
                _rotulo('LOGIN'),
                TextFormField(
                  controller: _login,
                  decoration: decoracaoCampo('ex.: nome.sobrenome'),
                  validator: (v) => (v == null || v.trim().length < 3)
                      ? 'Mínimo de 3 caracteres.'
                      : null,
                ),
                _rotulo('SENHA'),
                TextFormField(
                  controller: _senha,
                  obscureText: true,
                  decoration: decoracaoCampo('Mínimo de 6 caracteres'),
                  validator: (v) => (v == null || v.length < 6)
                      ? 'Mínimo de 6 caracteres.'
                      : null,
                ),
                _rotulo('ÁREA'),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final a in AreaGestao.values)
                      ChoiceChip(
                        label: Text(a.rotulo.replaceFirst('Gestão de ', '')),
                        selected: _area == a,
                        onSelected: (_) => setState(() => _area = a),
                      ),
                  ],
                ),
                _rotulo('PERFIL'),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final p in const ['Analista', 'Admin'])
                      ChoiceChip(
                        label: Text(p),
                        selected: _perfil == p,
                        onSelected: (_) => setState(() => _perfil = p),
                      ),
                  ],
                ),
                if (_erro != null) ...[
                  const SizedBox(height: 14),
                  Text(_erro!,
                      style:
                          const TextStyle(color: Cores.vermelho, fontSize: 13)),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _salvando ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _salvando ? null : _salvar,
          child: Text(_salvando ? 'Salvando...' : 'Cadastrar'),
        ),
      ],
    );
  }
}
