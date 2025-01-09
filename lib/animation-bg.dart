import 'dart:math';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

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

class NorthernLightsAnimation extends StatefulWidget {
  const NorthernLightsAnimation({Key? key}) : super(key: key);

  @override
  _NorthernLightsAnimationState createState() =>
      _NorthernLightsAnimationState();
}

class _NorthernLightsAnimationState extends State<NorthernLightsAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _waveAnimation;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);

    _waveAnimation = Tween<double>(begin: 0, end: 2 * pi).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _NorthernLightsPainter(
            waveProgress: _waveAnimation.value,
            random: _random,
          ),
          child: Container(),
        );
      },
    );
  }
}

class _NorthernLightsPainter extends CustomPainter {
  final double waveProgress;
  final Random random;

  _NorthernLightsPainter({required this.waveProgress, required this.random});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(0, size.height / 3),
        Offset(size.width, size.height),
        [
          Colors.blue.withOpacity(0.2),
          Colors.green.withOpacity(0.4),
          Colors.purple.withOpacity(0.3),
        ],
        [0.0, 0.5, 1.0],
        TileMode.clamp,
      );

    final path = Path();

    for (double x = 0; x <= size.width; x += 10) {
      final y = size.height / 2 +
          sin(waveProgress + x * 0.02) * 50 +
          sin(waveProgress + x * 0.1) * 10;
      if (x == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class VerticalAuroraAnimation extends StatefulWidget {
  const VerticalAuroraAnimation({Key? key}) : super(key: key);

  @override
  _VerticalAuroraAnimationState createState() =>
      _VerticalAuroraAnimationState();
}

class _VerticalAuroraAnimationState extends State<VerticalAuroraAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<AuroraBar> _bars;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);

    // Генерация полос
    _bars = List.generate(
      20,
      (index) => AuroraBar(
        baseHeight: Random().nextDouble() * 100 + 50,
        amplitude: Random().nextDouble() * 50 + 30,
        color: Color.lerp(
          Colors.blue,
          Colors.purple,
          Random().nextDouble(),
        )!,
        offset: Random().nextDouble() * pi * 2,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _AuroraBarsPainter(
            bars: _bars,
            animationValue: _controller.value,
          ),
          child: Container(),
        );
      },
    );
  }
}

class AuroraBar {
  final double baseHeight;
  final double amplitude;
  final Color color;
  final double offset;

  AuroraBar({
    required this.baseHeight,
    required this.amplitude,
    required this.color,
    required this.offset,
  });
}

class _AuroraBarsPainter extends CustomPainter {
  final List<AuroraBar> bars;
  final double animationValue;

  _AuroraBarsPainter({required this.bars, required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final barWidth = size.width / bars.length;

    for (int i = 0; i < bars.length; i++) {
      final bar = bars[i];
      final height = bar.baseHeight +
          sin(animationValue * 2 * pi + bar.offset) * bar.amplitude;

      final left = i * barWidth;
      final right = left + barWidth * 0.8; // Узкая полоска

      paint.shader = LinearGradient(
        colors: [
          bar.color.withOpacity(0.2),
          bar.color.withOpacity(0.6),
          bar.color.withOpacity(0.9),
        ],
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
      ).createShader(
          Rect.fromLTRB(left, size.height - height, right, size.height));

      canvas.drawRect(
        Rect.fromLTRB(left, size.height - height, right, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class PulsatingCirclesBackground extends StatefulWidget {
  const PulsatingCirclesBackground({Key? key}) : super(key: key);

  @override
  _PulsatingCirclesBackgroundState createState() =>
      _PulsatingCirclesBackgroundState();
}

class _PulsatingCirclesBackgroundState extends State<PulsatingCirclesBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<CircleWave> _waves;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 50),
    )..repeat(reverse: true);

    // Генерация кругов
    _waves = List.generate(
      12,
      (index) => CircleWave(
        center: Offset(
          Random().nextDouble() * 1.2 -
              0.1, // центр X (чуть больше 1 для выхода за границу)
          Random().nextDouble() * 1.2 - 0.1, // центр Y
        ),
        baseRadius: Random().nextDouble() * 40 + 60, // базовый радиус
        amplitude: Random().nextDouble() * 30 + 20, // изменение радиуса
        color: Color.lerp(
          Colors.blue,
          Colors.pinkAccent,
          Random().nextDouble(),
        )!
            .withOpacity(0.5),
        speed: Random().nextDouble() * 0.5 + 0.5, // скорость
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _PulsatingCirclesPainter(
            waves: _waves,
            animationValue: _controller.value,
          ),
          child: Container(),
        );
      },
    );
  }
}

class CircleWave {
  final Offset center;
  final double baseRadius;
  final double amplitude;
  final Color color;
  final double speed;

  CircleWave({
    required this.center,
    required this.baseRadius,
    required this.amplitude,
    required this.color,
    required this.speed,
  });
}

class _PulsatingCirclesPainter extends CustomPainter {
  final List<CircleWave> waves;
  final double animationValue;

  _PulsatingCirclesPainter({required this.waves, required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (final wave in waves) {
      final radius = wave.baseRadius +
          sin(animationValue * wave.speed * 2 * pi) * wave.amplitude;

      final center = Offset(
        wave.center.dx * size.width,
        wave.center.dy * size.height,
      );

      paint.color = wave.color.withOpacity(
        0.5 +
            0.3 *
                sin(animationValue * wave.speed * 2 * pi), // Пульсация яркости
      );

      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class FractalAurora extends StatefulWidget {
  const FractalAurora({Key? key}) : super(key: key);

  @override
  State<FractalAurora> createState() => _FractalAuroraState();
}

class _FractalAuroraState extends State<FractalAurora>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final Random _random = Random();

  final List<_Fractal> _fractals = [];

  @override
  void initState() {
    super.initState();
    // Создаем контроллер с длительной анимацией
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 300), // Очень медленная анимация
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);

    // Генерируем фракталы
    for (int i = 0; i < 10; i++) {
      _fractals.add(
        _Fractal(
          x: _random.nextDouble(),
          y: _random.nextDouble(),
          scale: _random.nextDouble() * 0.5 + 0.5,
          color: _generateAuroraColor(),
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _generateAuroraColor() {
    final colors = [
      Colors.green.withOpacity(0.3),
      Colors.blue.withOpacity(0.3),
      Colors.purple.withOpacity(0.3),
      Colors.cyan.withOpacity(0.3),
    ];
    return colors[_random.nextInt(colors.length)];
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          painter: _FractalPainter(_fractals, _animation.value),
          child: Container(),
        );
      },
    );
  }
}

class _Fractal {
  double x;
  double y;
  double scale;
  Color color;

  _Fractal({
    required this.x,
    required this.y,
    required this.scale,
    required this.color,
  });
}

class _FractalPainter extends CustomPainter {
  final List<_Fractal> fractals;
  final double progress;

  _FractalPainter(this.fractals, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    for (final fractal in fractals) {
      final paint = Paint()
        ..color = fractal.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;

      // Центр и радиус для фракталов
      final centerX = fractal.x * size.width;
      final centerY = fractal.y * size.height;
      final baseRadius = fractal.scale * size.width * 0.2;

      // Рисуем концентрические круги
      for (int i = 0; i < 5; i++) {
        final radius = baseRadius * (1 + i * 0.2) * (1 + progress * 0.1);
        canvas.drawCircle(Offset(centerX, centerY), radius, paint);
      }

      // Добавляем небольшие сдвиги для эффекта движения
      fractal.x += (progress - 0.5) * 0.001;
      fractal.y += (progress - 0.5) * 0.001;

      // Перезапуск фракталов, если они уходят за границы
      if (fractal.x < 0 || fractal.x > 1 || fractal.y < 0 || fractal.y > 1) {
        fractal.x = Random().nextDouble();
        fractal.y = Random().nextDouble();
        fractal.color = Color.lerp(fractal.color, _generateAuroraColor(), 0.5)!;
      }
    }
  }

  Color _generateAuroraColor() {
    final colors = [
      Colors.green.withOpacity(0.3),
      Colors.blue.withOpacity(0.3),
      Colors.purple.withOpacity(0.3),
      Colors.cyan.withOpacity(0.3),
    ];
    return colors[Random().nextInt(colors.length)];
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

////////// GAME! ////

class AuroraCatcherPage extends StatefulWidget {
  const AuroraCatcherPage({Key? key}) : super(key: key);

  @override
  State<AuroraCatcherPage> createState() => _AuroraCatcherPageState();
}

class _AuroraCatcherPageState extends State<AuroraCatcherPage> {
  final Random _random = Random();
  final List<_Particle> _particles = [];
  Offset _playerPosition = Offset(200, 400);
  Offset _lastDragPosition = Offset(200, 400);
  double _playerRadius = 30;
  int _energy = 50;
  int _score = 0;
  int _bestScore = 0;
  int _minEnergy = 0;
  int _maxEnergy = 100;
  late Timer _particleTimer;
  late Timer _gameTimer;
  late Timer _shrinkTimer;

  @override
  void initState() {
    super.initState();
    _loadBestScore();
    _startGame();
  }

  Future<void> _loadBestScore() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _bestScore = prefs.getInt('bestScoreAuroraCatcher') ?? 0;
    });
  }

  Future<void> _saveBestScore() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('bestScoreAuroraCatcher', _bestScore);
  }

  void _startGame() {
    _particles.clear();
    _energy = 50;
    _playerRadius = 30;
    _playerPosition = Offset(200, 400);
    _lastDragPosition = Offset(200, 400);
    _minEnergy = 0;
    _maxEnergy = 100;
    _score = 0;
    _particleTimer =
        Timer.periodic(const Duration(milliseconds: 400), _generateParticle);
    _gameTimer = Timer.periodic(const Duration(milliseconds: 16),
        (_) => setState(() => _updateParticles()));
    _shrinkTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (_minEnergy < 49 && _maxEnergy > 51) {
        setState(() {
          _minEnergy++;
          _maxEnergy--;
        });
      }
    });
    setState(() {});
  }

  void _endGame() {
    _particleTimer.cancel();
    _gameTimer.cancel();
    _shrinkTimer.cancel();
    if (_score > _bestScore) {
      setState(() {
        _bestScore = _score;
      });
      _saveBestScore();
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Text('Game Over.\nYour score: $_score\nBest score: $_bestScore'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _startGame();
            },
            child: const Text('Restart'),
          ),
        ],
      ),
    );
  }

  void _generateParticle(Timer timer) {
    if (_particles.length < 30) {
      final isGood = _random.nextBool();
      _particles.add(_Particle(
        position: Offset(_random.nextDouble() * 400, 0),
        radius: 10 + _random.nextDouble() * 10,
        color: isGood ? Colors.green : Colors.red,
        isGood: isGood,
      ));
    }
  }

  void _updateParticles() {
    for (final particle in _particles) {
      particle.position =
          Offset(particle.position.dx, particle.position.dy + 3);
    }

    _particles.removeWhere((particle) => particle.position.dy > 800);

    final caughtParticles = _particles
        .where((particle) =>
            (particle.position - _playerPosition).distance <
            _playerRadius + particle.radius)
        .toList();

    for (final particle in caughtParticles) {
      _energy +=
          particle.isGood ? particle.radius.toInt() : -particle.radius.toInt();
      _playerRadius += particle.isGood
          ? particle.radius / 10
          : 0; // Adjust radius based on particle size
      _score += 1; // Increment score by 1 for each particle caught
      _particles.remove(particle);
    }

    if (_energy >= _maxEnergy || _energy <= _minEnergy) {
      _endGame();
    }
  }

  Color _playerColor() {
    if (_energy >= 50) {
      return Color.lerp(Colors.yellow, Colors.green, (_energy - 50) / 50)!;
    } else {
      return Color.lerp(Colors.yellow, Colors.red, (50 - _energy) / 50)!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onPanStart: (details) {
          _lastDragPosition = details.localPosition;
        },
        onPanUpdate: (details) {
          setState(() {
            final dx = details.localPosition.dx - _lastDragPosition.dx;
            final dy = details.localPosition.dy - _lastDragPosition.dy;
            _playerPosition = Offset(
              (_playerPosition.dx + dx)
                  .clamp(0 + _playerRadius, 400 - _playerRadius),
              (_playerPosition.dy + dy)
                  .clamp(0 + _playerRadius, 800 - _playerRadius),
            );
            _lastDragPosition = details.localPosition;
          });
        },
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _AuroraCatcherPainter(
                  particles: _particles,
                  playerPosition: _playerPosition,
                  playerRadius: _playerRadius,
                  playerColor: _playerColor(),
                ),
              ),
            ),
            const Center(
              child: Opacity(
                opacity: 0.4,
                child: Text(
                  'Be Yellow\nEat Less',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        offset: Offset(2, 2),
                        blurRadius: 4,
                        color: Colors.black54,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              right: 20,
              child: Text(
                'Score: $_score\nBest: $_bestScore',
                style: const TextStyle(fontSize: 20, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Particle {
  Offset position;
  final double radius;
  final Color color;
  final bool isGood;

  _Particle({
    required this.position,
    required this.radius,
    required this.color,
    required this.isGood,
  });
}

class _AuroraCatcherPainter extends CustomPainter {
  final List<_Particle> particles;
  final Offset playerPosition;
  final double playerRadius;
  final Color playerColor;

  _AuroraCatcherPainter({
    required this.particles,
    required this.playerPosition,
    required this.playerRadius,
    required this.playerColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    // Draw particles
    for (final particle in particles) {
      paint.color = particle.color;
      canvas.drawCircle(particle.position, particle.radius, paint);
    }

    // Draw player
    paint.color = playerColor;
    final playerRect = Rect.fromCenter(
      center: playerPosition,
      width: playerRadius * 2,
      height: playerRadius * 1.5,
    );
    canvas.drawOval(playerRect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
