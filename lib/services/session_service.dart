import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  // ── Cache em memória (funciona sempre, inclusive no Windows sem Dev Mode) ──
  static String? _token;
  static String? _uuid;
  static String? _email;
  static String? _role;

  static const _keyToken = 'session_token';
  static const _keyUuid  = 'session_uuid';
  static const _keyEmail = 'session_email';
  static const _keyRole  = 'session_role';

  // ── SALVAR ───────────────────────────────────────────────────────────────
  static Future<void> salvar({
    required String token,
    required String uuid,
    required String email,
    required String role,
  }) async {
    // Salva em memória primeiro (sempre funciona)
    _token = token;
    _uuid  = uuid;
    _email = email;
    _role  = role;

    // Tenta persistir no disco (pode falhar no Windows sem Dev Mode)
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyToken, token);
      await prefs.setString(_keyUuid, uuid);
      await prefs.setString(_keyEmail, email);
      await prefs.setString(_keyRole, role);
    } catch (_) {
      // Silencia erro — memória já está salva
    }
  }

  // ── LER ──────────────────────────────────────────────────────────────────
  static Future<String?> getToken() async {
    if (_token != null) return _token;
    return _lerDoDisco(_keyToken);
  }

  static Future<String?> getUuid() async {
    if (_uuid != null) return _uuid;
    return _lerDoDisco(_keyUuid);
  }

  static Future<String?> getEmail() async {
    if (_email != null) return _email;
    return _lerDoDisco(_keyEmail);
  }

  static Future<String?> getRole() async {
    if (_role != null) return _role;
    return _lerDoDisco(_keyRole);
  }

  static Future<String?> _lerDoDisco(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(key);
    } catch (_) {
      return null;
    }
  }

  // ── VERIFICAR SE ESTÁ LOGADO ─────────────────────────────────────────────
  static Future<bool> estaLogado() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // ── LIMPAR (logout) ──────────────────────────────────────────────────────
  static Future<void> limpar() async {
    _token = null;
    _uuid  = null;
    _email = null;
    _role  = null;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyToken);
      await prefs.remove(_keyUuid);
      await prefs.remove(_keyEmail);
      await prefs.remove(_keyRole);
    } catch (_) {}
  }

  // ── HEADERS PRONTOS PARA REQUISIÇÕES ─────────────────────────────────────
  static Future<Map<String, String>> getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty)
        'Authorization': 'Bearer $token',
    };
  }
}