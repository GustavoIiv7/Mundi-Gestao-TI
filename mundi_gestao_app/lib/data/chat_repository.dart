import '../models/area.dart';
import '../models/chamado.dart';
import '../models/dados_gestao.dart';
import 'api_client.dart';
import 'auth_service.dart';
import 'mapeamentos.dart';

class ChatMensagem {
  const ChatMensagem(this.texto, this.minha, this.hora);

  final String texto;
  final bool minha;
  final String hora;
}

abstract class ChatRepository {
  Future<List<ChatMensagem>> listar(AreaGestao area);

  Future<void> enviar(AreaGestao area, String texto);

  Future<String> nomeContato(AreaGestao area);
}

/// Chat real: conversa com o contato da área via API (/api/usuarios/contato e /api/mensagens).
class ApiChatRepository implements ChatRepository {
  final Map<AreaGestao, Map<String, dynamic>> _contatos = {};

  Future<Map<String, dynamic>> _contato(AreaGestao area) async {
    final cache = _contatos[area];
    if (cache != null) return cache;
    final c = await api.get('/api/usuarios/contato/${area.chaveApi}')
        as Map<String, dynamic>;
    return _contatos[area] = c;
  }

  @override
  Future<String> nomeContato(AreaGestao area) async =>
      (await _contato(area))['nome'] as String;

  @override
  Future<List<ChatMensagem>> listar(AreaGestao area) async {
    final id = (await _contato(area))['id'] as int;
    final meuId = authService.sessao?.usuarioId;
    final lista = await api.get('/api/mensagens/conversa/$id') as List;
    return lista.cast<Map<String, dynamic>>().map((m) {
      return ChatMensagem(
        m['conteudo'] as String,
        m['remetenteId'] == meuId,
        formatarHora(dataLocal(m['enviadaEm'] as String)),
      );
    }).toList();
  }

  @override
  Future<void> enviar(AreaGestao area, String texto) async {
    final id = (await _contato(area))['id'] as int;
    await api.post('/api/mensagens', {'conteudo': texto, 'destinatarioId': id});
  }
}

/// Chat interno simulado (em memória), com as mesmas mensagens do portal web.
class MockChatRepository implements ChatRepository {
  final Map<AreaGestao, List<ChatMensagem>> _mensagens = {};

  List<ChatMensagem> _lista(AreaGestao area) {
    return _mensagens.putIfAbsent(area, () {
      final c = dadosDaArea(area).contato;
      return <ChatMensagem>[
        ChatMensagem(c.msg1, false, '14:25'),
        const ChatMensagem('Claro! Qual o problema específico?', true, '14:27'),
        ChatMensagem(c.msg2, false, '14:28'),
      ];
    });
  }

  @override
  Future<List<ChatMensagem>> listar(AreaGestao area) async {
    return List<ChatMensagem>.of(_lista(area));
  }

  @override
  Future<String> nomeContato(AreaGestao area) async => dadosDaArea(area).contato.nome;

  @override
  Future<void> enviar(AreaGestao area, String texto) async {
    _lista(area).add(ChatMensagem(texto, true, formatarHora(DateTime.now())));
  }
}

final ChatRepository chatRepository = ApiChatRepository();
