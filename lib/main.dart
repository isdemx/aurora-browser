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
      title: 'Flutter Browser Demo',
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

  /// Текстовый контроллер для адресной строки.
  final TextEditingController _addressBarController =
      TextEditingController(text: 'https://flutter.dev');

  /// Храним, включён ли Wakelock (true = экран не гаснет).
  bool _isWakelockEnabled = false;

  /// Собственная история посещений (дополнительно к механизму `canGoBack/canGoForward`).
  final List<String> _history = [];

  @override
  void initState() {
    super.initState();

    // Создаём WebViewController и настраиваем его.
    _webViewController = WebViewController()
      // Разрешаем JavaScript, если нужно.
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      // Подписываемся на колбэки навигации.
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            // Когда страница начинает грузиться, обновляем адрес в TextField
            // (можно делать и в onPageFinished, но так реагируем быстрее).
            _addressBarController.text = url;
          },
          onPageFinished: (url) {
            // После окончания загрузки страницы обновляем адрес.
            _addressBarController.text = url;

            // Добавляем URL в историю, если его там ещё нет,
            // или если это новый переход.
            if (_history.isEmpty || _history.last != url) {
              _history.add(url);
            }
          },
          onProgress: (int progress) {
            debugPrint('Загрузка страницы: $progress%');
          },
          onNavigationRequest: (request) {
            // Пример фильтра: можно блокировать определённые сайты.
            // if (request.url.contains('youtube.com')) {
            //   return NavigationDecision.prevent;
            // }
            return NavigationDecision.navigate;
          },
        ),
      )
      // Загружаем начальный URL.
      ..loadRequest(Uri.parse(_addressBarController.text));
  }

  /// Загрузка нового URL из адресной строки.
  void _goToUrl() {
    var url = _addressBarController.text.trim();

    // Если пользователь не ввёл протокол — добавим https://
    if (!url.startsWith('http')) {
      url = 'https://$url';
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
              tooltip: 'Назад',
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward),
              onPressed: _goForward,
              tooltip: 'Вперёд',
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _reloadPage,
              tooltip: 'Обновить',
            ),
            Expanded(
              child: TextField(
                controller: _addressBarController,
                keyboardType: TextInputType.url,
                textInputAction: TextInputAction.go,
                decoration: const InputDecoration(
                  hintText: 'Введите адрес, напр. flutter.dev',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 4.0),
                ),
                onSubmitted: (_) => _goToUrl(),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: _goToUrl,
              tooltip: 'Перейти',
            ),
            const SizedBox(width: 4),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: _showHistory,
            tooltip: 'История',
          ),
        ],
      ),

      /// Сам WebView на всю оставшуюся часть экрана.
      body: WebViewWidget(controller: _webViewController),

      /// Плавающая кнопка справа снизу - включает/выключает Wakelock.
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleWakelock,
        tooltip: 'Wakelock (не гасить экран)',
        child: Icon(_isWakelockEnabled ? Icons.lock : Icons.lock_open),
      ),
    );
  }
}
