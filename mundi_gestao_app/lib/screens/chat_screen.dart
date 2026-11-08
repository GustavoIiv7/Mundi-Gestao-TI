import 'package:flutter/material.dart';

import '../data/api_client.dart';
import '../data/chat_repository.dart';
import '../models/area.dart';
import '../tema.dart';
import '../widgets/componentes.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.area});

  final AreaGestao area;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controle = TextEditingController();
  final _rolagem = ScrollController();
  List<ChatMensagem> _mensagens = [];
  String _nomeContato = '';

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  @override
  void dispose() {
    _controle.dispose();
    _rolagem.dispose();
    super.dispose();
  }

  void _aviso(String texto) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

  Future<void> _carregar() async {
    final List<ChatMensagem> lista;
    final String nome;
    try {
      nome = await chatRepository.nomeContato(widget.area);
      lista = await chatRepository.listar(widget.area);
    } on ApiException catch (e) {
      _aviso(e.mensagem);
      return;
    }
    if (!mounted) return;
    setState(() {
      _nomeContato = nome;
      _mensagens = lista;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_rolagem.hasClients) {
        _rolagem.jumpTo(_rolagem.position.maxScrollExtent);
      }
    });
  }

  Future<void> _enviar() async {
    final texto = _controle.text.trim();
    if (texto.isEmpty) return;
    _controle.clear();
    try {
      await chatRepository.enviar(widget.area, texto);
    } on ApiException catch (e) {
      _aviso(e.mensagem);
      return;
    }
    await _carregar();
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
              child: ColunaCentral(
                largura: 700,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Cores.borda),
                      boxShadow: sombraCartao,
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'CHAMADOS INTERNOS',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: Cores.titulo,
                            letterSpacing: 0.4,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFFF8FAFC), Color(0xFFF1F5F9)],
                            ),
                            border: Border.all(color: Cores.borda, width: 2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Container(
                                width: 54,
                                height: 54,
                                decoration: BoxDecoration(
                                  gradient: gradienteAzul,
                                  shape: BoxShape.circle,
                                  border:
                                      Border.all(color: Colors.white, width: 3),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x4D2563EB),
                                      blurRadius: 6,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Icon(Icons.person_outline,
                                    color: Colors.white, size: 28),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _nomeContato,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Cores.titulo,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDCFCE7),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: const Text(
                                  'Online',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Cores.verde,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Cores.fundoCartao,
                              border: Border.all(color: Cores.borda),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ListView.builder(
                              controller: _rolagem,
                              padding: const EdgeInsets.all(14),
                              itemCount: _mensagens.length,
                              itemBuilder: (context, i) =>
                                  _Balao(mensagem: _mensagens[i]),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _controle,
                                onSubmitted: (_) => _enviar(),
                                decoration:
                                    decoracaoCampo('Digite uma mensagem...'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: _enviar,
                              child: Container(
                                padding: const EdgeInsets.all(13),
                                decoration: BoxDecoration(
                                  gradient: gradienteAzul,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.send,
                                    color: Colors.white, size: 22),
                              ),
                            ),
                          ],
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

class _Balao extends StatelessWidget {
  const _Balao({required this.mensagem});

  final ChatMensagem mensagem;

  @override
  Widget build(BuildContext context) {
    final minha = mensagem.minha;
    return Align(
      alignment: minha ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 320),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          gradient: minha ? gradienteAzul : null,
          color: minha ? null : Colors.white,
          border: minha ? null : Border.all(color: Cores.borda),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              mensagem.texto,
              style: TextStyle(
                fontSize: 14,
                height: 1.4,
                color: minha ? Colors.white : Cores.texto,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              mensagem.hora,
              style: TextStyle(
                fontSize: 11,
                color: minha ? const Color(0xCCFFFFFF) : Cores.cinza,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
