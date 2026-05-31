import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/session_service.dart';
import '../../models/usuario.dart';
import '../../services/checklist_service.dart';
import '../../services/cidade_service.dart';

class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key});

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  final AuthService _authService = AuthService();
  final ChecklistService _checklistService = ChecklistService();
  final CidadeService _cidadeService = CidadeService();

  String? _ultimaCidade;
  String _porcentagemRS = '0%';

  bool _loading = true;
  String? _erro;
  Usuario? _usuario;

  final List<Color> _coresAvatar = const [
    Color(0xFF1F918B),
    Color(0xFFEF4B4F),
    Color(0xFFF39C12),
    Color(0xFF2C3E50),
    Color(0xFF8E44AD),
  ];

  late Color _corSelecionada;

  @override
  void initState() {
    super.initState();
    _corSelecionada = _coresAvatar[0]; // Cor padrão (Mockada por enquanto)
    _carregarPerfil();
  }

  Future<void> _carregarPerfil() async {
    setState(() {
      _loading = true;
      _erro = null;
    });

    try {
      final uuid = await SessionService.getUuid();
      if (uuid != null && uuid.isNotEmpty) {

        final resultados = await Future.wait([
          _authService.buscarUsuarioPorUuid(uuid),
          _checklistService.buscarUltimaCidadeVisitada(uuid),
          _cidadeService.listarCidades(),
          _checklistService.buscarPorUsuario(uuid),
        ]);

        setState(() {
          _usuario = resultados[0] as Usuario;
          _ultimaCidade = resultados[1] as String?;

          // Removida a lógica de puxar a corAvatar do banco (Mockado)

          // Lógica para calcular a % do RS visitado
          final cidades = resultados[2] as List;
          final checklist = resultados[3] as List;

          final total = cidades.length;
          int marcadas = 0;
          for (final item in checklist) {
            if (item.visitado == true) {
              marcadas++;
            }
          }
          final progresso = total == 0 ? 0.0 : marcadas / total;
          _porcentagemRS = '${(progresso * 100).toStringAsFixed(0)}%';

          _loading = false;
        });
      } else {
        throw Exception('Usuário não encontrado na sessão.');
      }
    } catch (e) {
      setState(() {
        _erro = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  // Função mockada: apenas atualiza o estado local
  void _atualizarCorAvatar(Color cor) {
    setState(() {
      _corSelecionada = cor;
    });
    // TODO Futuro: Chamar o endpoint no backend para salvar a cor
  }

  String _formatarDataCadastro() {
    final data = _usuario?.dataCadastro;
    if (data == null) {
      return 'Não informada';
    }
    return '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}';
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF1F918B)),
      );
    }

    if (_erro != null) {
      return Center(
        child: Text('Erro ao carregar perfil:\n$_erro', textAlign: TextAlign.center),
      );
    }

    final inicial = _usuario?.nome.isNotEmpty == true
        ? _usuario!.nome[0].toUpperCase()
        : '?';

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      physics: const BouncingScrollPhysics(),
      children: [
        Column(
          children: [
            CircleAvatar(
              radius: 46,
              backgroundColor: _corSelecionada,
              child: Text(
                inicial,
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '${_usuario?.nome} ${_usuario?.sobrenome}',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _usuario?.email ?? '',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: const Color(0xFFDDDDDD)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: _coresAvatar.map((cor) {
                final selecionada = cor == _corSelecionada;
                return GestureDetector(
                  onTap: () => _atualizarCorAvatar(cor),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: cor,
                      shape: BoxShape.circle,
                      border: selecionada
                          ? Border.all(color: Colors.black54, width: 2.5)
                          : null,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),

        const SizedBox(height: 32),

        Row(
          children: [
            Expanded(
              child: _EstatisticaCard(
                icon: Icons.place_rounded,
                titulo: 'Última cidade',
                valor: _ultimaCidade ?? '-',
                cor: const Color(0xFF1F918B),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _EstatisticaCard(
                icon: Icons.explore_rounded,
                titulo: 'RS Explorado',
                valor: _porcentagemRS,
                cor: const Color(0xFFEF4B4F),
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        const Text(
          'DADOS PESSOAIS',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Colors.black38,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              _CampoLeitura(label: 'Nome', valor: _usuario?.nome ?? ''),
              const Divider(height: 24, color: Color(0xFFF2F2F2)),
              _CampoLeitura(label: 'Sobrenome', valor: _usuario?.sobrenome ?? ''),
              const Divider(height: 24, color: Color(0xFFF2F2F2)),
              _CampoLeitura(label: 'E-mail', valor: _usuario?.email ?? ''),
              const Divider(height: 24, color: Color(0xFFF2F2F2)),
              _CampoLeitura(label: 'Membro desde', valor: _formatarDataCadastro()),
            ],
          ),
        ),

        const SizedBox(height: 40),
      ],
    );
  }
}

class _EstatisticaCard extends StatelessWidget {
  final IconData icon;
  final String titulo;
  final String valor;
  final Color cor;

  const _EstatisticaCard({
    required this.icon,
    required this.titulo,
    required this.valor,
    required this.cor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: cor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            titulo,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: cor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            valor,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _CampoLeitura extends StatelessWidget {
  final String label;
  final String valor;

  const _CampoLeitura({required this.label, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          ),
        ),
        Expanded(
          child: Text(
            valor,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}