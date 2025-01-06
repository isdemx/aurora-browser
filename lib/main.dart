import 'package:flutter/material.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
// Важная часть: c 4.x версии WebView разделён на контроллер и виджет.
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

/// Корневое приложение
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aurora Browser',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const BrowserPage(),
    );
  }
}

/// Главная страница, содержащая WebView и элементы управления
class BrowserPage extends StatefulWidget {
  const BrowserPage({super.key});

  @override
  State<BrowserPage> createState() => _BrowserPageState();
}

class _BrowserPageState extends State<BrowserPage> {
  /// Контроллер WebView (из пакета `webview_flutter`).
  late final WebViewController _webViewController;
  double _progress = 0; // от 0 до 100

  /// Текстовый контроллер для адресной строки.
  final TextEditingController _addressBarController =
      TextEditingController(text: 'info');

  /// Храним, включён ли Wakelock (true = экран не гаснет).
  bool _isWakelockEnabled = false;

  /// Собственная история посещений (дополнительно к механизму `canGoBack/canGoForward`).
  final List<String> _history = [];

  @override
  void initState() {
    super.initState();

    // Создаём WebViewController и настраиваем его.
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            _addressBarController.text = url;
          },
          onPageFinished: (url) {
            _addressBarController.text = url;
            if (_history.isEmpty || _history.last != url) {
              _history.add(url);
            }
          },
          onProgress: (int progress) {
            setState(() {
              _progress = progress.toDouble();
            });
            debugPrint('Page Load: $progress%');
          },
          onNavigationRequest: (request) {
            return NavigationDecision.navigate;
          },
          onWebResourceError: (WebResourceError error) {
            // Загружаем простую HTML-страницу с текстом "404 Page not found"
            _webViewController.loadHtmlString('''
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8"/>
  <title>404 Page not found</title>
  <style>
    body {
      font-family: Arial, sans-serif;
      background-color: #f5f5f5;
      color: #333;
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      height: 100vh;
      margin: 0;
      padding: 20px;
    }
    h1 {
      font-size: 3rem;
      margin-bottom: 1rem;
    }
    p {
      font-size: 1.5rem;
      line-height: 1.5;
    }
  </style>
</head>
<body>
  <h1>404 - Page not found</h1>
  <p>The requested page does not exist or could not be loaded.</p>
</body>
</html>
''');
          },
        ),
      )
      // Вместо "flutter.dev" сразу загружаем HTML-описание
      ..loadHtmlString('''
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8"/>
  <style>
    * {
      font-family: Arial, sans-serif;
      margin: 0;
      padding: 0;
      box-sizing: border-box;
    }

    body {
      display: flex;
      justify-content: center;
      align-items: center;
      flex-direction: column;
      height: 100vh;
      text-align: center;
      background-color: #f5f5f5;
      color: #333;
      padding: 40px;
    }

    h1 {
      font-size: 3rem;
      margin-bottom: 1rem;
    }

    p {
      font-size: 2.5rem;
      line-height: 1.8;
      margin-bottom: 100px;
    }
  </style>
  <title>Aurora Browser</title>
</head>
<body>
  <h1>Aurora Browser</h1>
  <p>This browser is useful for those who need to keep a page open
     and prevent the screen from turning off.</p>
</body>
</html>
''');
  }

  /// Загрузка нового URL из адресной строки.
  void _goToUrl() {
    var url = _addressBarController.text.trim();

    // Если пользователь не ввёл ни http:// ни https://
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'http://$url';
      // Либо меняйте логику по желанию:
      // например сначала пытаетесь http://, а при неудаче — https:// и т.д.
    }

    _webViewController.loadRequest(Uri.parse(url));
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

  /// Открыть историю в BottomSheet.
  void _showHistory() {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext ctx) {
        return ListView.builder(
          itemCount: _history.length,
          itemBuilder: (context, index) {
            final url = _history[index];
            return ListTile(
              title: Text(url),
              onTap: () {
                Navigator.pop(context); // Закрываем BottomSheet
                _addressBarController.text = url;
                _webViewController.loadRequest(Uri.parse(url));
              },
            );
          },
        );
      },
    );
  }

  /// Кнопка «Назад» (шаг назад в истории WebView).
  Future<void> _goBack() async {
    if (await _webViewController.canGoBack()) {
      await _webViewController.goBack();
    }
  }

  /// Кнопка «Вперёд» (шаг вперёд в истории WebView).
  Future<void> _goForward() async {
    if (await _webViewController.canGoForward()) {
      await _webViewController.goForward();
    }
  }

  /// Кнопка «Обновить» (обновляет текущую страницу).
  Future<void> _reloadPage() async {
    await _webViewController.reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /// Верхняя панель с кнопками и адресной строкой.
      appBar: AppBar(
        // Делим AppBar на две части: иконки управления + поле для URL + кнопка «Go».
        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: _goBack,
              tooltip: 'Backward',
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward),
              onPressed: _goForward,
              tooltip: 'Forward',
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _reloadPage,
              tooltip: 'Refresh',
            ),
            Expanded(
              child: TextField(
                controller: _addressBarController,
                keyboardType: TextInputType.url,
                textInputAction: TextInputAction.go,
                decoration: const InputDecoration(
                  hintText: 'Enter an url address',
                  border: InputBorder.none,
                  // contentPadding: EdgeInsets.symmetric(horizontal: 4.0),
                ),
                onSubmitted: (_) => _goToUrl(),
                onTap: () {
                  // Выделяем весь текст в поле при нажатии
                  _addressBarController.selection = TextSelection(
                    baseOffset: 0,
                    extentOffset: _addressBarController.text.length,
                  );
                },
              ),
            ),
            // IconButton(
            //   icon: const Icon(Icons.search),
            //   onPressed: _goToUrl,
            //   tooltip: 'Go',
            // ),
            // const SizedBox(width: 4),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: _showHistory,
            tooltip: 'History',
          ),
        ],
      ),

      /// Сам WebView на всю оставшуюся часть экрана.
      body: Column(
        children: [
          // Прогресс-бар (показывается, если загрузка < 100%)
          if (_progress < 100) LinearProgressIndicator(value: _progress / 100),

          // Расширяемый контейнер с WebView
          Expanded(
            child: WebViewWidget(controller: _webViewController),
          ),
        ],
      ),

      /// Плавающая кнопка справа снизу - включает/выключает Wakelock.
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleWakelock,
        tooltip: 'Wakelock',
        child: Icon(_isWakelockEnabled ? Icons.lock : Icons.lock_open),
      ),
    );
  }
}
