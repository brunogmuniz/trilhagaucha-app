import 'package:flutter/material.dart';
import '../../models/conquista_item.dart';
import '../../services/conquista_service.dart';
import '../../services/session_service.dart';
import '../../utils/conquista_icon_mapper.dart';

enum FiltroConquista { todas, conquistadas, bloqueadas }

const _kBackground = Color(0xFFF2F2F2);
const _kTurquesa = Color(0xFF1F918B);
const _kVermelho = Color(0xFFEF4B4F);

class ConquistaPage extends StatefulWidget {
  const ConquistaPage({super.key});

  @override
  State<ConquistaPage> createState() => _ConquistaPageState();
}

class _ConquistaPageState extends State<ConquistaPage> {
  final ConquistaService _conquistaService = ConquistaService();

  List<ConquistaItem> _conquistas = [];
  FiltroConquista _filtro = FiltroConquista.todas;

  bool _loading = true;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _carregarConquistas();
  }

  Future<void> _carregarConquistas() async {
    setState(() {
      _loading = true;
      _erro = null;
    });
    try {
      final uuid = await SessionService.getUuid() ?? '';
      final conquistas = await _conquistaService.buscarPorUsuario(uuid);
      setState(() {
        _conquistas = conquistas;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _erro = e.toString();
        _loading = false;
      });
    }
  }

  List<ConquistaItem> get _filtradas {
    switch (_filtro) {
      case FiltroConquista.conquistadas:
        return _conquistas.where((c) => c.desbloqueada).toList();
      case FiltroConquista.bloqueadas:
        return _conquistas.where((c) => !c.desbloqueada).toList();
      case FiltroConquista.todas:
        return _conquistas;
    }
  }

  void _abrirDetalhe(ConquistaItem conquista) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _ConquistaDetalheSheet(conquista: conquista),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Container(
        color: _kBackground,
        child: Center(
          child: CircularProgressIndicator(color: _kTurquesa),
        ),
      );
    }

    if (_erro != null) {
      return Container(
        color: _kBackground,
        child: _ErroConquistasView(
          mensagem: _erro!,
          onRetry: _carregarConquistas,
        ),
      );
    }

    final total = _conquistas.length;
    final desbloqueadas = _conquistas.where((c) => c.desbloqueada).length;
    final bloqueadas = total - desbloqueadas;
    final progresso = total == 0 ? 0.0 : desbloqueadas / total;

    return Container(
      color: _kBackground,
      child: Column(
        children: [
          _PassaporteHeaderCard(
            desbloqueadas: desbloqueadas,
            total: total,
            progresso: progresso,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Row(
              children: [
                Expanded(
                  child: _FiltroChip(
                    label: 'Todas',
                    selecionado: _filtro == FiltroConquista.todas,
                    onTap: () => setState(() => _filtro = FiltroConquista.todas),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _FiltroChip(
                    label: 'Conquistadas ($desbloqueadas)',
                    selecionado: _filtro == FiltroConquista.conquistadas,
                    onTap: () =>
                        setState(() => _filtro = FiltroConquista.conquistadas),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _FiltroChip(
                    label: 'Bloqueadas ($bloqueadas)',
                    selecionado: _filtro == FiltroConquista.bloqueadas,
                    onTap: () =>
                        setState(() => _filtro = FiltroConquista.bloqueadas),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _filtradas.isEmpty
                ? const Center(
              child: Text(
                'Nenhuma conquista nessa categoria.',
                style: TextStyle(color: Colors.black38),
              ),
            )
                : GridView.builder(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              physics: const BouncingScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 0.82,
              ),
              itemCount: _filtradas.length,
              itemBuilder: (_, i) {
                final conquista = _filtradas[i];
                return _ConquistaCard(
                  conquista: conquista,
                  onTap: () => _abrirDetalhe(conquista),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Card de destaque no topo ("Passaporte Gaúcho").
class _PassaporteHeaderCard extends StatelessWidget {
  final int desbloqueadas;
  final int total;
  final double progresso;

  const _PassaporteHeaderCard({
    required this.desbloqueadas,
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
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _kTurquesa.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.menu_book_rounded, color: _kTurquesa),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Seu Passaporte Gaúcho',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$desbloqueadas de $total Desbloqueadas',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: _kTurquesa.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${(progresso * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: _kTurquesa,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progresso),
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) {
                return LinearProgressIndicator(
                  value: value,
                  minHeight: 10,
                  backgroundColor: const Color(0xFFF2F2F2),
                  valueColor: const AlwaysStoppedAnimation<Color>(_kTurquesa),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Chip de filtro rápido (Todas / Conquistadas / Bloqueadas).
class _FiltroChip extends StatelessWidget {
  final String label;
  final bool selecionado;
  final VoidCallback onTap;

  const _FiltroChip({
    required this.label,
    required this.selecionado,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selecionado ? _kTurquesa : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selecionado ? _kTurquesa : const Color(0xFFDDDDDD),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: selecionado ? Colors.white : Colors.black54,
          ),
        ),
      ),
    );
  }
}

/// Card individual do grid — estado "Glória" (desbloqueada) ou
/// "Mistério" (bloqueada).
class _ConquistaCard extends StatelessWidget {
  final ConquistaItem conquista;
  final VoidCallback onTap;

  const _ConquistaCard({required this.conquista, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cor = ConquistaIconMapper.colorFromHex(conquista.corHex);
    final icone = ConquistaIconMapper.resolve(conquista.iconeNome);

    if (conquista.desbloqueada) {
      return _buildDesbloqueada(cor, icone);
    }
    return _buildBloqueada(icone);
  }

  Widget _buildDesbloqueada(Color cor, IconData icone) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cor.withOpacity(0.08),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: cor.withOpacity(0.5), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: cor.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icone, size: 28, color: cor),
            ),
            const Spacer(),
            Text(
              conquista.nome,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.calendar_today_rounded, size: 11, color: cor.withOpacity(0.8)),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Conquistado em ${_formatarDataConquista(conquista.dataConquista)}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: cor.withOpacity(0.9),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBloqueada(IconData icone) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: 0.55,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFDDDDDD)),
          ),
          child: ColorFiltered(
            colorFilter: const ColorFilter.matrix(_grayscaleMatrix),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE0E0E0),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icone, size: 28, color: Colors.black38),
                    ),
                    Positioned(
                      right: -2,
                      bottom: -2,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.lock_rounded,
                          size: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  conquista.nome,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  conquista.descricao,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.black45,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Matriz de escala de cinza aplicada ao card bloqueado.
const List<double> _grayscaleMatrix = [
  0.2126, 0.7152, 0.0722, 0, 0,
  0.2126, 0.7152, 0.0722, 0, 0,
  0.2126, 0.7152, 0.0722, 0, 0,
  0, 0, 0, 1, 0,
];

/// Formata uma data ISO-8601 para o padrão dd/MM/aa usado nos cards
/// e no BottomSheet de detalhe.
String _formatarDataConquista(String? iso) {
  if (iso == null) return '--/--/--';
  final data = DateTime.tryParse(iso);
  if (data == null) return '--/--/--';
  final dia = data.day.toString().padLeft(2, '0');
  final mes = data.month.toString().padLeft(2, '0');
  final ano = (data.year % 100).toString().padLeft(2, '0');
  return '$dia/$mes/$ano';
}

class _ErroConquistasView extends StatelessWidget {
  final String mensagem;
  final VoidCallback onRetry;

  const _ErroConquistasView({required this.mensagem, required this.onRetry});

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
            const Text(
              'Não foi possível carregar suas conquistas.',
              style: TextStyle(fontSize: 15, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              mensagem,
              style: const TextStyle(fontSize: 12, color: Colors.black38),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _kTurquesa,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// BottomSheet exibido ao tocar em um card — conteúdo varia conforme
/// o estado da conquista (desbloqueada ou bloqueada).
class _ConquistaDetalheSheet extends StatefulWidget {
  final ConquistaItem conquista;

  const _ConquistaDetalheSheet({required this.conquista});

  @override
  State<_ConquistaDetalheSheet> createState() =>
      _ConquistaDetalheSheetState();
}

class _ConquistaDetalheSheetState extends State<_ConquistaDetalheSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scaleAnim = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
    if (widget.conquista.desbloqueada) {
      _controller.forward();
    } else {
      _controller.value = 1;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _compartilhar() {
    // TODO: integrar com share_plus quando o backend gerar a imagem/card
    // de compartilhamento da conquista.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Compartilhamento em breve! 🎉')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final conquista = widget.conquista;
    final cor = ConquistaIconMapper.colorFromHex(conquista.corHex);
    final icone = ConquistaIconMapper.resolve(conquista.iconeNome);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            ScaleTransition(
              scale: _scaleAnim,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: conquista.desbloqueada
                          ? cor.withOpacity(0.12)
                          : const Color(0xFFE0E0E0),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icone,
                      size: 52,
                      color: conquista.desbloqueada ? cor : Colors.black38,
                    ),
                  ),
                  if (!conquista.desbloqueada)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.lock_rounded,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              conquista.nome,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            if (conquista.desbloqueada) ..._buildDesbloqueadaBody(cor) else
              ..._buildBloqueadaBody(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildDesbloqueadaBody(Color cor) {
    final conquista = widget.conquista;
    return [
      Text(
        'Parabéns, você conquistou essa medalha! 🎉',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: cor,
        ),
      ),
      const SizedBox(height: 14),
      Text(
        conquista.descricao,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.black54,
          height: 1.4,
        ),
      ),
      const SizedBox(height: 6),
      Text(
        'Conquistado em ${_formatarDataConquista(conquista.dataConquista)}',
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.black38,
        ),
      ),
      const SizedBox(height: 24),
      SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _compartilhar,
          icon: const Icon(Icons.ios_share_rounded, size: 18),
          label: const Text('Compartilhar Conquista'),
          style: ElevatedButton.styleFrom(
            backgroundColor: cor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    ];
  }

  List<Widget> _buildBloqueadaBody() {
    final conquista = widget.conquista;
    return [
      const Text(
        'Medalha bloqueada',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: Colors.black54,
        ),
      ),
      const SizedBox(height: 14),
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF2F2F2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.flag_circle_rounded, size: 20, color: _kVermelho),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                conquista.descricao,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 8),
      const Text(
        'Continue explorando o estado para desbloquear esta medalha!',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 12, color: Colors.black38),
      ),
    ];
  }
}