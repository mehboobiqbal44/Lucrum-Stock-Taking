import 'package:equatable/equatable.dart';

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
  });

  factory RouteStopModel.fromJson(Map<String, dynamic> json) {
    return RouteStopModel(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      status: StopStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => StopStatus.pending,
      ),
      distanceKm: (json['distance_km'] as num?)?.toDouble() ?? 0,
      taskCount: json['task_count'] as int? ?? 0,
      completedTime: json['completed_time'] as String?,
      eta: json['eta'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'address': address,
    'latitude': latitude,
    'longitude': longitude,
    'status': status.name,
    'distance_km': distanceKm,
    'task_count': taskCount,
    'completed_time': completedTime,
    'eta': eta,
  };

  @override
  List<Object?> get props => [id, name, address, latitude, longitude, status];
}
