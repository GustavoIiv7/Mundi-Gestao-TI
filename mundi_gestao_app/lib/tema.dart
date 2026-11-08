import 'package:flutter/material.dart';

import 'models/chamado.dart';

/// Paleta do portal web (ex3.css), reaproveitada no app.
class Cores {
  Cores._();

  static const titulo = Color(0xFF0F172A);
  static const texto = Color(0xFF334155);
  static const textoSuave = Color(0xFF475569);
  static const cinza = Color(0xFF64748B);
  static const cinzaClaro = Color(0xFF94A3B8);
  static const borda = Color(0xFFE2E8F0);
  static const fundoCartao = Color(0xFFF8FAFC);
  static const azul = Color(0xFF2563EB);
  static const azulEscuro = Color(0xFF1E40AF);
  static const azulClaro = Color(0xFFEFF6FF);
  static const vermelho = Color(0xFFDC2626);
  static const verde = Color(0xFF16A34A);
}

const LinearGradient gradienteAzul = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Cores.azul, Cores.azulEscuro],
);

const LinearGradient gradienteFundo = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFFF8FAFC), Color(0xFFE2E8F0)],
);

const List<BoxShadow> sombraCartao = [
  BoxShadow(
    color: Color(0x1A000000),
    blurRadius: 6,
    spreadRadius: -1,
    offset: Offset(0, 4),
  ),
];

const List<BoxShadow> sombraSuave = [
  BoxShadow(
    color: Color(0x1A000000),
    blurRadius: 3,
    offset: Offset(0, 1),
  ),
];

class EstiloPrioridade {
  const EstiloPrioridade({
    required this.barra,
    required this.texto,
    required this.fundo,
    required this.borda,
    required this.progresso,
  });

  final Color barra;
  final Color texto;
  final Color fundo;
  final Color borda;
  final List<Color> progresso;
}

EstiloPrioridade estiloDe(Prioridade p) => switch (p) {
      Prioridade.urgente => const EstiloPrioridade(
          barra: Color(0xFFEF4444),
          texto: Color(0xFFDC2626),
          fundo: Color(0xFFFEF2F2),
          borda: Color(0xFFFECACA),
          progresso: [Color(0xFFEF4444), Color(0xFFFCA5A5)],
        ),
      Prioridade.alta => const EstiloPrioridade(
          barra: Color(0xFFF59E0B),
          texto: Color(0xFFD97706),
          fundo: Color(0xFFFFFBEB),
          borda: Color(0xFFFDE68A),
          progresso: [Color(0xFFF59E0B), Color(0xFFFDE68A)],
        ),
      Prioridade.normal => const EstiloPrioridade(
          barra: Color(0xFF3B82F6),
          texto: Color(0xFF2563EB),
          fundo: Color(0xFFEFF6FF),
          borda: Color(0xFFDBEAFE),
          progresso: [Color(0xFF2563EB), Color(0xFF93C5FD)],
        ),
      Prioridade.baixa => const EstiloPrioridade(
          barra: Color(0xFF64748B),
          texto: Color(0xFF475569),
          fundo: Color(0xFFF8FAFC),
          borda: Color(0xFFE2E8F0),
          progresso: [Color(0xFF64748B), Color(0xFFCBD5E1)],
        ),
    };

Color corStatus(StatusChamado s) => switch (s) {
      StatusChamado.aberto => const Color(0xFFEF4444),
      StatusChamado.emAndamento => const Color(0xFF3B82F6),
      StatusChamado.agendado => const Color(0xFF64748B),
    };

/// Campo de texto no estilo do portal (fundo claro, borda de 2px, foco azul).
InputDecoration decoracaoCampo(String dica) {
  OutlineInputBorder borda(Color cor) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: cor, width: 2),
      );
  return InputDecoration(
    hintText: dica,
    hintStyle: const TextStyle(color: Cores.cinzaClaro),
    filled: true,
    fillColor: Cores.fundoCartao,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    enabledBorder: borda(Cores.borda),
    focusedBorder: borda(Cores.azul),
    errorBorder: borda(const Color(0xFFEF4444)),
    focusedErrorBorder: borda(const Color(0xFFEF4444)),
  );
}
