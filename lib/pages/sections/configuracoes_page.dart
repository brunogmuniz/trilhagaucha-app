import 'package:flutter/material.dart';
import 'configuracoes/editar_perfil_page.dart';
import 'configuracoes/alterar_senha_page.dart';

class ConfiguracoesPage extends StatefulWidget {
  const ConfiguracoesPage({super.key});

  @override
  State<ConfiguracoesPage> createState() => _ConfiguracoesPageState();
}

class _ConfiguracoesPageState extends State<ConfiguracoesPage> {
  bool _notificacoesAtivas = true;
  bool _modoEscuro = false;

  void _confirmarExclusaoConta() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir Conta', style: TextStyle(color: Colors.red)),
        content: const Text(
            'Tem certeza que deseja excluir sua conta permanentemente? Esta ação não pode ser desfeita e todos os seus dados serão perdidos.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar', style: TextStyle(color: Colors.black87)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(ctx);
              // TODO: Implementar a chamada na API para deletar a conta
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Conta excluída (Simulação)')),
              );
            },
            child: const Text('Sim, excluir', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _sairDaConta() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sair da conta'),
        content: const Text('Deseja realmente sair do aplicativo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar', style: TextStyle(color: Colors.black87)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1F918B)),
            onPressed: () {
              Navigator.pop(ctx);
              // TODO: Limpar o SessionService e redirecionar para a tela de Login
            },
            child: const Text('Sair', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
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
        title: const Text('Configurações',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Colors.black87)),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFEEEEEE), height: 1),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          _SectionTitle(title: 'Conta'),
          _ConfigMenuTile(
            icon: Icons.person_outline,
            title: 'Editar Perfil',
            subtitle: 'Altere seu nome, sobrenome e cidade',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EditarPerfilPage()),
            ),
          ),
          _ConfigMenuTile(
            icon: Icons.lock_outline,
            title: 'Alterar Senha',
            subtitle: 'Atualize sua senha de acesso',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AlterarSenhaPage()),
            ),
          ),

          const SizedBox(height: 24),
          _SectionTitle(title: 'Preferências'),
          SwitchListTile(
            activeColor: const Color(0xFF1F918B),
            secondary: const Icon(Icons.notifications_none, color: Colors.black87),
            title: const Text('Notificações', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
            subtitle: const Text('Receber alertas de trilhas', style: TextStyle(fontSize: 13)),
            value: _notificacoesAtivas,
            onChanged: (val) => setState(() => _notificacoesAtivas = val),
          ),
          SwitchListTile(
            activeColor: const Color(0xFF1F918B),
            secondary: const Icon(Icons.dark_mode_outlined, color: Colors.black87),
            title: const Text('Modo Escuro', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
            value: _modoEscuro,
            onChanged: (val) => setState(() => _modoEscuro = val),
          ),

          const SizedBox(height: 24),
          _SectionTitle(title: 'Ações da Conta'),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.black87),
            title: const Text('Sair da conta', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
            onTap: _sairDaConta,
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text('Excluir conta', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.red)),
            onTap: _confirmarExclusaoConta,
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: 20, bottom: 8, top: 8),
    child: Text(title.toUpperCase(),
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
            color: Colors.black45, letterSpacing: 1.0)),
  );
}

class _ConfigMenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _ConfigMenuTile({required this.icon, required this.title, this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.black87),
      title: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
      subtitle: subtitle != null ? Text(subtitle!, style: const TextStyle(fontSize: 13)) : null,
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.black38),
      onTap: onTap,
    );
  }
}