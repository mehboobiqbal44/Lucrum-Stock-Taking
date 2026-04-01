import 'package:equatable/equatable.dart';

abstract class RoutesEvent extends Equatable {
  const RoutesEvent();
  @override
  List<Object?> get props => [];
}

class LoadRoutes extends RoutesEvent {}

class SelectStop extends RoutesEvent {
  final String stopId;
  const SelectStop(this.stopId);

  @override
  List<Object?> get props => [stopId];
}
