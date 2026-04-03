import 'package:equatable/equatable.dart';
import 'task_model.dart';

enum StopStatus { completed, active, pending }

class RouteStopModel extends Equatable {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final StopStatus status;
  final double distanceKm;
  final int taskCount;
  final String? completedTime;
  final String? eta;
  final String? subject;
  final String? sourceWarehouse;
  final String? targetWarehouse;
  final List<TaskChildModel> taskChildren;

  const RouteStopModel({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.status,
    this.distanceKm = 0,
    this.taskCount = 0,
    this.completedTime,
    this.eta,
    this.subject,
    this.sourceWarehouse,
    this.targetWarehouse,
    this.taskChildren = const [],
  });

  factory RouteStopModel.fromTaskModel(TaskModel task, StopStatus status) {
    return RouteStopModel(
      id: task.name,
      name: task.location.isNotEmpty ? task.location : task.sourceWarehouse,
      address: task.sourceWarehouse,
      latitude: task.latitude,
      longitude: task.longitude,
      status: status,
      taskCount: task.taskChildren.length,
      subject: task.subject,
      sourceWarehouse: task.sourceWarehouse,
      targetWarehouse: task.targetWarehouse,
      taskChildren: task.taskChildren,
    );
  }

  /// Builds ordered stops with [StopStatus] from API child task statuses.
  static List<RouteStopModel> fromTaskList(List<TaskModel> tasks) {
    final statuses = _computeStatuses(tasks);
    return List.generate(
      tasks.length,
      (i) => RouteStopModel.fromTaskModel(tasks[i], statuses[i]),
    );
  }

  static List<StopStatus> _computeStatuses(List<TaskModel> tasks) {
    if (tasks.isEmpty) return [];

    final out = List<StopStatus>.generate(
      tasks.length,
      (_) => StopStatus.pending,
    );

    for (var i = 0; i < tasks.length; i++) {
      if (tasks[i].isFullyCompleted) {
        out[i] = StopStatus.completed;
      }
    }

    final firstIncomplete = out.indexWhere((s) => s != StopStatus.completed);
    if (firstIncomplete >= 0) {
      out[firstIncomplete] = StopStatus.active;
    }

    return out;
  }

  bool get isFullyCompleted =>
      taskChildren.isNotEmpty && taskChildren.every((c) => c.isCompleted);

  bool get isNotStarted =>
      taskChildren.isEmpty ||
      taskChildren.every((c) => c.isPending);

  bool get isInProgress {
    if (taskChildren.isEmpty) return false;
    final anyDone = taskChildren.any((c) => c.isCompleted);
    return anyDone && !isFullyCompleted;
  }

  bool get hasStockRequest => taskChildren.any((c) => c.isStockRequest);
  bool get hasStockTake => taskChildren.any((c) => c.isStockTake);

  bool get isStockRequestCompleted =>
      taskChildren.any((c) => c.isStockRequest && c.isCompleted);

  bool get isStockTakeCompleted =>
      taskChildren.any((c) => c.isStockTake && c.isCompleted);

  @override
  List<Object?> get props => [id, name, address, latitude, longitude, status];
}
