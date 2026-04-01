import 'package:equatable/equatable.dart';

abstract class CheckinState extends Equatable {
  const CheckinState();
  @override
  List<Object?> get props => [];
}

class CheckinInitial extends CheckinState {}

class CheckinLoading extends CheckinState {}

class CheckinSuccess extends CheckinState {
  final String checkinTime;
  final double distanceFromCenter;

  const CheckinSuccess({
    required this.checkinTime,
    required this.distanceFromCenter,
  });

  @override
  List<Object?> get props => [checkinTime, distanceFromCenter];
}

class CheckinError extends CheckinState {
  final String message;
  const CheckinError(this.message);

  @override
  List<Object?> get props => [message];
}
