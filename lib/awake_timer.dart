// awake_timer.dart
import 'dart:async';
import 'package:wakelock_plus/wakelock_plus.dart';

/// Варианты длительности "Awake Timer".
enum AwakeTimerOption {
  oneMinute,       // 1 минута
  fifteenMinutes,  // 15 минут
  forever,         // всегда
}

/// Удобный метод, чтобы получить "человеческое" название.
String getAwakeTimerLabel(AwakeTimerOption option) {
  switch (option) {
    case AwakeTimerOption.oneMinute:
      return '1 Minute';
    case AwakeTimerOption.fifteenMinutes:
      return '15 Minutes';
    case AwakeTimerOption.forever:
      return 'Always Awake';
  }
}

/// Класс, управляющий "таймером бодрствования".
class AwakeTimerManager {
  Timer? _timer;

  /// Текущий выбранный вариант (по умолчанию - forever).
  AwakeTimerOption currentOption = AwakeTimerOption.forever;

  /// Включаем Wakelock согласно выбранному варианту.
  /// Если это 1 или 15 минут — запустим соответствующий таймер.
  Future<void> enableAwake() async {
    // Сначала включаем
    await WakelockPlus.enable();

    // Если уже шел таймер, отменим
    _timer?.cancel();
    _timer = null;

    if (currentOption == AwakeTimerOption.oneMinute) {
      // Запускаем таймер на 1 минуту
      _timer = Timer(const Duration(minutes: 1), () async {
        await WakelockPlus.disable();
      });
    } else if (currentOption == AwakeTimerOption.fifteenMinutes) {
      // Запускаем таймер на 15 минут
      _timer = Timer(const Duration(minutes: 15), () async {
        await WakelockPlus.disable();
      });
    } else {
      // forever - ничего не делаем, просто оставляем включенным
    }
  }

  /// Отключаем Wakelock и любой таймер.
  Future<void> disableAwake() async {
    _timer?.cancel();
    _timer = null;
    await WakelockPlus.disable();
  }
}
