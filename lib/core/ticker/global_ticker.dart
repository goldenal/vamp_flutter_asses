import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../time/server_time_service.dart';

class GlobalTicker {
  final ServerTimeService _timeService;

  GlobalTicker(this._timeService);

  Stream<DateTime> tick() {
    return Stream.periodic(const Duration(seconds: 1), (_) {
      return _timeService.now();
    });
  }
}

final globalTickerProvider = Provider<GlobalTicker>((ref) {
  final timeService = ref.watch(serverTimeServiceProvider);
  return GlobalTicker(timeService);
});

final tickerStreamProvider = StreamProvider<DateTime>((ref) {
  final ticker = ref.watch(globalTickerProvider);
  return ticker.tick();
});
