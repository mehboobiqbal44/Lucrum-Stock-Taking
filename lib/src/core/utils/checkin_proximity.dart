import 'package:latlong2/latlong.dart';
import '../models/route_stop_model.dart';
import 'distance_utils.dart';
import 'location_helper.dart';

/// Validates that the device is close enough to a task stop for check-in.
class CheckinProximity {
  CheckinProximity._();

  /// Maximum distance from the stop (200 m).
  static const double maxRadiusKm = 0.2;

  static Future<CheckinProximityResult> validate(RouteStopModel stop) async {
    if (stop.latitude == 0 && stop.longitude == 0) {
      return const CheckinProximityResult(
        allowed: false,
        message:
            'This stop has no map coordinates. Check-in cannot be verified.',
      );
    }

    final user = await LocationHelper.getCurrentLatLng();
    if (user == null) {
      return const CheckinProximityResult(
        allowed: false,
        message: 'Please enable location services to check in.',
      );
    }

    final km = DistanceUtils.kmBetween(
      user,
      LatLng(stop.latitude, stop.longitude),
    );

    if (km > maxRadiusKm) {
      return CheckinProximityResult(
        allowed: false,
        message:
            'Please move to this location. You must be within 200 m of the stop to check in.',
      );
    }

    return const CheckinProximityResult(allowed: true);
  }
}

class CheckinProximityResult {
  final bool allowed;
  final String message;

  const CheckinProximityResult({
    required this.allowed,
    this.message = '',
  });
}
