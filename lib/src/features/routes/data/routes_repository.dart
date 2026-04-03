import '../../../core/models/task_model.dart';
import '../../../core/models/route_stop_model.dart';
import 'routes_service.dart';

class RoutesRepository {
  final RoutesService _service;

  RoutesRepository(this._service);

  Future<List<RouteStopModel>> getTaskStops(String employeeId) async {
    final data = await _service.fetchTaskDetails(employeeId);
    final message = data['message'] as Map<String, dynamic>;
    final tasksList = message['tasks'] as List<dynamic>? ?? [];

    final tasks = tasksList
        .map((e) => TaskModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return RouteStopModel.fromTaskList(tasks);
  }
}
