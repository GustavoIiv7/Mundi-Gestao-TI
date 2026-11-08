import 'package:flutter/material.dart';

enum AreaGestao { redes, bancoDados, acessos, sistemas }

extension AreaGestaoX on AreaGestao {
  /// Nome usado dentro do portal.
  String get rotulo => switch (this) {
        AreaGestao.redes => 'Gestão de Redes',
        AreaGestao.bancoDados => 'Gestão de Banco de Dados',
        AreaGestao.acessos => 'Gestão de Acessos',
        AreaGestao.sistemas => 'Gestão de Sistemas',
      };

  /// Título exibido no cartão da tela de seleção de área.
  String get tituloCartao => switch (this) {
        AreaGestao.redes => 'GESTÃO DE REDES',
        AreaGestao.bancoDados => 'GESTÃO BANCO DE DADOS',
        AreaGestao.acessos => 'GESTÃO DE ACESSOS',
        AreaGestao.sistemas => 'GESTÃO DE SISTEMAS',
      };

  IconData get icone => switch (this) {
        AreaGestao.redes => Icons.lan_outlined,
        AreaGestao.bancoDados => Icons.storage_outlined,
        AreaGestao.acessos => Icons.shield_outlined,
        AreaGestao.sistemas => Icons.dns_outlined,
      };

  String get imagem => switch (this) {
        AreaGestao.redes =>
          'https://images.unsplash.com/photo-1558494949-ef010cbdcc31?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080',
        AreaGestao.bancoDados =>
          'https://images.unsplash.com/photo-1597852074816-d933c7d2b988?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080',
        AreaGestao.acessos =>
          'https://images.unsplash.com/photo-1769704653651-2d09b1e6e60e?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080',
        AreaGestao.sistemas =>
          'https://images.unsplash.com/photo-1762279389083-abf71f22d338?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080',
      };
}
