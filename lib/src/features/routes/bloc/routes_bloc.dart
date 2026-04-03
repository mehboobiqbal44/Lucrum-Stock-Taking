import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/models/route_stop_model.dart';
import '../data/routes_repository.dart';
import 'routes_event.dart';
import 'routes_state.dart';

class RoutesBloc extends Bloc<RoutesEvent, RoutesState> {
  final RoutesRepository _repository;

  RoutesBloc({required RoutesRepository repository})
      : _repository = repository,
        super(RoutesInitial()) {
    on<LoadRoutes>(_onLoadRoutes);
  }

  Future<void> _onLoadRoutes(
    LoadRoutes event,
    Emitter<RoutesState> emit,
  ) async {
    emit(RoutesLoading());
    try {
      final stops = await _repository.getTaskStops(event.employeeId);
      final completedCount =
          stops.where((s) => s.status == StopStatus.completed).length;

      emit(RoutesLoaded(
        stops: stops,
        completedCount: completedCount,
        totalDistanceLeft: 0,
      ));
    } catch (e) {
      emit(RoutesError(e.toString()));
    }
  }
}
