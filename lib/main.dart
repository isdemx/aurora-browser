import 'dart:math';
import 'package:flutter/material.dart';
import 'package:midnight_sun/animation-bg.dart';
import 'package:midnight_sun/app_bar.dart';
import 'package:midnight_sun/favorites.dart';
import 'package:midnight_sun/helpers.dart';
import 'package:midnight_sun/message-with-input.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'dart:convert';
import 'package:flutter/services.dart'; // Для управления системным UI

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

/// The root app with light and dark themes.
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  /// Theme mode (default = system).
  ThemeMode _themeMode = ThemeMode.system;

  /// Toggles between light and dark theme for demonstration.
  void _toggleThemeMode() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aurora Awake Browser',
      themeMode: _themeMode,
      // Light theme
      theme: ThemeData(
        brightness: Brightness.light,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black, // icons/text color in AppBar
        ),
      ),
      // Dark theme
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
      ),
      home: BrowserPage(onToggleThemeMode: _toggleThemeMode),
    );
  }
}

/// The main "browser" page.
class BrowserPage extends StatefulWidget {
  final VoidCallback onToggleThemeMode;

  const BrowserPage({super.key, required this.onToggleThemeMode});

  @override
  State<BrowserPage> createState() => _BrowserPageState();
}

class _BrowserPageState extends State<BrowserPage>
    with SingleTickerProviderStateMixin {
  /// WebView controller (from webview_flutter 4.x).
  late final WebViewController _webViewController;

  /// Text controller for the address bar.
  final TextEditingController _addressBarController = TextEditingController();

  /// Whether to show the start page (before any address is entered).
  bool _showStartPage = true;

  /// Error flag (e.g., 404).
  bool _hasError = false;

  /// Loading progress [0..100].
  double _progress = 0;

  /// Wakelock control (true = keep screen on).
  bool _isWakelockEnabled = false;

  /// Vertical position of the floating button (0.0 top, 1.0 bottom).
  double _buttonPosition = 0.8;

  /// Custom history of visited pages.
  final List<String> _history = [];

  late final Widget _startBackground;
  late final Widget _errorBackground;

  final FocusNode _addressFocusNode = FocusNode();
  bool _headerFocused = false;

  List<Map<String, dynamic>> _favorites = [];

  /// Флаг, показывающий, идёт ли загрузка фаворитов
  bool _favoritesLoading = false;

  late AnimationController _headerController;
  late Animation<Color?> _headerColorAnimation;

  bool _isTutorialShown = false;

  bool _isAppBarVisible = true; // Новый флаг

  bool _isFabHidden = false;

  @override
  void dispose() {
    _headerController.dispose();
    super.dispose();
  }

  Future<void> _checkTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    // prefs.remove('tutorialShown');
    _isTutorialShown = prefs.getBool('tutorialShown') ?? false;
    setState(() {});
  }

  void _completeTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('tutorialShown', true);
    setState(() {
      _isTutorialShown = true;
    });
  }

  @override
  void initState() {
    super.initState();

    _init();
    _checkTutorial();

    _addressFocusNode.addListener(() {
      setState(() {
        // true, если TextField получил фокус
        _headerFocused = _addressFocusNode.hasFocus;
      });
    });

    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);

    _headerColorAnimation = ColorTween(
      begin: Colors.blueGrey,
      end: Colors.deepPurpleAccent,
    ).animate(_headerController);

    // Пример списка из трёх вариантов фона:
    final backgrounds = [
      const AnimatedBackground(), // ваш старый фон с пузырями
      const AnimatedBackground2(), // новый фон с квадратиками
      const AnimatedBackground3(), // новый фон с кружками
      const NorthernLightsAnimation(), // Северное 1
      const VerticalAuroraAnimation(), // Северное 2
      const PulsatingCirclesBackground(), // Северное 3
      const FractalAurora(), // Северное ФРАКталы
      const AuroraCatcherPage(), // Северное ФРАКталы
      const IcyNorthernLights(), // Северное ФРАКталы
    ];

    final random = Random();

    // Выбираем случайным образом
    _startBackground = AuroraCatcherPage();
    _errorBackground = AuroraCatcherPage();
  }

  Widget _buildTutorialOverlay() {
    if (_isTutorialShown) return const SizedBox.shrink();

    return Stack(
      children: [
        Container(
          color: Colors.black.withOpacity(0.5), // Затемнение
        ),
        Positioned(
          top: MediaQuery.of(context).size.height * 0.4, // Позиция облака
          right: 16,
          child: Stack(
            children: [
              // Фон с хвостиком
              CustomPaint(
                painter: SpeechBubblePainter(color: Colors.deepPurpleAccent!),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: const Text(
                    'Tap the button to enable Awake mode.\n'
                    'Long press to open the menu.\n'
                    'Swipe right to hide the button.\n'
                    'Tap the button to close this tutorial.',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _init() async {
    // Перед загрузкой фаворитов ставим флаг
    setState(() {
      _favoritesLoading = true;
    });

    await _loadFavorites();

    // Когда загрузка завершилась, сбрасываем флаг
    setState(() {
      _favoritesLoading = false;
    });

    // Initialize the WebViewController
    final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }
    _webViewController = WebViewController.fromPlatformCreationParams(params)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            setState(() {
              _progress = 0;
              _hasError = false;
              _addressBarController.text = url;
            });
          },
          onProgress: (p) {
            setState(() {
              _progress = p.toDouble();
            });
          },
          onPageFinished: (url) {
            setState(() {
              _progress = 100;
              _addressBarController.text = url;
              if (_history.isEmpty || _history.last != url) {
                _history.add(url);
              }
            });
          },
          onWebResourceError: (error) {
            setState(() {
              _hasError = true;
            });
          },
        ),
      );
  }

  bool _isCurrentUrlFavorite() {
    final currentUrl = _addressBarController.text.trim();
    return _favorites.any((f) => f["url"] == currentUrl);
  }

  /// Тоглим: если URL уже в избранном — убираем, если нет — добавляем.
  void _toggleFavorite(String url) async {
    final idx = _favorites.indexWhere((f) => f["url"] == url);
    if (idx >= 0) {
      // Уже в избранном — убираем
      _favorites.removeAt(idx);
      await _saveFavorites();
      setState(() {});
    } else {
      // Нет — добавляем
      _addToFavorites(url);
    }
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favString = prefs.getString('favorites');
    if (favString != null) {
      final List<dynamic> jsonList = jsonDecode(favString);
      _favorites = jsonList
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();
    }
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favString = jsonEncode(_favorites);
    await prefs.setString('favorites', favString);
  }

  void _addToFavorites(String url) async {
    // Генерируем рандомный пастельный цвет
    final color = generateRandomPastelColor();
    final item = {
      "url": url,
      "color": colorToHex(color),
    };
    // Проверим, нет ли уже такого
    bool alreadyExists = _favorites.any((fav) => fav["url"] == url);
    if (!alreadyExists) {
      _favorites.add(item);
      await _saveFavorites();
      setState(() {});
    }
  }

  void _showFavorites() {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext ctx) {
        return ListView.builder(
          itemCount: _favorites.length,
          itemBuilder: (context, index) {
            final fav = _favorites[index];
            final url = fav["url"] as String;
            final colorHex = fav["color"] as String;
            final color = hexToColor(colorHex);

            return ListTile(
              tileColor: color.withOpacity(0.4),
              title: Text(url),
              onTap: () {
                Navigator.pop(context); // Закрыть BottomSheet
                setState(() {
                  _showStartPage = false;
                  _hasError = false;
                  _addressBarController.text = url;
                });
                _webViewController.loadRequest(Uri.parse(url));
              },
            );
          },
        );
      },
    );
  }

  /// Toggle Wakelock (prevent the screen from sleeping).
  Future<void> _toggleWakelock() async {
    if (_isWakelockEnabled) {
      await WakelockPlus.disable();
    } else {
      await WakelockPlus.enable();
    }
    final newValue = await WakelockPlus.enabled;
    setState(() {
      _isWakelockEnabled = newValue;
    });
  }

  /// Load URL from the address bar.
  void _goToUrl() {
    final text = _addressBarController.text.trim();
    if (text.isEmpty) return;

    String url;
    if (isUrl(text)) {
      url = text.startsWith('http') ? text : 'https://$text';
    } else {
      url = buildSearchQuery(text);
    }

    setState(() {
      _showStartPage = false;
      _hasError = false;
    });
    _webViewController.loadRequest(Uri.parse(url));
  }

  Widget _buildStartPage(BuildContext context) {
    // Если ещё идёт загрузка фаворитов, покажем индикатор
    if (_favoritesLoading) {
      return Stack(
        children: [
          _startBackground,
          const Center(
            child: CircularProgressIndicator(),
          ),
        ],
      );
    }

    return Stack(
      children: [
        // Случайный (или выбранный) фон для стартовой
        _startBackground,
        // Разрешим прокрутку (если фаворитов много)
        SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Блок с полем ввода вверху

                if (_favorites.isNotEmpty)
                  Column(
                    children: [
                      TextField(
                        controller: _addressBarController,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.go,
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Enter URL or search prompt',
                          hintStyle: const TextStyle(color: Colors.white54),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.1),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(80),
                            borderSide: BorderSide.none,
                          ),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.arrow_forward,
                                color: Colors.white),
                            onPressed: _goToUrl,
                          ),
                        ),
                        onSubmitted: (_) => _goToUrl(),
                      ),
                    ],
                  ),

                const SizedBox(height: 20),

                // Проверяем, есть ли фавориты
                if (_favorites.isEmpty)
                  MessageWithInput(
                    message: 'Welcome to Aurora Awake Browser!\n\n'
                        'This is a miniature web browser featuring an always-awake mode.\n'
                        'Enter prompt or URL to start\n',
                    hintText: 'Enter a new URL or prompt',
                    controller: _addressBarController,
                    onGoPressed: _goToUrl,
                    onSubmitted: (_) => _goToUrl(),
                  )
                else
                  // Сетка фаворитов
                  FavoritesWidget(
                    favorites: _favorites,
                    onFavoriteTap: (url) {
                      setState(() {
                        _showStartPage = false;
                        _hasError = false;
                        _addressBarController.text = url;
                      });
                      _webViewController.loadRequest(Uri.parse(url));
                    },
                  )
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Build the error page (e.g., 404).
  Widget _buildErrorPage(BuildContext context) {
    return Stack(
      children: [
        // Случайный (или специально выбранный) фон
        _errorBackground,
        MessageWithInput(
          message: 'Oops! 404 Error.\n\n'
              'The requested page was not found or is temporarily unavailable...\n'
              'Please try a different URL or go back:\n',
          hintText: 'Enter a new URL',
          controller: _addressBarController,
          onGoPressed: _goToUrl,
          onSubmitted: (_) => _goToUrl(),
        ),
      ],
    );
  }

  /// Build the page with WebView if there's no error.
  Widget _buildWebView() {
    return Stack(
      children: [
        WebViewWidget(controller: _webViewController),
        if (_progress < 100) LinearProgressIndicator(value: _progress / 100),
      ],
    );
  }

  Widget _buildDraggableFab() {
    double buttonLeftPosition = MediaQuery.of(context).size.width - 80;

    return StatefulBuilder(
      builder: (context, setState) {
        return Positioned(
          top: _buttonPosition *
                  (MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom) -
              30,
          left: _isFabHidden
              ? MediaQuery.of(context).size.width - 20
              : buttonLeftPosition,
          child: GestureDetector(
            onVerticalDragUpdate: (details) {
              setState(() {
                _buttonPosition +=
                    details.delta.dy / MediaQuery.of(context).size.height;
                _buttonPosition = _buttonPosition.clamp(
                  MediaQuery.of(context).padding.top /
                      MediaQuery.of(context).size.height,
                  1.0 -
                      MediaQuery.of(context).padding.bottom /
                          MediaQuery.of(context).size.height,
                );
              });
            },
            onLongPress: () {
              // Включение вибрации
              HapticFeedback.lightImpact();
              // Показываем меню
              _showFabMenu(context);
            },
            onHorizontalDragUpdate: (details) {
              setState(() {
                if (details.delta.dx > 10) {
                  // Свайп вправо
                  _isFabHidden = true;
                } else if (details.delta.dx < -10) {
                  // Свайп влево
                  _isFabHidden = false;
                }
              });
            },
            onTap: () {
              if (_isFabHidden) {
                setState(() {
                  _isFabHidden = false;
                });
              }
            },
            child: AnimatedOpacity(
              opacity: _isFabHidden ? 0.5 : 1.0,
              duration: const Duration(milliseconds: 300),
              child: FloatingActionButton(
                onPressed: () {
                  _toggleWakelock();
                  if (!_isTutorialShown) {
                    _completeTutorial();
                  }
                },
                child: Icon(_isWakelockEnabled ? Icons.lock : Icons.lock_open),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showFabMenu(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true, // Закрыть при нажатии за пределы
      builder: (BuildContext dialogContext) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width:
                  MediaQuery.of(context).size.width * 0.8, // 80% ширины экрана
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.grey[900], // Темный фон
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: StatefulBuilder(
                builder: (BuildContext localContext, StateSetter setState) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Fullscreen с чекбоксом
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Fullscreen',
                            style: TextStyle(color: Colors.white),
                          ),
                          Checkbox(
                            value: !_isAppBarVisible,
                            onChanged: (value) {
                              // Обновляем состояние глобально
                              setState(() {
                                _isAppBarVisible = !value!;
                              });
                              this.setState(() {
                                // Полное обновление родительского виджета
                                if (value!) {
                                  SystemChrome.setEnabledSystemUIMode(
                                      SystemUiMode.immersive);
                                } else {
                                  SystemChrome.setEnabledSystemUIMode(
                                      SystemUiMode.edgeToEdge);
                                }
                              });
                              Navigator.pop(dialogContext); // Закрываем меню
                            },
                          ),
                        ],
                      ),
                      // const Divider(color: Colors.white54),
                      // TextButton(
                      //   onPressed: () {
                      //     print('Awake Timer Clicked');
                      //     Navigator.pop(dialogContext); // Закрываем диалог
                      //   },
                      //   child: const Text(
                      //     'Awake Timer',
                      //     style: TextStyle(color: Colors.white),
                      //   ),
                      // ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  /// Go back in WebView.
  Future<void> _goBack() async {
    if (await _webViewController.canGoBack()) {
      await _webViewController.goBack();
    }
  }

  /// Go forward in WebView.
  Future<void> _goForward() async {
    if (await _webViewController.canGoForward()) {
      await _webViewController.goForward();
    }
  }

  /// Reload the WebView.
  Future<void> _reloadPage() async {
    if (!_showStartPage && !_hasError) {
      await _webViewController.reload();
    }
  }

  /// Show the browsing history in a BottomSheet.
  void _showHistory() {
    final filteredHistory =
        _history.where((url) => url != 'about:blank').toList();

    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext ctx) {
        return ListView.builder(
          itemCount: filteredHistory.length,
          itemBuilder: (context, index) {
            final url = filteredHistory[index];
            return ListTile(
              title: Text(url),
              onTap: () {
                Navigator.pop(context); // Close BottomSheet
                setState(() {
                  _showStartPage = false;
                  _hasError = false;
                  _addressBarController.text = url;
                });
                _webViewController.loadRequest(Uri.parse(url));
              },
            );
          },
        );
      },
    );
  }

  PreferredSizeWidget _buildAnimatedGradientAppBar() {
    final isFavorite = _isCurrentUrlFavorite();
    final currentUrl = _addressBarController.text.trim();

    return GradientAppBar(
      addressBarController: _addressBarController,
      addressFocusNode: _addressFocusNode,
      isFavorite: isFavorite,
      gradientAnimation: _headerColorAnimation,
      onBackPressed: _goBack,
      onForwardPressed: _goForward,
      onRefreshPressed: _reloadPage,
      onHistoryPressed: _showHistory,
      onFavoriteToggle: () {
        if (currentUrl.isNotEmpty) {
          _toggleFavorite(currentUrl);
        }
      },
      onFavoritesLongPress: _showFavorites,
      onUrlSubmitted: (_) => _goToUrl(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Если `_showStartPage` или `_hasError`, AppBar = null
      appBar: (_showStartPage || _hasError || !_isAppBarVisible)
          ? null
          : _buildAnimatedGradientAppBar(),
      body: Stack(
        children: [
          if (_showStartPage)
            _buildStartPage(context)
          else if (_hasError)
            _buildErrorPage(context)
          else
            _buildWebView(),
          if (!_isTutorialShown) _buildTutorialOverlay(),
          _buildDraggableFab(),
        ],
      ),
    );
  }
}

class SpeechBubblePainter extends CustomPainter {
  final Color color;

  SpeechBubblePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 20)
      ..lineTo(0, size.height - 20) // Левая нижняя кривая
      ..quadraticBezierTo(0, size.height, 20, size.height)
      ..lineTo(size.width * 0.6, size.height) // Линия до хвостика
      ..lineTo(size.width * 0.8, size.height + 30) // Вниз (хвостик)
      ..lineTo(size.width * 0.8, size.height) // Обратно вверх
      ..lineTo(size.width - 20, size.height) // Правая нижняя кривая
      ..quadraticBezierTo(size.width, size.height, size.width, size.height - 20)
      ..lineTo(size.width, 20) // Правая вертикальная линия
      ..quadraticBezierTo(size.width, 0, size.width - 20, 0)
      ..lineTo(20, 0) // Верхняя горизонтальная линия
      ..quadraticBezierTo(0, 0, 0, 20) // Левая верхняя кривая
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
