import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../main.dart';
import '../models/checklist.dart';
import 'session_service.dart';

class ChecklistService {
 // static const String _baseUrl = 'http://10.0.2.2:8081';
  static const String _baseUrl = 'http://localhost:8081';
  void _verificarAuth(http.Response response) {
    if (response.statusCode == 401 || response.statusCode == 403) {
      MyApp.forcarLogin();
      throw Exception('Sessão expirada. Faça login novamente.');
    }
  }

  Future<List<Checklist>> buscarPorUsuario(String uuid) async {
    final headers = await SessionService.getHeaders();
    final uri = Uri.parse('$_baseUrl/checklists/$uuid');

    print('>>> GET $uri');
    print('>>> uuid usado: $uuid');

    final response = await http.get(uri, headers: headers);

    print('>>> Status: ${response.statusCode}');
    print('>>> Body: ${response.body}');

    _verificarAuth(response);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(utf8.decode(response.bodyBytes));
      return jsonList
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
    final uri = Uri.parse('$_baseUrl/checklists/visitar');

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
      '$_baseUrl/checklists/removerVisita/$cidadeId/$usuarioUuid',
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
}