import 'dart:convert';
import 'package:http/http.dart' as http;
import '../main.dart';
import '../models/conquista_item.dart';
import 'session_service.dart';

class ConquistaService {
  // static const String _baseUrl = 'http://10.0.2.2:8081';
  static const String _baseUrl = 'http://localhost:8081';

  void _verificarAuth(http.Response response) {
    if (response.statusCode == 401 || response.statusCode == 403) {
      MyApp.forcarLogin();
      throw Exception('Sessão expirada. Faça login novamente.');
    }
  }

  Future<List<ConquistaItem>> buscarPorUsuario(String uuid) async {
    final headers = await SessionService.getHeaders();
    final uri = Uri.parse('$_baseUrl/conquista/usuario/$uuid');

    print('>>> GET $uri');
    print('>>> uuid usado: $uuid');

    final response = await http.get(uri, headers: headers);

    print('>>> Status: ${response.statusCode}');
    print('>>> Body: ${response.body}');

    _verificarAuth(response);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(utf8.decode(response.bodyBytes));
      return jsonList
          .map((e) => ConquistaItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Erro ao buscar conquistas: ${response.statusCode}');
    }
  }
}