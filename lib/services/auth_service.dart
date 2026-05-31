import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/usuario.dart';
import 'session_service.dart';

class AuthService {
 // static const String _baseUrl = 'http://10.0.2.2:8081';
  static const String _baseUrl = 'http://localhost:8081';

  Future<Usuario> login(String email, String senha) async {
    final uri = Uri.parse('$_baseUrl/auth/login');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'senha': senha}),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> json = jsonDecode(
        utf8.decode(response.bodyBytes),
      );

      final token = json['token'] as String;
      final usuarioJson = json['usuario'] as Map<String, dynamic>;

      final uuid = usuarioJson['id'] as String? ?? '';
      final role = usuarioJson['role_USER'] as String? ?? 'USER';

      print('>>> LOGIN OK | uuid: $uuid | role: $role');

      await SessionService.salvar(
        token: token,
        uuid: uuid,
        email: email,
        role: role,
      );

      return Usuario(
        id: 0,
        uuid: uuid,
        nome: '',
        sobrenome: '',
        email: email,
        roleUser: role,
        status: 'ATIVO',
        emailVerificado: false,
      );
    } else {
      final body = jsonDecode(utf8.decode(response.bodyBytes));
      throw Exception(body['erro'] ?? 'Erro ao fazer login');
    }
  }

  Future<void> cadastrar({
    required String nome,
    required String sobrenome,
    required String email,
    required String senha,
  }) async {
    final uri = Uri.parse('$_baseUrl/auth/cadastrar');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nome': nome,
        'sobrenome': sobrenome,
        'email': email,
        'senha': senha,
      }),
    );

    if (response.statusCode != 201) {
      final body = jsonDecode(utf8.decode(response.bodyBytes));
      throw Exception(body['erro'] ?? 'Erro ao cadastrar');
    }
  }

  Future<Usuario> buscarUsuarioPorUuid(String uuid) async {
    final headers = await SessionService.getHeaders();
    final uri = Uri.parse('$_baseUrl/usuarios/$uuid');
    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      return Usuario.fromJson(
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>,
      );
    } else {
      throw Exception('Erro ao buscar dados do usuário');
    }
  }

  Future<void> logout() async {
    await SessionService.limpar();
  }
}