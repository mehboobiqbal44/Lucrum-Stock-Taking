import 'package:dio/dio.dart';
import 'package:latlong2/latlong.dart';

class RouteInfo {
  final List<LatLng> points;
  final double distanceKm;
  final double durationMin;
  final bool isRoadRoute;

  const RouteInfo({
    required this.points,
    this.distanceKm = 0,
    this.durationMin = 0,
    this.isRoadRoute = false,
  });
}

/// Fetches road-following polylines from the OSRM demo routing server.
class RouteDirectionsService {
  RouteDirectionsService._();

  static final _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  static Future<RouteInfo> getRoute(List<LatLng> waypoints) async {
    if (waypoints.length < 2) {
      return RouteInfo(points: waypoints);
    }

    final coords =
        waypoints.map((p) => '${p.longitude},${p.latitude}').join(';');

    final url = 'https://router.project-osrm.org/route/v1/driving/$coords'
        '?overview=full&geometries=geojson';

    try {
      final response = await _dio.get(url);
      final data = response.data as Map<String, dynamic>;

      if (data['code'] != 'Ok') return RouteInfo(points: waypoints);

      final routes = data['routes'] as List;
      if (routes.isEmpty) return RouteInfo(points: waypoints);

      final route = routes[0] as Map<String, dynamic>;
      final geometry = route['geometry'] as Map<String, dynamic>;
      final coordinates = geometry['coordinates'] as List;

      final points = coordinates.map((c) {
        final coord = c as List;
        return LatLng(
          (coord[1] as num).toDouble(),
          (coord[0] as num).toDouble(),
        );
      }).toList();

      final distanceM = (route['distance'] as num?)?.toDouble() ?? 0;
      final durationS = (route['duration'] as num?)?.toDouble() ?? 0;

      return RouteInfo(
        points: points,
        distanceKm: distanceM / 1000,
        durationMin: durationS / 60,
        isRoadRoute: true,
      );
    } catch (_) {
      return RouteInfo(points: waypoints);
    }
  }
}
