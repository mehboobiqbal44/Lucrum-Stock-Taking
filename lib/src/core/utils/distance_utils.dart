import 'package:latlong2/latlong.dart';

class DistanceUtils {
  DistanceUtils._();

  static final _distance = Distance();

  /// Great-circle distance in kilometers.
  static double kmBetween(LatLng from, LatLng to) {
    return _distance.as(LengthUnit.Kilometer, from, to);
  }

  static String formatDistanceKm(double km) {
    if (km.isNaN || km.isInfinite) return '—';
    if (km < 1) {
      return '${(km * 1000).round()} m away';
    }
    return '${km.toStringAsFixed(1)} km away';
  }
}
