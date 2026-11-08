import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Endereço da API.
/// - Chrome / Windows / Web: http://localhost:5157
/// - Emulador Android: http://10.0.2.2:5157
/// - Outro endereço (celular físico, servidor): flutter run --dart-define=API_URL=http://192.168.0.10:5157
class ApiConfig {
  static String get baseUrl {
    const definido = String.fromEnvironment('API_URL');
    if (definido.isNotEmpty) return definido;
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:5157';
    }
    return 'http://localhost:5157';
  }
}

class ApiException implements Exception {
  ApiException(this.mensagem, {this.status});

  final String mensagem;
  final int? status;

  @override
  String toString() => mensagem;
}

/// Cliente HTTP único do app: guarda o token JWT e traduz erros da API.
class ApiClient {
  String? token;

  /// Chamado quando a API responde 401 numa rota autenticada (token vencido).
  VoidCallback? aoExpirarSessao;

  Uri _uri(String caminho, Map<String, String>? query) {
    final base = Uri.parse(ApiConfig.baseUrl);
    return base.replace(path: caminho, queryParameters: query);
  }

  Map<String, String> _cabecalhos(bool autenticado) => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (autenticado && token != null) 'Authorization': 'Bearer $token',
      };

  Future<dynamic> get(String caminho, {Map<String, String>? query}) =>
      _enviar(() => http.get(_uri(caminho, query), headers: _cabecalhos(true)),
          autenticado: true);

  Future<dynamic> put(String caminho, Object? corpo) => _enviar(
      () => http.put(_uri(caminho, null),
          headers: _cabecalhos(true), body: jsonEncode(corpo)),
      autenticado: true);

  Future<dynamic> delete(String caminho) => _enviar(
      () => http.delete(_uri(caminho, null), headers: _cabecalhos(true)),
      autenticado: true);

  Future<dynamic> post(String caminho, Object? corpo,
          {bool autenticado = true}) =>
      _enviar(
          () => http.post(_uri(caminho, null),
              headers: _cabecalhos(autenticado), body: jsonEncode(corpo)),
          autenticado: autenticado);

  Future<dynamic> _enviar(Future<http.Response> Function() chamada,
      {required bool autenticado}) async {
    final http.Response resposta;
    try {
      resposta = await chamada().timeout(const Duration(seconds: 15));
    } catch (_) {
      throw ApiException(
          'Não foi possível conectar ao servidor. Verifique se a API está rodando.');
    }

    final corpo = utf8.decode(resposta.bodyBytes);
    final status = resposta.statusCode;

    if (status >= 200 && status < 300) {
      return corpo.isEmpty ? null : jsonDecode(corpo);
    }

    if (status == 401 && autenticado) {
      token = null;
      aoExpirarSessao?.call();
      throw ApiException('Sessão expirada. Entre novamente.', status: status);
    }

    throw ApiException(_mensagemDeErro(corpo, status), status: status);
  }

  String _mensagemDeErro(String corpo, int status) {
    try {
      final json = jsonDecode(corpo);
      if (json is Map<String, dynamic>) {
        if (json['mensagem'] is String) return json['mensagem'] as String;
        final erros = json['errors'];
        if (erros is Map && erros.isNotEmpty) {
          final primeiro = erros.values.first;
          if (primeiro is List && primeiro.isNotEmpty) {
            return primeiro.first.toString();
          }
        }
        if (json['title'] is String) return json['title'] as String;
      }
    } catch (_) {}
    if (status == 403) return 'Você não tem permissão para esta ação.';
    if (status == 404) return 'Não encontrado.';
    return 'Erro no servidor ($status).';
  }
}

final ApiClient api = ApiClient();
