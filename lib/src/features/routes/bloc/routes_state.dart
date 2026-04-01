import 'package:equatable/equatable.dart';
import '../../../core/models/route_stop_model.dart';

abstract class RoutesState extends Equatable {
  const RoutesState();
  @override
  List<Object?> get props => [];
}

class RoutesInitial extends RoutesState {}

class RoutesLoading extends RoutesState {}

class RoutesLoaded extends RoutesState {
  final List<RouteStopModel> stops;
  final int completedCount;
  final double totalDistanceLeft;

  const RoutesLoaded({
    required this.stops,
    required this.completedCount,
    required this.totalDistanceLeft,
  });

  RouteStopModel? get activeStop {
    try {
      return stops.firstWhere((s) => s.status == StopStatus.active);
    } catch (_) {
      return null;
    }
  }

  double get progress =>
      stops.isEmpty ? 0 : completedCount / stops.length;

  @override
  List<Object?> get props => [stops, completedCount, totalDistanceLeft];
}

class RoutesError extends RoutesState {
  final String message;
  const RoutesError(this.message);

  @override
  List<Object?> get props => [message];
}
