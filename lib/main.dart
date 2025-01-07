import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

/// Корневое приложение со светлой и тёмной темами.
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  /// Режим темы (по умолчанию — системный).
  ThemeMode _themeMode = ThemeMode.system;

  /// Переключение (для примера) между светлой и тёмной.
  void _toggleThemeMode() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aurora Browser',
      themeMode: _themeMode,
      // Светлая тема
      theme: ThemeData(
        brightness: Brightness.light,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black, // цвет иконок и текста в AppBar
        ),
      ),
      // Тёмная тема
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

/// Главная страница «браузера».
class BrowserPage extends StatefulWidget {
  final VoidCallback onToggleThemeMode;
  const BrowserPage({super.key, required this.onToggleThemeMode});

  @override
  State<BrowserPage> createState() => _BrowserPageState();
}

class _BrowserPageState extends State<BrowserPage> {
  /// Контроллер WebView (начиная с пакета webview_flutter 4.x).
  late final WebViewController _webViewController;

  /// Текстовое поле для ввода URL.
  final TextEditingController _addressBarController = TextEditingController();

  /// Показываем ли «стартовый экран» (пока пользователь не ввёл адрес).
  bool _showStartPage = true;

  /// Флаг ошибки (напр. 404).
  bool _hasError = false;

  /// Прогресс загрузки [0..100].
  double _progress = 0;

  /// Управление Wakelock (true = не гасить экран).
  bool _isWakelockEnabled = false;

  /// Позиция «плавающей» кнопки по вертикали (0.0 сверху, 1.0 снизу).
  double _buttonPosition = 0.8;

  /// Наша собственная история посещённых страниц.
  final List<String> _history = [];

  @override
  void initState() {
    super.initState();

    /// Инициируем WebViewController
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            setState(() {
              _progress = 0;
              _hasError = false;
              _addressBarController.text = url; // если хотите сразу отразить
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
              // Обновляем адресную строку
              _addressBarController.text = url;
              // Добавляем в историю, если такого URL ещё нет
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

  /// Переключить Wakelock (не давать экрану гаснуть).
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

  /// Загрузка URL из адресной строки.
  void _goToUrl() {
    final text = _addressBarController.text.trim();
    if (text.isEmpty) return;

    // Если не начинается с http/https, добавим https://
    var url = text;
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }

    setState(() {
      _showStartPage = false;
      _hasError = false;
    });
    _webViewController.loadRequest(Uri.parse(url));
  }

  /// Экран «стартовый» (нативный), без WebView.
  Widget _buildStartPage(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final bgColor = brightness == Brightness.dark ? Colors.black : Colors.white;
    final fgColor = brightness == Brightness.dark ? Colors.white : Colors.black;

    return Container(
      color: bgColor,
      child: Center(
        child: Text(
          'Welcome to Aurora awake browser. \nEnter an url in address bar',
          style: TextStyle(color: fgColor, fontSize: 18),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  /// Экран «ошибка» (нативный) — напр. 404 / недоступно.
  Widget _buildErrorPage(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final bgColor = brightness == Brightness.dark ? Colors.black : Colors.white;
    final fgColor = brightness == Brightness.dark ? Colors.white : Colors.black;

    return Container(
      color: bgColor,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '404 - Page not found',
              style: TextStyle(color: fgColor, fontSize: 24),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  /// Обычная страница с WebView (если всё хорошо).
  Widget _buildWebView() {
    return Stack(
      children: [
        WebViewWidget(controller: _webViewController),
        // Прогресс-бар (линейный), если < 100%
        if (_progress < 100) LinearProgressIndicator(value: _progress / 100),
      ],
    );
  }

  /// «Плавающая» FAB-кнопка, которую можно таскать вверх/вниз.
  Widget _buildDraggableFab() {
    return Positioned(
      top: _buttonPosition * MediaQuery.of(context).size.height - 30,
      right: 16,
      child: GestureDetector(
        onVerticalDragUpdate: (details) {
          setState(() {
            _buttonPosition +=
                details.delta.dy / MediaQuery.of(context).size.height;
            // Ограничим в диапазоне [0..1]
            _buttonPosition = _buttonPosition.clamp(0.0, 1.0);
          });
        },
        child: FloatingActionButton(
          onPressed: _toggleWakelock,
          tooltip: 'Wakelock',
          child: Icon(_isWakelockEnabled ? Icons.lock : Icons.lock_open),
        ),
      ),
    );
  }

  /// Кнопка «Назад» (WebView).
  Future<void> _goBack() async {
    if (await _webViewController.canGoBack()) {
      await _webViewController.goBack();
    }
  }

  /// Кнопка «Вперёд» (WebView).
  Future<void> _goForward() async {
    if (await _webViewController.canGoForward()) {
      await _webViewController.goForward();
    }
  }

  /// Кнопка «Обновить» (WebView).
  Future<void> _reloadPage() async {
    if (!_showStartPage && !_hasError) {
      await _webViewController.reload();
    }
  }

  /// Показать «Историю» (ListView внутри BottomSheet).
  void _showHistory() {
    // Можно отфильтровать "about:blank" и т.д. при желании.
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            // // Переключатель темы
            // IconButton(
            //   icon: const Icon(Icons.brightness_6),
            //   onPressed: widget.onToggleThemeMode,
            // ),
            // Кнопка «Назад»
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: _goBack,
              tooltip: 'Back',
            ),
            // Кнопка «Вперёд»
            IconButton(
              icon: const Icon(Icons.arrow_forward),
              onPressed: _goForward,
              tooltip: 'Forward',
            ),
            // Кнопка «Обновить»
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _reloadPage,
              tooltip: 'Refresh',
            ),
            // Поле для ввода
            Expanded(
              child: TextField(
                controller: _addressBarController,
                keyboardType: TextInputType.url,
                textInputAction: TextInputAction.go,
                onSubmitted: (_) => _goToUrl(),
                decoration: const InputDecoration(
                  hintText: 'Enter url',
                  border: InputBorder.none,
                ),
              ),
            ),
            // Кнопка «History»
            IconButton(
              icon: const Icon(Icons.history),
              onPressed: _showHistory,
              tooltip: 'History',
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          // Выбираем, что показывать:
          if (_showStartPage)
            _buildStartPage(context)
          else if (_hasError)
            _buildErrorPage(context)
          else
            _buildWebView(),

          // Перетаскиваемая FAB
          _buildDraggableFab(),
        ],
      ),
    );
  }
}
