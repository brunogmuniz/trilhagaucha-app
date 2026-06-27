import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'sections/conquista_page.dart' show ConquistaPage;
import 'sections/conquista_page.dart';
import 'sections/rotas_page.dart';
import 'sections/checklist_page.dart';
import 'sections/perfil_page.dart';
import 'sections/menu_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 2;

  Key _perfilKey = UniqueKey();

  List<Widget> get _pages => [
    const ConquistaPage(),
    const RotasPage(),
    const ChecklistPage(),
    PerfilPage(key: _perfilKey),
    const MenuPage(),
  ];

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      extendBodyBehindAppBar: false,

      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(90),
        child: _AppHeader(),
      ),

      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),

      bottomNavigationBar: _BottomNav(
        currentIndex: _currentIndex,
        onTap: (i) {
          setState(() {
            _currentIndex = i;
            if (i == 3) {
              _perfilKey = UniqueKey();
            }
          });
        },
      ),
    );
  }
}

class _AppHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      height: 90 + topPadding,
      padding: EdgeInsets.only(top: topPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(
            'assets/images/logo.png',
            height: 48,
          ),
          Positioned(
            bottom: 0,
            left: 32,
            right: 32,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Row(
                children: [
                  Expanded(child: Container(height: 3, color: const Color(0xFF1F918B))),
                  Expanded(child: Container(height: 3, color: const Color(0xFFFFEA61))),
                  Expanded(child: Container(height: 3, color: const Color(0xFFEF4B4F))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


enum _NavIcon { conquistas, rotas, checklist, perfil, menu }

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _BottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    const double barHeight = 70.0;
    const double buttonOverflow = 28.0;

    return Container(
      height: barHeight + buttonOverflow + bottomPadding,
      color: Colors.transparent,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            height: barHeight + bottomPadding,
            padding: EdgeInsets.only(bottom: bottomPadding),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 20,
                  offset: const Offset(0, -6),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSideTab(0, _NavIcon.conquistas, 'Conquistas'),
                _buildSideTab(1, _NavIcon.rotas, 'Rotas'),
                const SizedBox(width: 76),
                _buildSideTab(3, _NavIcon.perfil, 'Perfil'),
                _buildSideTab(4, _NavIcon.menu, 'Menu'),
              ],
            ),
          ),

          Positioned(
            top: 0,
            child: GestureDetector(
              onTap: () => onTap(2),
              child: _buildCenterButton(currentIndex == 2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSideTab(int index, _NavIcon icon, String label) {
    final isActive = currentIndex == index;
    final color = isActive ? const Color(0xFF1F918B) : const Color(0xFF9E9E9E);

    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              height: isActive ? 28 : 24,
              alignment: Alignment.center,
              child: _NavIconWidget(icon: icon, color: color, size: isActive ? 26 : 24),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: color,
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(top: 4),
              height: 4,
              width: isActive ? 4 : 0,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterButton(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: const Color(0xFF1F918B),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFF2F2F2), width: 6), // Borda cinza do fundo
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1F918B).withOpacity(isActive ? 0.6 : 0.3),
            blurRadius: isActive ? 16 : 8,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: const Center(
        child: _NavIconWidget(
          icon: _NavIcon.checklist,
          color: Colors.white,
          size: 32,
        ),
      ),
    );
  }
}


class _NavIconWidget extends StatelessWidget {
  final _NavIcon icon;
  final Color color;
  final double size;

  const _NavIconWidget({
    super.key,
    required this.icon,
    required this.color,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final s = Size(size, size);
    switch (icon) {
      case _NavIcon.conquistas:
        return CustomPaint(size: s, painter: _ConquistasPainter(color: color));
      case _NavIcon.rotas:
        return CustomPaint(size: s, painter: _RotasPainter(color: color));
      case _NavIcon.checklist:
        return CustomPaint(size: s, painter: _ChecklistPainter(color: color));
      case _NavIcon.perfil:
        return CustomPaint(size: s, painter: _PerfilPainter(color: color));
      case _NavIcon.menu:
        return CustomPaint(size: s, painter: _MenuPainter(color: color));
    }
  }
}

class _ConquistasPainter extends CustomPainter {
  final Color color;
  _ConquistasPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final fill = Paint()..color = color..style = PaintingStyle.fill;
    final stroke = Paint()
      ..color = color
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    // Taça
    final cup = Path()
      ..moveTo(w * 0.28, h * 0.16)
      ..lineTo(w * 0.72, h * 0.16)
      ..lineTo(w * 0.66, h * 0.52)
      ..quadraticBezierTo(w * 0.5, h * 0.62, w * 0.34, h * 0.52)
      ..close();
    canvas.drawPath(cup, fill);

    // Alças laterais
    final leftHandle = Path()
      ..moveTo(w * 0.28, h * 0.22)
      ..quadraticBezierTo(w * 0.04, h * 0.22, w * 0.10, h * 0.42)
      ..quadraticBezierTo(w * 0.16, h * 0.54, w * 0.32, h * 0.50);
    canvas.drawPath(leftHandle, stroke);

    final rightHandle = Path()
      ..moveTo(w * 0.72, h * 0.22)
      ..quadraticBezierTo(w * 0.96, h * 0.22, w * 0.90, h * 0.42)
      ..quadraticBezierTo(w * 0.84, h * 0.54, w * 0.68, h * 0.50);
    canvas.drawPath(rightHandle, stroke);

    // Pé da taça
    canvas.drawRect(
      Rect.fromLTWH(w * 0.46, h * 0.58, w * 0.08, h * 0.14),
      fill,
    );

    // Base
    final base = Path()
      ..moveTo(w * 0.30, h * 0.88)
      ..lineTo(w * 0.70, h * 0.88)
      ..lineTo(w * 0.64, h * 0.72)
      ..lineTo(w * 0.36, h * 0.72)
      ..close();
    canvas.drawPath(base, fill);
  }

  @override
  bool shouldRepaint(_ConquistasPainter o) => o.color != color;
}

class _RotasPainter extends CustomPainter {
  final Color color;
  _RotasPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final fill = Paint()..color = color..style = PaintingStyle.fill;
    _drawPin(canvas, fill, Offset(w * 0.27, h * 0.13), w * 0.22);
    _drawPin(canvas, fill, Offset(w * 0.73, h * 0.55), w * 0.19);
    final dashPaint = Paint()..color = color..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round..style = PaintingStyle.stroke;
    final curvePath = Path()
      ..moveTo(w * 0.27, h * 0.42)
      ..cubicTo(w * 0.27, h * 0.70, w * 0.73, h * 0.45, w * 0.73, h * 0.75);
    _drawDashedPath(canvas, dashPaint, curvePath);
  }

  void _drawPin(Canvas canvas, Paint fill, Offset center, double r) {
    canvas.drawPath(Path()..addOval(Rect.fromCircle(center: center, radius: r * 0.58)), fill);
    canvas.drawPath(
      Path()
        ..moveTo(center.dx - r * 0.32, center.dy + r * 0.38)
        ..quadraticBezierTo(center.dx, center.dy + r * 1.28, center.dx + r * 0.32, center.dy + r * 0.38)
        ..close(),
      fill,
    );
    canvas.drawCircle(center, r * 0.25, Paint()..color = Colors.white..style = PaintingStyle.fill);
  }

  void _drawDashedPath(Canvas canvas, Paint paint, Path path) {
    const dash = 5.0, gap = 4.0;
    for (final m in path.computeMetrics()) {
      double d = 0;
      while (d < m.length) {
        canvas.drawPath(m.extractPath(d, (d + dash).clamp(0, m.length)), paint);
        d += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(_RotasPainter o) => o.color != color;
}

class _ChecklistPainter extends CustomPainter {
  final Color color;
  _ChecklistPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final paint = Paint()..color = color..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round..style = PaintingStyle.stroke;
    _drawCheck(canvas, paint, Offset(w * 0.06, h * 0.20), w * 0.20, h * 0.20);
    canvas.drawLine(Offset(w * 0.36, h * 0.30), Offset(w * 0.92, h * 0.30), paint);
    _drawCheck(canvas, paint, Offset(w * 0.06, h * 0.58), w * 0.20, h * 0.20);
    canvas.drawLine(Offset(w * 0.36, h * 0.68), Offset(w * 0.92, h * 0.68), paint);
  }

  void _drawCheck(Canvas canvas, Paint p, Offset o, double sw, double sh) {
    canvas.drawPath(
      Path()
        ..moveTo(o.dx, o.dy + sh * 0.48)
        ..lineTo(o.dx + sw * 0.38, o.dy + sh)
        ..lineTo(o.dx + sw, o.dy),
      p,
    );
  }

  @override
  bool shouldRepaint(_ChecklistPainter o) => o.color != color;
}

class _PerfilPainter extends CustomPainter {
  final Color color;
  _PerfilPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final fill = Paint()..color = color..style = PaintingStyle.fill;
    final w = size.width;
    final h = size.height;
    canvas.drawCircle(Offset(w / 2, h * 0.30), w * 0.24, fill);
    canvas.drawPath(
      Path()
        ..moveTo(0, h)
        ..quadraticBezierTo(0, h * 0.58, w / 2, h * 0.58)
        ..quadraticBezierTo(w, h * 0.58, w, h)
        ..close(),
      fill,
    );
  }

  @override
  bool shouldRepaint(_PerfilPainter o) => o.color != color;
}

class _MenuPainter extends CustomPainter {
  final Color color;
  _MenuPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round..style = PaintingStyle.stroke;
    final w = size.width;
    final h = size.height;
    canvas.drawLine(Offset(w * 0.18, h * 0.25), Offset(w * 0.82, h * 0.25), paint);
    canvas.drawLine(Offset(w * 0.08, h * 0.50), Offset(w * 0.92, h * 0.50), paint);
    canvas.drawLine(Offset(w * 0.18, h * 0.75), Offset(w * 0.82, h * 0.75), paint);
  }

  @override
  bool shouldRepaint(_MenuPainter o) => o.color != color;
}