import 'checkin_service.dart';

class CheckinRepository {
  final CheckinService _service;

  CheckinRepository(this._service);

  Future<bool> checkin({
    required String stopId,
    required double latitude,
    required double longitude,
  }) async {
    try {
      await _service.performCheckin(
        stopId: stopId,
        latitude: latitude,
        longitude: longitude,
      );
      return true;
    } catch (_) {
      return false;
    }
  }
}
