import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static String? _token;
  static String? _uuid;
  static String? _email;
  static String? _role;

  static const _keyToken = 'session_token';
  static const _keyUuid  = 'session_uuid';
  static const _keyEmail = 'session_email';
  static const _keyRole  = 'session_role';

  static Future<void> salvar({
    required String token,
    required String uuid,
    required String email,
    required String role,
  }) async {
    _token = token;
    _uuid  = uuid;
    _email = email;
    _role  = role;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyToken, token);
      await prefs.setString(_keyUuid, uuid);
      await prefs.setString(_keyEmail, email);
      await prefs.setString(_keyRole, role);
      print('>>> Sessão salva no disco | uuid: $uuid');
    } catch (e) {
      print('>>> shared_preferences indisponível, usando só memória: $e');
    }
  }

  static Future<String?> getToken() async => _token ?? await _disco(_keyToken);
  static Future<String?> getUuid()  async => _uuid  ?? await _disco(_keyUuid);
  static Future<String?> getEmail() async => _email ?? await _disco(_keyEmail);
  static Future<String?> getRole()  async => _role  ?? await _disco(_keyRole);

  static Future<String?> _disco(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final val = prefs.getString(key);
      // Preenche cache ao ler do disco
      if (key == _keyToken) _token = val;
      if (key == _keyUuid)  _uuid  = val;
      if (key == _keyEmail) _email = val;
      if (key == _keyRole)  _role  = val;
      return val;
    } catch (_) {
      return null;
    }
  }

  static Future<bool> estaLogado() async {
    final token = await getToken();
    final uuid  = await getUuid();
    return token != null && token.isNotEmpty &&
        uuid  != null && uuid.isNotEmpty;
  }

  static Future<void> limpar() async {
    _token = null;
    _uuid  = null;
    _email = null;
    _role  = null;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (_) {}
  }

  static Future<Map<String, String>> getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty)
        'Authorization': 'Bearer $token',
    };
  }
}