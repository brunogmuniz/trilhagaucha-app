import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'sections/stats_page.dart';
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
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    StatsPage(),
    RotasPage(),
    ChecklistPage(),
    PerfilPage(),
    MenuPage(),
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
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}


class _AppHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return SizedBox(
      width: double.infinity,
      height: 90 + topPadding,
      child: Stack(
        children: [
          // Faixas diagonais via CustomPaint
          Positioned.fill(
            child: CustomPaint(
              painter: _HeaderStripesPainter(),
            ),
          ),
          Positioned.fill(
            top: topPadding,
            child: Center(
              child: Image.asset(
                'assets/images/logo.png',
                height: 54,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderStripesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final teal = Paint()..color = const Color(0xFF1F918B)..style = PaintingStyle.fill;
    final tealPath = Path()
      ..moveTo(0, 0)
      ..lineTo(w, 0)
      ..lineTo(w, h * 0.42)
      ..lineTo(0, h * 0.58)
      ..close();
    canvas.drawPath(tealPath, teal);

    final red = Paint()..color = const Color(0xFFEF4B4F)..style = PaintingStyle.fill;
    final redPath = Path()
      ..moveTo(0, h * 0.58)
      ..lineTo(w, h * 0.42)
      ..lineTo(w, h * 0.75)
      ..lineTo(0, h * 0.88)
      ..close();
    canvas.drawPath(redPath, red);

    final yellow = Paint()..color = const Color(0xFFFFEA61)..style = PaintingStyle.fill;
    final yellowPath = Path()
      ..moveTo(0, h * 0.88)
      ..lineTo(w, h * 0.75)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(yellowPath, yellow);
  }

  @override
  bool shouldRepaint(_HeaderStripesPainter old) => false;
}


enum _NavIcon { stats, rotas, checklist, perfil, menu }

class _NavItem {
  final _NavIcon icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _BottomNav({required this.currentIndex, required this.onTap});

  static const _items = [
    _NavItem(icon: _NavIcon.stats,     label: 'Stats'),
    _NavItem(icon: _NavIcon.rotas,     label: 'Rotas'),
    _NavItem(icon: _NavIcon.checklist, label: 'Checklist'),
    _NavItem(icon: _NavIcon.perfil,    label: 'Perfil'),
    _NavItem(icon: _NavIcon.menu,      label: 'Menu'),
  ];

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      color: Colors.white,
      child: SizedBox(
        height: 68 + bottomPadding,
        child: Column(
          children: [
            SizedBox(
              height: 68,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(_items.length, (i) {
                  final selected = i == currentIndex;
                  final item = _items[i];
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => onTap(i),
                      behavior: HitTestBehavior.opaque,
                      child: selected
                          ? _ActiveTile(item: item)
                          : _InactiveTile(item: item),
                    ),
                  );
                }),
              ),
            ),
            SizedBox(height: bottomPadding),
          ],
        ),
      ),
    );
  }
}

class _ActiveTile extends StatelessWidget {
  final _NavItem item;
  const _ActiveTile({required this.item});

  static const _activeColor = Color(0xFF1F918B);

  @override
  Widget build(BuildContext context) {
    return OverflowBox(
      alignment: Alignment.bottomCenter,
      maxHeight: 110,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: const BoxDecoration(
              color: _activeColor,
              borderRadius: BorderRadius.only(
                topLeft:     Radius.circular(40),
                topRight:    Radius.circular(40),
                bottomLeft:  Radius.circular(18),
                bottomRight: Radius.circular(18),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _NavIconWidget(icon: item.icon, color: Colors.white, size: 32),
                const SizedBox(height: 4),
                Text(
                  item.label,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
        ],
      ),
    );
  }
}

class _InactiveTile extends StatelessWidget {
  final _NavItem item;
  const _InactiveTile({required this.item});

  static const _inactiveColor = Color(0xFF9E9E9E);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _NavIconWidget(icon: item.icon, color: _inactiveColor, size: 30),
        const SizedBox(height: 4),
        Text(
          item.label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w400,
            color: _inactiveColor,
          ),
        ),
      ],
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
      case _NavIcon.stats:
        return CustomPaint(size: s, painter: _StatsPainter(color: color));
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

// Stats
class _StatsPainter extends CustomPainter {
  final Color color;
  _StatsPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final pts = [
      Offset(w * 0.05, h * 0.70),
      Offset(w * 0.22, h * 0.38),
      Offset(w * 0.42, h * 0.58),
      Offset(w * 0.62, h * 0.18),
      Offset(w * 0.82, h * 0.42),
      Offset(w * 0.95, h * 0.30),
    ];
    final area = Path()..moveTo(pts.first.dx, h * 0.95);
    for (final p in pts) area.lineTo(p.dx, p.dy);
    area.lineTo(pts.last.dx, h * 0.95);
    area.close();
    canvas.drawPath(area, Paint()..color = color.withOpacity(0.18)..style = PaintingStyle.fill);
    final line = Path()..moveTo(pts[0].dx, pts[0].dy);
    for (int i = 1; i < pts.length; i++) line.lineTo(pts[i].dx, pts[i].dy);
    canvas.drawPath(line, Paint()
      ..color = color..strokeWidth = 2.5..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round..style = PaintingStyle.stroke);
    final dot   = Paint()..color = color..style = PaintingStyle.fill;
    final dotBg = Paint()..color = Colors.white..style = PaintingStyle.fill;
    for (final p in [pts[1], pts[3], pts[5]]) {
      canvas.drawCircle(p, 3.5, dot);
      canvas.drawCircle(p, 1.8, dotBg);
    }
  }

  @override
  bool shouldRepaint(_StatsPainter o) => o.color != color;
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