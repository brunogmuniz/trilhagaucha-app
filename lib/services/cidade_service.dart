import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/cidade.dart';

class CidadeService {
  static const String _baseUrl = 'http://localhost:8081';

  Future<List<Cidade>> listarCidades() async {
    final uri = Uri.parse('$_baseUrl/cidades/listar');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(
        utf8.decode(response.bodyBytes),
      );
      return jsonList.map((e) => Cidade.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Erro ao buscar cidades: ${response.statusCode}');
    }
  }

  Future<List<Cidade>> listarPorRegiao(String regiao) async {
    final uri = Uri.parse('$_baseUrl/cidades/regiao/$regiao');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(
        utf8.decode(response.bodyBytes),
      );
      return jsonList.map((e) => Cidade.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Erro ao buscar cidades por região: ${response.statusCode}');
    }
  }
}