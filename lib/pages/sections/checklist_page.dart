import 'package:flutter/material.dart';
import '../../models/cidade.dart';
import '../../services/cidade_service.dart';
import '../../services/checklist_service.dart';
import '../../services/session_service.dart';

enum FiltroVisita { todos, visitados, naoVisitados }

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

  final Map<int, bool> _visitadas = {};
  int _usuarioId = 0;
  String _uuid = '';

  bool _loading = true;
  final Set<int> _salvando = {};
  String? _erro;

  bool _ordemAZ = true;
  List<String> _regioes = [];
  String? _regiaoSelecionada;
  FiltroVisita _filtroVisita = FiltroVisita.todos;

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
    setState(() {
      _loading = true;
      _erro = null;
    });
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
      setState(() {
        _erro = e.toString();
        _loading = false;
      });
    }
  }

  void _filtrar() {
    final query = _searchController.text.toLowerCase();
    List<Cidade> resultado = _todasCidades;

    if (_regiaoSelecionada != null) {
      resultado = resultado.where((c) => c.regiao == _regiaoSelecionada).toList();
    }

    if (_filtroVisita == FiltroVisita.visitados) {
      resultado = resultado.where((c) => _visitadas[c.id] == true).toList();
    } else if (_filtroVisita == FiltroVisita.naoVisitados) {
      resultado = resultado.where((c) => _visitadas[c.id] != true).toList();
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

    if (eraVisitada) {
      final confirmar = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'Remover visita',
            style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
          ),
          content: Text(
            'Tem certeza que deseja desmarcar ${cidade.nome} das suas cidades visitadas?',
            style: const TextStyle(color: Colors.black54),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w500),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4B4F),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Desmarcar', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      );

      if (confirmar != true) return;
    }

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
            backgroundColor: const Color(0xFFEF4B4F),
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
                decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 16),
              const Text('Filtrar por Região', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const Divider(),
              ListTile(
                leading: Icon(
                  _regiaoSelecionada == null ? Icons.radio_button_checked : Icons.radio_button_off,
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
                  _regiaoSelecionada == r ? Icons.radio_button_checked : Icons.radio_button_off,
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

  void _abrirFiltroVisita() {
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
                decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 16),
              const Text('Filtrar por Status', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const Divider(),
              ListTile(
                leading: Icon(
                  _filtroVisita == FiltroVisita.todos ? Icons.radio_button_checked : Icons.radio_button_off,
                  color: const Color(0xFF1F918B),
                ),
                title: const Text('Todas as cidades'),
                onTap: () {
                  setState(() => _filtroVisita = FiltroVisita.todos);
                  _filtrar();
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(
                  _filtroVisita == FiltroVisita.visitados ? Icons.radio_button_checked : Icons.radio_button_off,
                  color: const Color(0xFF1F918B),
                ),
                title: const Text('Apenas Visitadas'),
                onTap: () {
                  setState(() => _filtroVisita = FiltroVisita.visitados);
                  _filtrar();
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(
                  _filtroVisita == FiltroVisita.naoVisitados ? Icons.radio_button_checked : Icons.radio_button_off,
                  color: const Color(0xFF1F918B),
                ),
                title: const Text('Apenas Não Visitadas'),
                onTap: () {
                  setState(() => _filtroVisita = FiltroVisita.naoVisitados);
                  _filtrar();
                  Navigator.pop(context);
                },
              ),
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
        _ProgressHeaderCard(marcadas: marcadas, total: total, progresso: progresso),

        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Buscar cidades...',
                    hintStyle: TextStyle(color: Colors.black38, fontSize: 15),
                    prefixIcon: Icon(Icons.search, color: Color(0xFF1F918B), size: 22),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
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
                      label: _regiaoSelecionada ?? 'Região',
                      onTap: _abrirFiltroRegiao,
                      active: _regiaoSelecionada != null,
                    ),
                    const SizedBox(width: 8),
                    _FilterChipButton(
                      icon: Icons.checklist_rounded,
                      label: _filtroVisita == FiltroVisita.todos
                          ? 'Status'
                          : _filtroVisita == FiltroVisita.visitados
                          ? 'Visitados'
                          : 'Não Visitados',
                      onTap: _abrirFiltroVisita,
                      active: _filtroVisita != FiltroVisita.todos,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF1F918B)))
              : _erro != null
              ? _ErroView(mensagem: _erro!, onRetry: _carregarTudo)
              : _cidadesFiltradas.isEmpty
              ? const Center(
              child: Text('Nenhuma cidade encontrada.',
                  style: TextStyle(color: Colors.black38)))
              : ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            physics: const BouncingScrollPhysics(),
            itemCount: _cidadesFiltradas.length,
            itemBuilder: (_, i) {
              final cidade = _cidadesFiltradas[i];
              final visitada = _visitadas[cidade.id] ?? false;
              final salvando = _salvando.contains(cidade.id);
              return _CidadeItemCard(
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

class _ProgressHeaderCard extends StatelessWidget {
  final int marcadas;
  final int total;
  final double progresso;

  const _ProgressHeaderCard({
    required this.marcadas,
    required this.total,
    required this.progresso,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Seu Progresso',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$marcadas de $total',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF1F918B).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${(progresso * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1F918B),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progresso,
              minHeight: 10,
              backgroundColor: const Color(0xFFF2F2F2),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF1F918B)),
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF1F918B).withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: active ? const Color(0xFF1F918B) : const Color(0xFFDDDDDD),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min, // Garante que ocupe só o necessário
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color),
            ),
          ],
        ),
      ),
    );
  }
}

class _CidadeItemCard extends StatelessWidget {
  final Cidade cidade;
  final bool marcada;
  final bool salvando;
  final VoidCallback onToggle;

  const _CidadeItemCard({
    required this.cidade,
    required this.marcada,
    required this.salvando,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: salvando ? null : onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: marcada ? const Color(0xFF1F918B).withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: marcada ? const Color(0xFF1F918B).withOpacity(0.4) : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: [
            if (!marcada)
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cidade.nome,
                    style: TextStyle(
                      fontSize: 17,
                      color: marcada ? const Color(0xFF1F918B) : Colors.black87,
                      fontWeight: marcada ? FontWeight.w700 : FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.map_rounded,
                        size: 12,
                        color: marcada ? const Color(0xFF1F918B).withOpacity(0.6) : Colors.black38,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        cidade.regiao,
                        style: TextStyle(
                          fontSize: 12,
                          color: marcada ? const Color(0xFF1F918B).withOpacity(0.8) : Colors.black45,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: marcada ? const Color(0xFF1F918B) : const Color(0xFFF2F2F2),
                shape: BoxShape.circle,
              ),
              child: salvando
                  ? const Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF1F918B),
                ),
              )
                  : Icon(
                Icons.check_rounded,
                size: 20,
                color: marcada ? Colors.white : Colors.black26,
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