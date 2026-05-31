import 'package:flutter/material.dart';
import '../../models/cidade.dart';
import '../../services/cidade_service.dart';
import '../../services/checklist_service.dart';
import '../../services/session_service.dart';

class ChecklistPage extends StatefulWidget {
  const ChecklistPage({super.key});

  @override
  State<ChecklistPage> createState() => _ChecklistPageState();
}

class _ChecklistPageState extends State<ChecklistPage> {
  final CidadeService _cidadeService = CidadeService();
  final ChecklistService _checklistService = ChecklistService();
  final TextEditingController _searchController = TextEditingController();

  List<Cidade> _todasCidades = [];
  List<Cidade> _cidadesFiltradas = [];

  // cidadeId → true/false (visitado)
  final Map<int, bool> _visitadas = {};
  // cidadeId → usuarioId (para poder remover)
  int _usuarioId = 0;
  String _uuid = '';

  bool _loading = true;
  // ids com requisição em andamento (evita double-tap)
  final Set<int> _salvando = {};
  String? _erro;

  bool _ordemAZ = true;
  List<String> _regioes = [];
  String? _regiaoSelecionada;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filtrar);
    _carregarTudo();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _carregarTudo() async {
    setState(() { _loading = true; _erro = null; });
    try {
      _uuid = await SessionService.getUuid() ?? '';

      final resultados = await Future.wait([
        _cidadeService.listarCidades(),
        _checklistService.buscarPorUsuario(_uuid),
      ]);

      final cidades = resultados[0] as List<Cidade>;
      final checklist = resultados[1] as List;

      final visitadasMap = <int, bool>{};
      for (final item in checklist) {
        visitadasMap[item.cidadeId] = item.visitado;
        if (_usuarioId == 0) _usuarioId = item.usuarioId;
      }

      final regioes = cidades
          .map((c) => c.regiao)
          .where((r) => r.isNotEmpty)
          .toSet()
          .toList()
        ..sort();

      setState(() {
        _todasCidades = cidades;
        _regioes = regioes;
        _visitadas.addAll(visitadasMap);
        _loading = false;
      });
      _filtrar();
    } catch (e) {
      setState(() { _erro = e.toString(); _loading = false; });
    }
  }

  void _filtrar() {
    final query = _searchController.text.toLowerCase();
    List<Cidade> resultado = _todasCidades;

    if (_regiaoSelecionada != null) {
      resultado = resultado.where((c) => c.regiao == _regiaoSelecionada).toList();
    }
    if (query.isNotEmpty) {
      resultado = resultado.where((c) => c.nome.toLowerCase().contains(query)).toList();
    }
    resultado.sort((a, b) =>
    _ordemAZ ? a.nome.compareTo(b.nome) : b.nome.compareTo(a.nome));

    setState(() => _cidadesFiltradas = resultado);
  }

  void _toggleOrdem() {
    setState(() => _ordemAZ = !_ordemAZ);
    _filtrar();
  }

  Future<void> _toggleVisita(Cidade cidade) async {
    if (_salvando.contains(cidade.id)) return;

    final eraVisitada = _visitadas[cidade.id] ?? false;

    setState(() {
      _visitadas[cidade.id] = !eraVisitada;
      _salvando.add(cidade.id);
    });

    try {
      if (eraVisitada) {
        await _checklistService.removerVisita(
          usuarioUuid: _uuid,
          cidadeId: cidade.id,
        );
      } else {
        await _checklistService.registrarVisita(
          usuarioUuid: _uuid,
          cidadeId: cidade.id,
        );
      }
    } catch (e) {
      setState(() => _visitadas[cidade.id] = eraVisitada);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar: ${e.toString().replaceFirst('Exception: ', '')}'),
            backgroundColor: const Color(0xFFE84040),
          ),
        );
      }
    } finally {
      setState(() => _salvando.remove(cidade.id));
    }
  }

  void _abrirFiltroRegiao() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Filtrar por Região',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const Divider(),
              ListTile(
                leading: Icon(
                  _regiaoSelecionada == null
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: const Color(0xFF1F918B),
                ),
                title: const Text('Todas as regiões'),
                onTap: () {
                  setState(() => _regiaoSelecionada = null);
                  _filtrar();
                  Navigator.pop(context);
                },
              ),
              ..._regioes.map((r) => ListTile(
                leading: Icon(
                  _regiaoSelecionada == r
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: const Color(0xFF1F918B),
                ),
                title: Text(r),
                onTap: () {
                  setState(() => _regiaoSelecionada = r);
                  _filtrar();
                  Navigator.pop(context);
                },
              )),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = _todasCidades.length;
    final marcadas = _visitadas.values.where((v) => v).length;
    final progresso = total == 0 ? 0.0 : marcadas / total;

    return Column(
      children: [
        _ProgressHeader(marcadas: marcadas, total: total, progresso: progresso),

        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Buscar cidades...',
                  hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
                  prefixIcon: const Icon(Icons.search, color: Colors.black38, size: 20),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF1F918B), width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _FilterChipButton(
                    icon: Icons.sort_by_alpha,
                    label: _ordemAZ ? 'A - Z' : 'Z - A',
                    onTap: _toggleOrdem,
                    active: false,
                  ),
                  const SizedBox(width: 8),
                  _FilterChipButton(
                    icon: Icons.map_outlined,
                    label: _regiaoSelecionada ?? 'Filtrar por Região',
                    onTap: _abrirFiltroRegiao,
                    active: _regiaoSelecionada != null,
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        Expanded(
          child: _loading
              ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF1F918B)))
              : _erro != null
              ? _ErroView(mensagem: _erro!, onRetry: _carregarTudo)
              : _cidadesFiltradas.isEmpty
              ? const Center(
              child: Text('Nenhuma cidade encontrada.',
                  style: TextStyle(color: Colors.black38)))
              : ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            itemCount: _cidadesFiltradas.length,
            itemBuilder: (_, i) {
              final cidade = _cidadesFiltradas[i];
              final visitada = _visitadas[cidade.id] ?? false;
              final salvando = _salvando.contains(cidade.id);
              return _CidadeItem(
                cidade: cidade,
                marcada: visitada,
                salvando: salvando,
                onToggle: () => _toggleVisita(cidade),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ProgressHeader extends StatelessWidget {
  final int marcadas;
  final int total;
  final double progresso;

  const _ProgressHeader({
    required this.marcadas,
    required this.total,
    required this.progresso,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFF2F2F2),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
              children: [
                const TextSpan(text: 'Você completou '),
                TextSpan(
                  text: '${(progresso * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(decoration: TextDecoration.underline),
                ),
                const TextSpan(text: ' do RS!'),
              ],
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progresso,
              minHeight: 14,
              backgroundColor: const Color(0xFFDDDDDD),
              valueColor:
              const AlwaysStoppedAnimation<Color>(Color(0xFF1F918B)),
            ),
          ),
        ],
      ),
    );
  }
}


class _FilterChipButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool active;

  const _FilterChipButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? const Color(0xFF1F918B) : Colors.black54;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: active ? const Color(0xFF1F918B) : const Color(0xFFDDDDDD),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(fontSize: 13, color: color)),
          ],
        ),
      ),
    );
  }
}


class _CidadeItem extends StatelessWidget {
  final Cidade cidade;
  final bool marcada;
  final bool salvando;
  final VoidCallback onToggle;

  const _CidadeItem({
    required this.cidade,
    required this.marcada,
    required this.salvando,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: salvando ? null : onToggle,
      child: Container(
        margin: const EdgeInsets.only(bottom: 2),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: marcada ? const Color(0xFF1F918B) : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: marcada ? const Color(0xFF1F918B) : Colors.black26,
                  width: 1.8,
                ),
              ),
              child: salvando
                  ? const Padding(
                padding: EdgeInsets.all(5),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF1F918B),
                ),
              )
                  : marcada
                  ? const Icon(Icons.check, size: 18, color: Colors.white)
                  : const Icon(Icons.close, size: 16, color: Colors.black26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                cidade.nome,
                style: TextStyle(
                  fontSize: 17,
                  color: marcada ? Colors.black87 : Colors.black54,
                  fontWeight: marcada ? FontWeight.w500 : FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class _ErroView extends StatelessWidget {
  final String mensagem;
  final VoidCallback onRetry;

  const _ErroView({required this.mensagem, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 52, color: Colors.black26),
            const SizedBox(height: 16),
            const Text('Não foi possível carregar as cidades.',
                style: TextStyle(fontSize: 15, color: Colors.black54),
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(mensagem,
                style: const TextStyle(fontSize: 12, color: Colors.black38),
                textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1F918B),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}