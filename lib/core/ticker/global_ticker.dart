import '../time/server_time_service.dart';

class GlobalTicker {
  final ServerTimeService _timeService;

  GlobalTicker(this._timeService);

  Stream<DateTime> tick() {
    return Stream.periodic(const Duration(seconds: 1), (_) {
      return _timeService.now();
    }).asBroadcastStream();
  }
}
