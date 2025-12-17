class ServerTimeService {
  Duration _offset = Duration.zero;

  void updateServerTime(DateTime serverTime) {
    final deviceNow = DateTime.now().toUtc();
    _offset = serverTime.difference(deviceNow);
  }

  DateTime now() {
    return DateTime.now().toUtc().add(_offset);
  }
}
