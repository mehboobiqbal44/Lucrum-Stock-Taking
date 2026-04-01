import '../../../core/models/route_stop_model.dart';
import 'routes_service.dart';

class RoutesRepository {
  final RoutesService _service;

  RoutesRepository(this._service);

  Future<List<RouteStopModel>> getRouteStops() async {
    try {
      final data = await _service.fetchRoutes();
      return data.map((e) => RouteStopModel.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }
}
