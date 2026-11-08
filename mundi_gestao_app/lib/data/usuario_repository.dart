import '../models/area.dart';
import 'api_client.dart';
import 'mapeamentos.dart';

class UsuarioResumo {
  const UsuarioResumo({
    required this.id,
    required this.nome,
    required this.area,
    required this.perfil,
  });

  final int id;
  final String nome;
  final AreaGestao area;
  final String perfil;

  bool get admin => perfil == 'Admin';
}

/// Cadastro e consulta de usuários (o cadastro é restrito ao perfil Admin na API).
class UsuarioRepository {
  UsuarioResumo _paraUsuario(Map<String, dynamic> j) => UsuarioResumo(
        id: j['id'] as int,
        nome: j['nome'] as String,
        area: areaDeApi(j['area'] as String),
        perfil: j['perfil'] as String,
      );

  Future<List<UsuarioResumo>> listar() async {
    final lista = await api.get('/api/usuarios') as List;
    return lista.cast<Map<String, dynamic>>().map(_paraUsuario).toList();
  }

  Future<UsuarioResumo> criar({
    required String login,
    required String senha,
    required String nome,
    required AreaGestao area,
    required String perfil,
  }) async {
    final json = await api.post('/api/auth/cadastrar', {
      'login': login.trim().toLowerCase(),
      'senha': senha,
      'nome': nome.trim(),
      'area': area.chaveApi,
      'perfil': perfil,
    }) as Map<String, dynamic>;
    return _paraUsuario(json);
  }
}

final UsuarioRepository usuarioRepository = UsuarioRepository();
