import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../services/session_service.dart'; // Ajuste o path se necessário

class AlterarSenhaPage extends StatefulWidget {
  const AlterarSenhaPage({super.key});

  @override
  State<AlterarSenhaPage> createState() => _AlterarSenhaPageState();
}

class _AlterarSenhaPageState extends State<AlterarSenhaPage> {
  static const String _baseUrl = 'http://localhost:8081';

  final _novaSenhaController      = TextEditingController();
  final _confirmarSenhaController = TextEditingController();
  bool _novaSenhaVisivel          = false;
  bool _confirmarVisivel          = false;
  bool _salvandoSenha             = false;
  String? _erroSenha;
  String? _sucessoSenha;

  @override
  void dispose() {
    _novaSenhaController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
  }

  Future<void> _alterarSenha() async {
    final nova      = _novaSenhaController.text;
    final confirmar = _confirmarSenhaController.text;

    setState(() { _erroSenha = null; _sucessoSenha = null; });

    if (nova.isEmpty || confirmar.isEmpty) {
      setState(() => _erroSenha = 'Preencha todos os campos.');
      return;
    }
    if (nova.length < 6) {
      setState(() => _erroSenha = 'Mínimo de 6 caracteres.');
      return;
    }
    if (nova != confirmar) {
      setState(() => _erroSenha = 'As senhas não coincidem.');
      return;
    }

    setState(() => _salvandoSenha = true);
    try {
      final uuid    = await SessionService.getUuid() ?? '';
      final headers = await SessionService.getHeaders();

      final response = await http.post(
        Uri.parse('$_baseUrl/auth/redefinirSenha'),
        headers: headers,
        body: jsonEncode({'uuid': uuid, 'senha': nova}),
      ).timeout(const Duration(seconds: 10)); // Timeout adicionado!

      if (response.statusCode == 200) {
        setState(() {
          _sucessoSenha = 'Senha alterada com sucesso!';
          _novaSenhaController.clear();
          _confirmarSenhaController.clear();
        });
      } else {
        final json = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() => _erroSenha = json['erro'] ?? 'Erro ao alterar senha.');
      }
    } catch (e) {
      setState(() => _erroSenha = 'Erro de conexão.');
    } finally {
      if (mounted) setState(() => _salvandoSenha = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Alterar Senha',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Colors.black87)),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFEEEEEE), height: 1),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFDDDDDD)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Por segurança, crie uma senha forte.',
                    style: TextStyle(fontSize: 13, color: Colors.black45)),
                const SizedBox(height: 20),

                _CampoSenha(
                  label: 'Nova senha',
                  controller: _novaSenhaController,
                  visivel: _novaSenhaVisivel,
                  onToggle: () => setState(() => _novaSenhaVisivel = !_novaSenhaVisivel),
                ),
                const SizedBox(height: 14),
                _CampoSenha(
                  label: 'Confirmar nova senha',
                  controller: _confirmarSenhaController,
                  visivel: _confirmarVisivel,
                  onToggle: () => setState(() => _confirmarVisivel = !_confirmarVisivel),
                ),
                const SizedBox(height: 20),

                if (_erroSenha != null) ...[
                  _FeedbackBox(mensagem: _erroSenha!, isErro: true),
                  const SizedBox(height: 14),
                ],
                if (_sucessoSenha != null) ...[
                  _FeedbackBox(mensagem: _sucessoSenha!, isErro: false),
                  const SizedBox(height: 14),
                ],

                SizedBox(
                  width: double.infinity, height: 48,
                  child: ElevatedButton(
                    onPressed: _salvandoSenha ? null : _alterarSenha,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1F918B), foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(0xFF1F918B).withOpacity(0.6),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: _salvandoSenha
                        ? const SizedBox(width: 22, height: 22,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                        : const Text('Atualizar senha', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---- Widgets Reaproveitados ---- //
class _CampoSenha extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool visivel;
  final VoidCallback onToggle;
  const _CampoSenha({required this.label, required this.controller,
    required this.visivel, required this.onToggle});
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontSize: 13, color: Colors.black87)),
      const SizedBox(height: 6),
      TextField(
        controller: controller,
        obscureText: !visivel,
        decoration: InputDecoration(
          filled: true, fillColor: const Color(0xFFF2F2F2),
          suffixIcon: IconButton(
            icon: Icon(visivel ? Icons.visibility_off : Icons.visibility,
                color: Colors.black38, size: 20),
            onPressed: onToggle,
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFCCCCCC))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFCCCCCC))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF1F918B), width: 1.5)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      ),
    ],
  );
}

class _FeedbackBox extends StatelessWidget {
  final String mensagem;
  final bool isErro;
  const _FeedbackBox({required this.mensagem, required this.isErro});
  @override
  Widget build(BuildContext context) {
    final color  = isErro ? const Color(0xFFE84040) : const Color(0xFF1F918B);
    final bg     = isErro ? const Color(0xFFFFEBEB) : const Color(0xFFE8F5F4);
    final icon   = isErro ? Icons.error_outline : Icons.check_circle_outline;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color)),
      child: Row(children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        Expanded(child: Text(mensagem, style: TextStyle(fontSize: 13, color: color))),
      ]),
    );
  }
}