import 'dart:math';
import 'package:flutter/material.dart';

/// A widget that renders a slowly changing colorful background
/// with floating bubbles for visual flair.
class AnimatedBackground extends StatefulWidget {
  const AnimatedBackground({Key? key}) : super(key: key);

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;
  final Random _random = Random();

  // A list of bubble positions and sizes for demonstration
  final List<_Bubble> _bubbles = [];

  @override
  void initState() {
    super.initState();
    // Animation controller for color transitions
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);

    // Color tween between two vibrant gradients or solid colors
    _colorAnimation = ColorTween(
      begin: Colors.deepPurple,
      end: Colors.deepOrange,
    ).animate(_controller);

    // Create some random bubbles
    for (int i = 0; i < 15; i++) {
      _bubbles.add(
        _Bubble(
          x: _random.nextDouble(),
          y: _random.nextDouble(),
          radius: _random.nextDouble() * 30 + 10,
          speed: _random.nextDouble() * 0.001 + 0.0005,
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Move bubbles upward in a loop
  void _moveBubbles() {
    for (final bubble in _bubbles) {
      bubble.y -= bubble.speed;
      if (bubble.y < -0.1) {
        bubble.y = 1.1; // reset to bottom
        bubble.x = _random.nextDouble();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        _moveBubbles();
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _colorAnimation.value ?? Colors.deepPurple,
                Colors.blue,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: CustomPaint(
            painter: _BubblePainter(_bubbles),
            child: Container(),
          ),
        );
      },
    );
  }
}

/// A simple model class for bubble properties.
class _Bubble {
  double x;
  double y;
  double radius;
  double speed;

  _Bubble({
    required this.x,
    required this.y,
    required this.radius,
    required this.speed,
  });
}

/// Custom painter that draws bubbles on the canvas.
class _BubblePainter extends CustomPainter {
  final List<_Bubble> bubbles;
  _BubblePainter(this.bubbles);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.4);
    for (final bubble in bubbles) {
      final dx = bubble.x * size.width;
      final dy = bubble.y * size.height;
      canvas.drawCircle(Offset(dx, dy), bubble.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Второй вариант анимированного фона.
/// Пример: цвета меняются от зелёного к синему, а по экрану летят квадраты.
class AnimatedBackground2 extends StatefulWidget {
  const AnimatedBackground2({Key? key}) : super(key: key);

  @override
  State<AnimatedBackground2> createState() => _AnimatedBackground2State();
}

class _AnimatedBackground2State extends State<AnimatedBackground2>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;
  final Random _random = Random();

  final List<_Square> _squares = [];

  @override
  void initState() {
    super.initState();
    // Контроллер для анимации цвета
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);

    _colorAnimation = ColorTween(
      begin: Colors.green,
      end: Colors.blue,
    ).animate(_controller);

    // Инициируем «квадратики»
    for (int i = 0; i < 15; i++) {
      _squares.add(
        _Square(
          x: _random.nextDouble(),
          y: _random.nextDouble(),
          size: _random.nextDouble() * 20 + 10,
          speed: _random.nextDouble() * 0.002 + 0.0008,
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _moveSquares() {
    for (final sqr in _squares) {
      sqr.y -= sqr.speed;
      if (sqr.y < -0.1) {
        sqr.y = 1.1; // «перезагрузка» квадрата снизу
        sqr.x = _random.nextDouble();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        _moveSquares();
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _colorAnimation.value ?? Colors.green,
                Colors.lightBlueAccent,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: CustomPaint(
            painter: _SquarePainter(_squares),
            child: Container(),
          ),
        );
      },
    );
  }
}

class _Square {
  double x;
  double y;
  double size;
  double speed;

  _Square({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
  });
}

/// Painter, который рисует квадраты
class _SquarePainter extends CustomPainter {
  final List<_Square> squares;
  _SquarePainter(this.squares);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.5);
    for (final sqr in squares) {
      final dx = sqr.x * size.width;
      final dy = sqr.y * size.height;
      final rect = Rect.fromLTWH(dx, dy, sqr.size, sqr.size);
      canvas.drawRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Третий вариант анимированного фона.
/// Например, цвета - от бирюзового к оранжевому, а по экрану «летают» цветные круги.
class AnimatedBackground3 extends StatefulWidget {
  const AnimatedBackground3({Key? key}) : super(key: key);

  @override
  State<AnimatedBackground3> createState() => _AnimatedBackground3State();
}

class _AnimatedBackground3State extends State<AnimatedBackground3>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;
  final Random _random = Random();

  final List<_Circle> _circles = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);

    _colorAnimation = ColorTween(
      begin: Colors.teal,
      end: Colors.amber,
    ).animate(_controller);

    // Инициируем набор кружков
    for (int i = 0; i < 20; i++) {
      _circles.add(
        _Circle(
          x: _random.nextDouble(),
          y: _random.nextDouble(),
          radius: _random.nextDouble() * 25 + 5,
          speed: _random.nextDouble() * 0.001 + 0.0003,
          color: Color.lerp(
            Colors.white,
            Colors.pinkAccent,
            _random.nextDouble(),
          )!
              .withOpacity(0.5),
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _moveCircles() {
    for (final circle in _circles) {
      circle.y -= circle.speed;
      if (circle.y < -0.1) {
        circle.y = 1.1;
        circle.x = _random.nextDouble();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        _moveCircles();
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _colorAnimation.value ?? Colors.teal,
                Colors.lightBlue,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: CustomPaint(
            painter: _CirclePainter(_circles),
            child: Container(),
          ),
        );
      },
    );
  }
}

class _Circle {
  double x;
  double y;
  double radius;
  double speed;
  Color color;

  _Circle({
    required this.x,
    required this.y,
    required this.radius,
    required this.speed,
    required this.color,
  });
}

class _CirclePainter extends CustomPainter {
  final List<_Circle> circles;
  _CirclePainter(this.circles);

  @override
  void paint(Canvas canvas, Size size) {
    for (final circle in circles) {
      final paint = Paint()..color = circle.color;
      final dx = circle.x * size.width;
      final dy = circle.y * size.height;
      canvas.drawCircle(Offset(dx, dy), circle.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
