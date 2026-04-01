import 'package:flutter_bloc/flutter_bloc.dart';
import 'checkin_event.dart';
import 'checkin_state.dart';

class CheckinBloc extends Bloc<CheckinEvent, CheckinState> {
  CheckinBloc() : super(CheckinInitial()) {
    on<PerformCheckin>(_onPerformCheckin);
  }

  Future<void> _onPerformCheckin(
    PerformCheckin event,
    Emitter<CheckinState> emit,
  ) async {
    emit(CheckinLoading());
    try {
      // TODO: Replace with actual API call and GPS location
      await Future.delayed(const Duration(milliseconds: 800));
      emit(const CheckinSuccess(
        checkinTime: '10:23 AM',
        distanceFromCenter: 68,
      ));
    } catch (e) {
      emit(CheckinError(e.toString()));
    }
  }
}
