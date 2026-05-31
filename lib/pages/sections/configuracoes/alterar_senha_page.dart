import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
// Ajuste os imports abaixo caso sua estrutura de pastas mude (adicionei um '../' a mais)
import '../../../models/cidade.dart';
import '../../../services/cidade_service.dart';
import '../../../services/session_service.dart';

class EditarPerfilPage extends StatefulWidget {
  const EditarPerfilPage({super.key});

  @override
  State<EditarPerfilPage> createState() => _EditarPerfilPageState();
}

class _EditarPerfilPageState extends State<EditarPerfilPage> {
  // Lembre-se de mudar para o endereço real quando for para produção!
  static const String _baseUrl = 'http://localhost:8081';

  final _nomeController      = TextEditingController();
  final _sobrenomeController = TextEditingController();
  List<Cidade> _cidades      = [];
  Cidade? _cidadeSelecionada;
  bool _carregandoDados      = true;
  bool _salvandoDados        = false;
  String? _erroDados;
  String? _sucessoDados;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _sobrenomeController.dispose();
    super.dispose();
  }

  Future<void> _carregarDados() async {
    setState(() => _carregandoDados = true);
    try {
      final uuid    = await SessionService.getUuid() ?? '';
      final headers = await SessionService.getHeaders();

      final resultados = await Future.wait([
        // Adicionado o timeout de 10 segundos para não travar no loading!
        http.get(Uri.parse('$_baseUrl/usuarios/$uuid'), headers: headers)
            .timeout(const Duration(seconds: 10)),
        CidadeService().listarCidades(),
      ]);

      final userResp = resultados[0] as http.Response;
      final cidades  = resultados[1] as List<Cidade>;

      if (userResp.statusCode == 200) {
        final json = jsonDecode(utf8.decode(userResp.bodyBytes));
        _nomeController.text      = json['nome'] ?? '';
        _sobrenomeController.text = json['sobrenome'] ?? '';

        final cidadeJson = json['cidade'];
        if (cidadeJson != null) {
          final cidadeId = cidadeJson['id'] as int?;
          final match = cidades.where((c) => c.id == cidadeId);
          if (match.isNotEmpty) _cidadeSelecionada = match.first;
        }
      }

      if (mounted) {
        setState(() {
          _cidades        = cidades;
          _carregandoDados = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _erroDados      = 'Erro ao carregar dados. Verifique sua conexão.';
          _carregandoDados = false;
        });
      }
    }
  }

  Future<void> _salvarDados() async {
    final nome      = _nomeController.text.trim();
    final sobrenome = _sobrenomeController.text.trim();

    setState(() { _erroDados = null; _sucessoDados = null; });

    if (nome.isEmpty || sobrenome.isEmpty) {
      setState(() => _erroDados = 'Nome e sobrenome são obrigatórios.');
      return;
    }

    setState(() => _salvandoDados = true);
    try {
      final uuid    = await SessionService.getUuid() ?? '';
      final headers = await SessionService.getHeaders();

      final body = {
        'uuid':      uuid,
        'nome':      nome,
        'sobrenome': sobrenome,
        if (_cidadeSelecionada != null) 'cidadeId': _cidadeSelecionada!.id,
      };

      final response = await http.put(
        Uri.parse('$_baseUrl/usuarios/atualizar'),
        headers: headers,
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        setState(() => _sucessoDados = 'Dados atualizados com sucesso!');
      } else {
        final json = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() => _erroDados = json['erro'] ?? 'Erro ao salvar.');
      }
    } catch (e) {
      setState(() => _erroDados = 'Erro de conexão.');
    } finally {
      if (mounted) setState(() => _salvandoDados = false);
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
        title: const Text('Editar Perfil',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Colors.black87)),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFEEEEEE), height: 1),
        ),
      ),
      body: _carregandoDados
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF1F918B)))
          : ListView(
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
                      _CampoTexto(label: 'Nome', controller: _nomeController),
                      const SizedBox(height: 14),
                      _CampoTexto(label: 'Sobrenome', controller: _sobrenomeController),
                      const SizedBox(height: 14),

                      const Text('Cidade onde mora',
                          style: TextStyle(fontSize: 13, color: Colors.black87)),
                      const SizedBox(height: 6),
                      _SeletorCidade(
                        cidades: _cidades,
                        selecionada: _cidadeSelecionada,
                        onChanged: (c) => setState(() => _cidadeSelecionada = c),
                      ),
                      const SizedBox(height: 20),

                      if (_erroDados != null) ...[
                        _FeedbackBox(mensagem: _erroDados!, isErro: true),
                        const SizedBox(height: 14),
                      ],
                      if (_sucessoDados != null) ...[
                        _FeedbackBox(mensagem: _sucessoDados!, isErro: false),
                        const SizedBox(height: 14),
                      ],

                      _BotaoSalvar(
                        label: 'Salvar alterações',
                        carregando: _salvandoDados,
                        onPressed: _salvarDados,
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
class _CampoTexto extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  const _CampoTexto({required this.label, required this.controller});
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontSize: 13, color: Colors.black87)),
      const SizedBox(height: 6),
      TextField(
        controller: controller,
        decoration: InputDecoration(
          filled: true, fillColor: const Color(0xFFF2F2F2),
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

class _SeletorCidade extends StatefulWidget {
  final List<Cidade> cidades;
  final Cidade? selecionada;
  final ValueChanged<Cidade?> onChanged;
  const _SeletorCidade({required this.cidades, required this.selecionada, required this.onChanged});
  @override
  State<_SeletorCidade> createState() => _SeletorCidadeState();
}

class _SeletorCidadeState extends State<_SeletorCidade> {
  final _searchController = TextEditingController();
  List<Cidade> _filtradas = [];

  @override
  void initState() {
    super.initState();
    _filtradas = widget.cidades;
    _searchController.addListener(_filtrar);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filtrar() {
    final q = _searchController.text.toLowerCase();
    setState(() => _filtradas = widget.cidades
        .where((c) => c.nome.toLowerCase().contains(q))
        .toList());
  }

  void _abrirModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModal) {
          return DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.7,
            maxChildSize: 0.95,
            builder: (_, scroll) => Column(
              children: [
                const SizedBox(height: 12),
                Container(width: 40, height: 4,
                    decoration: BoxDecoration(color: Colors.black12,
                        borderRadius: BorderRadius.circular(2))),
                const SizedBox(height: 14),
                const Text('Selecionar Cidade',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (_) => setModal(() => _filtrar()),
                    decoration: InputDecoration(
                      hintText: 'Buscar cidade...',
                      prefixIcon: const Icon(Icons.search, size: 20, color: Colors.black38),
                      filled: true, fillColor: const Color(0xFFF2F2F2),
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0xFFDDDDDD))),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0xFFDDDDDD))),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0xFF1F918B), width: 1.5)),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                ListTile(
                  leading: Icon(
                      widget.selecionada == null ? Icons.radio_button_checked : Icons.radio_button_off,
                      color: const Color(0xFF1F918B)),
                  title: const Text('Nenhuma'),
                  onTap: () {
                    widget.onChanged(null);
                    Navigator.pop(ctx);
                  },
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView.builder(
                    controller: scroll,
                    itemCount: _filtradas.length,
                    itemBuilder: (_, i) {
                      final c = _filtradas[i];
                      final sel = widget.selecionada?.id == c.id;
                      return ListTile(
                        leading: Icon(
                            sel ? Icons.radio_button_checked : Icons.radio_button_off,
                            color: const Color(0xFF1F918B)),
                        title: Text(c.nome),
                        subtitle: Text(c.regiao,
                            style: const TextStyle(fontSize: 12, color: Colors.black45)),
                        onTap: () {
                          widget.onChanged(c);
                          Navigator.pop(ctx);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _abrirModal,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: const Color(0xFFF2F2F2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFCCCCCC)),
        ),
        child: Row(children: [
          Expanded(child: Text(
            widget.selecionada?.nome ?? 'Selecionar cidade...',
            style: TextStyle(
              fontSize: 14,
              color: widget.selecionada != null ? Colors.black87 : Colors.black38,
            ),
          )),
          const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.black38),
        ]),
      ),
    );
  }
}

class _BotaoSalvar extends StatelessWidget {
  final String label;
  final bool carregando;
  final VoidCallback onPressed;
  const _BotaoSalvar({required this.label, required this.carregando, required this.onPressed});
  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity, height: 48,
    child: ElevatedButton(
      onPressed: carregando ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1F918B), foregroundColor: Colors.white,
        disabledBackgroundColor: const Color(0xFF1F918B).withOpacity(0.6),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: carregando
          ? const SizedBox(width: 22, height: 22,
          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
          : Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
    ),
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