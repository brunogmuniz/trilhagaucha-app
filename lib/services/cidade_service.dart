import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/cidade.dart';
import '../config/api_config.dart';

class CidadeService {

  Future<List<Cidade>> listarCidades() async {
    final uri = Uri.parse('${ApiConfig.baseUrl}cidades/listar');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List data = jsonDecode(utf8.decode(response.bodyBytes));

      return data.map((e) => Cidade.fromJson(e)).toList();
    } else {
      throw Exception('Erro ao buscar cidades: ${response.statusCode}');
    }
  }

  Future<List<Cidade>> listarPorRegiao(String regiao) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}cidades/regiao/$regiao');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List data = jsonDecode(utf8.decode(response.bodyBytes));

      return data.map((e) => Cidade.fromJson(e)).toList();
    } else {
      throw Exception('Erro ao buscar cidades por região: ${response.statusCode}');
    }
  }
}