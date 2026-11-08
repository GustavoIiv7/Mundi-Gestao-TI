/// Autenticação de exemplo (somente para a demonstração do app).
///
/// Na integração com o back-end, o método [entrar] vira uma chamada
/// POST /api/auth/login e a senha deixa de existir dentro do app.
class AuthService {
  // login (primeiro.segundo nome) -> nome completo
  static const Map<String, String> _usuarios = {
    'rafael.souza': 'Rafael Souza Rosendo',
    'isabela.aparecida': 'Isabela Aparecida Barbosa Bueno',
    'gustavo.de': 'Gustavo de Oliveira',
    'anderson.souza': 'Anderson Souza da Silva',
  };

  static const String _senhaDemo = 'senha123';

  /// Retorna o nome do usuário se as credenciais forem válidas, ou null.
  Future<String?> entrar(String login, String senha) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final nome = _usuarios[login.toLowerCase()];
    if (nome != null && senha == _senhaDemo) return nome;
    return null;
  }
}

final AuthService authService = AuthService();
