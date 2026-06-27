import 'package:flutter/material.dart';

/// Converte os identificadores de string vindos do backend (`iconeNome`,
/// `corHex`) para os tipos nativos do Flutter usados na UI.
class ConquistaIconMapper {
  static const Map<String, IconData> _icones = {
    'trofeu': Icons.emoji_events_rounded,
    'mapa': Icons.map_rounded,
    'cuia': Icons.local_cafe_rounded,
    'bota': Icons.hiking_rounded,
    'estrela': Icons.star_rounded,
    'montanha': Icons.terrain_rounded,
    'bandeira': Icons.flag_rounded,
    'sol': Icons.wb_sunny_rounded,
    'praia': Icons.beach_access_rounded,
    'gaucho': Icons.savings_rounded,
    'coracao': Icons.favorite_rounded,
    'foguete': Icons.rocket_launch_rounded,
  };

  /// Retorna o ícone correspondente; usa um ícone genérico como fallback
  /// caso o backend envie uma chave ainda não mapeada aqui.
  static IconData resolve(String iconeNome) {
    return _icones[iconeNome] ?? Icons.military_tech_rounded;
  }

  /// Converte uma string hex (`#1F918B` ou `1F918B`) em [Color].
  static Color colorFromHex(String corHex) {
    final hex = corHex.replaceAll('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }
}
