import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../login_page.dart';
import 'configuracoes_page.dart';
import 'package:url_launcher/url_launcher.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  Future<void> _fazerLogout(BuildContext context) async {
    try {
      await AuthService().logout();
      if (!context.mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
            (route) => false,
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Erro ao sair: ${e.toString()}'),
        backgroundColor: const Color(0xFFE84040),
      ));
    }
  }

  void _mostrarDialogoSair(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Sair da conta',
            style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black87)),
        content: const Text('Tem certeza que deseja encerrar a sua sessão?',
            style: TextStyle(color: Colors.black54)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar',
                style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w500)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE84040),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _fazerLogout(context);
            },
            child: const Text('Sair', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  // Função renomeada para o Apoia.se
  Future<void> _abrirApoiase() async {
    final Uri url = Uri.parse(
      'https://apoia.se/trillhagaucha',
    );

    await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 20),
          child: Text('Menu',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.black87)),
        ),

        _buildMenuGroup([
          _MenuItem(
            icon: Icons.settings_outlined,
            label: 'Configurações',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ConfiguracoesPage()),
            ),
          ),
        ]),
        const SizedBox(height: 16),

        _buildMenuGroup([
          _MenuItem(icon: Icons.help_outline, label: 'Ajuda e Suporte', onTap: () {}),
          _MenuItem(icon: Icons.shield_outlined, label: 'Privacidade e Termos', onTap: () {}),
          _MenuItem(icon: Icons.info_outline, label: 'Sobre o App', onTap: () {}),
          _MenuItem(
            icon: Icons.favorite_outline_rounded, // Ícone de coração para o Apoia.se
            label: 'Apoia.se',
            iconColor: const Color(0xFFEF4B4F), // Vermelho
            onTap: _abrirApoiase,
          ),
        ]),
        const SizedBox(height: 16),

        _buildMenuGroup([
          _MenuItem(
            icon: Icons.logout_rounded,
            label: 'Sair',
            textColor: const Color(0xFFE84040),
            iconColor: const Color(0xFFE84040),
            hideArrow: true,
            onTap: () => _mostrarDialogoSair(context),
          ),
        ]),

        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildMenuGroup(List<_MenuItem> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDDDDDD)),
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final isLast = entry.key == items.length - 1;
          return Column(children: [
            entry.value,
            if (!isLast)
              const Divider(height: 1, thickness: 1,
                  color: Color(0xFFF2F2F2), indent: 52, endIndent: 16),
          ]);
        }).toList(),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? textColor;
  final Color? iconColor;
  final bool hideArrow;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.textColor,
    this.iconColor,
    this.hideArrow = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(children: [
            Icon(icon, size: 22, color: iconColor ?? const Color(0xFF1F918B)),
            const SizedBox(width: 14),
            Expanded(child: Text(label,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500,
                    color: textColor ?? Colors.black87))),
            if (!hideArrow)
              const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.black26),
          ]),
        ),
      ),
    );
  }
}