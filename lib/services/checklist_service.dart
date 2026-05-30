import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/checklist.dart';
import 'session_service.dart';

class ChecklistService {
  static const String _baseUrl = 'http://localhost:8081';

  Future<List<Checklist>> buscarPorUsuario(String uuid) async {
    final headers = await SessionService.getHeaders();
    final uri = Uri.parse('$_baseUrl/checklists/$uuid');

    print('>>> GET $uri');
    print('>>> Headers: $headers');

    final response = await http.get(uri, headers: headers);

    print('>>> Status: ${response.statusCode}');
    print('>>> Body: ${response.body}');

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(utf8.decode(response.bodyBytes));
      return jsonList
          .map((e) => Checklist.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Erro ao buscar checklist: ${response.statusCode} - ${response.body}');
    }
  }

  Future<void> registrarVisita({
    required int usuarioId,
    required int cidadeId,
  }) async {
    final headers = await SessionService.getHeaders();
    final uri = Uri.parse('$_baseUrl/checklists/visitar');
    final response = await http.post(
      uri,
      headers: headers,
      body: jsonEncode({
        'usuarioId': usuarioId,
        'cidadeId': cidadeId,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Erro ao registrar visita');
    }
  }

  Future<void> removerVisita({
    required int usuarioId,
    required int cidadeId,
  }) async {
    final headers = await SessionService.getHeaders();
    final uri = Uri.parse('$_baseUrl/checklists/removerVisita/$cidadeId/$usuarioId');
    final response = await http.delete(uri, headers: headers);

    if (response.statusCode != 204) {
      throw Exception('Erro ao remover visita');
    }
  }
}