import 'package:equatable/equatable.dart';

class TaskChildModel extends Equatable {
  final String type;
  final String status;

  const TaskChildModel({required this.type, required this.status});

  factory TaskChildModel.fromJson(Map<String, dynamic> json) {
    return TaskChildModel(
      type: json['type'] as String? ?? '',
      status: json['status'] as String? ?? 'Pending',
    );
  }

  String get _s => status.trim().toLowerCase();

  bool get isStockRequest => type == 'Stock Request';
  bool get isStockTake => type == 'Stock Take Form';
  bool get isPending => _s == 'pending';
  bool get isCompleted => _s == 'completed' || _s == 'done';

  @override
  List<Object?> get props => [type, status];
}

class TaskModel extends Equatable {
  final String name;
  final String subject;
  final String customer;
  final String location;
  final String sourceWarehouse;
  final String targetWarehouse;
  final double latitude;
  final double longitude;
  final String assignedTo;
  final List<TaskChildModel> taskChildren;

  const TaskModel({
    required this.name,
    required this.subject,
    required this.customer,
    required this.location,
    required this.sourceWarehouse,
    required this.targetWarehouse,
    required this.latitude,
    required this.longitude,
    required this.assignedTo,
    required this.taskChildren,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    final children = (json['custom_task_child'] as List<dynamic>?)
            ?.map((e) => TaskChildModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    return TaskModel(
      name: json['name'] as String? ?? '',
      subject: json['subject'] as String? ?? '',
      customer: json['custom_customer'] as String? ?? '',
      location: json['custom_location'] as String? ?? '',
      sourceWarehouse: json['custom_source_warehouse'] as String? ?? '',
      targetWarehouse: json['custom_target_warehouse'] as String? ?? '',
      latitude: (json['custom_latitude'] as num?)?.toDouble() ?? 0,
      longitude: (json['custom_longitude'] as num?)?.toDouble() ?? 0,
      assignedTo: json['custom_assigned_to'] as String? ?? '',
      taskChildren: children,
    );
  }

  bool get hasStockRequest => taskChildren.any((c) => c.isStockRequest);
  bool get hasStockTake => taskChildren.any((c) => c.isStockTake);

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

  @override
  List<Object?> get props => [name];
}
