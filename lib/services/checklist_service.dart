import 'dart:convert';
import 'package:http/http.dart' as http;
import '../main.dart';
import '../models/checklist.dart';
import 'session_service.dart';
import '../config/api_config.dart';

class ChecklistService {

  void _verificarAuth(http.Response response) {
    if (response.statusCode == 401 || response.statusCode == 403) {
      MyApp.forcarLogin();
      throw Exception('Sessão expirada. Faça login novamente.');
    }
  }

  Future<List<Checklist>> buscarPorUsuario(String uuid) async {
    final headers = await SessionService.getHeaders();
    final uri = Uri.parse('${ApiConfig.baseUrl}/checklists/$uuid');

    print('>>> GET $uri');
    print('>>> uuid usado: $uuid');

    final response = await http.get(uri, headers: headers);

    print('>>> Status: ${response.statusCode}');
    print('>>> Body: ${response.body}');

    _verificarAuth(response);

    if (response.statusCode == 200) {
      final List data = jsonDecode(utf8.decode(response.bodyBytes));

      return data
          .map((e) => Checklist.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Erro ao buscar checklist: ${response.statusCode}');
    }
  }

  Future<void> registrarVisita({
    required String usuarioUuid,
    required int cidadeId,
  }) async {
    final headers = await SessionService.getHeaders();
    final uri = Uri.parse('${ApiConfig.baseUrl}/checklists/visitar');

    final body = {
      'usuarioUuid': usuarioUuid,
      'cidadeId': cidadeId,
    };

    print('>>> POST $uri');
    print('>>> Headers: $headers');
    print('>>> Body: ${jsonEncode(body)}');

    final response = await http.post(
      uri,
      headers: headers,
      body: jsonEncode(body),
    );

    print('>>> Status: ${response.statusCode}');
    print('>>> Response: ${response.body}');

    _verificarAuth(response);

    if (response.statusCode != 200) {
      throw Exception('Erro ao registrar visita: ${response.statusCode}');
    }
  }

  Future<void> removerVisita({
    required String usuarioUuid,
    required int cidadeId,
  }) async {
    final headers = await SessionService.getHeaders();

    final uri = Uri.parse(
      '${ApiConfig.baseUrl}checklists/removerVisita/$cidadeId/$usuarioUuid',
    );

    print('>>> DELETE $uri');

    final response = await http.delete(uri, headers: headers);

    print('>>> Status: ${response.statusCode}');
    print('>>> Response: ${response.body}');

    _verificarAuth(response);

    if (response.statusCode != 204) {
      throw Exception('Erro ao remover visita: ${response.statusCode}');
    }
  }

  Future<String?> buscarUltimaCidadeVisitada(String uuid) async {
    final headers = await SessionService.getHeaders();

    final uri = Uri.parse('${ApiConfig.baseUrl}checklists/$uuid/ultima-visita');

    final response = await http.get(uri, headers: headers);

    _verificarAuth(response);

    if (response.statusCode == 200) {
      if (response.body.isEmpty) return null;

      final body = jsonDecode(utf8.decode(response.bodyBytes));
      return body['cidadeNome'] as String?;
    }

    if (response.statusCode == 404 || response.statusCode == 204) {
      return null;
    }

    throw Exception('Erro ao buscar última cidade visitada');
  }
}