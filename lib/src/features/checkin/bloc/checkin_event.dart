import 'package:equatable/equatable.dart';

abstract class CheckinEvent extends Equatable {
  const CheckinEvent();
  @override
  List<Object?> get props => [];
}

class PerformCheckin extends CheckinEvent {
  final String stopId;
  const PerformCheckin(this.stopId);

  @override
  List<Object?> get props => [stopId];
}
