import 'package:equatable/equatable.dart';

abstract class RoutesEvent extends Equatable {
  const RoutesEvent();
  @override
  List<Object?> get props => [];
}

class LoadRoutes extends RoutesEvent {
  final String employeeId;
  const LoadRoutes({required this.employeeId});

  @override
  List<Object?> get props => [employeeId];
}
