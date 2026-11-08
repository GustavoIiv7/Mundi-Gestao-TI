import '../models/area.dart';
import 'api_client.dart';
import 'mapeamentos.dart';

class Sessao {
  const Sessao({
    required this.usuarioId,
    required this.nome,
    required this.area,
    required this.perfil,
  });

  final int usuarioId;
  final String nome;
  final AreaGestao area;
  final String perfil;

  bool get admin => perfil == 'Admin';
}

/// Login real na API (POST /api/auth/login). O token JWT fica só em memória.
class AuthService {
  Sessao? sessao;

  /// Retorna o nome completo do usuário, ou null se login/senha estiverem errados.
  /// Lança [ApiException] se a API estiver fora do ar.
  Future<String?> entrar(String login, String senha) async {
    try {
      final json = await api.post(
        '/api/auth/login',
        {'login': login.trim().toLowerCase(), 'senha': senha},
        autenticado: false,
      ) as Map<String, dynamic>;

      api.token = json['token'] as String;
      sessao = Sessao(
        usuarioId: json['usuarioId'] as int,
        nome: json['nome'] as String,
        area: areaDeApi(json['area'] as String),
        perfil: json['perfil'] as String,
      );
      return sessao!.nome;
    } on ApiException catch (e) {
      if (e.status == 400 || e.status == 401) return null;
      rethrow;
    }
  }

  void sair() {
    sessao = null;
    api.token = null;
  }
}

final AuthService authService = AuthService();
