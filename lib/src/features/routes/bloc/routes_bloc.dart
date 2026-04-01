import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/models/route_stop_model.dart';
import 'routes_event.dart';
import 'routes_state.dart';

class RoutesBloc extends Bloc<RoutesEvent, RoutesState> {
  RoutesBloc() : super(RoutesInitial()) {
    on<LoadRoutes>(_onLoadRoutes);
  }

  Future<void> _onLoadRoutes(
    LoadRoutes event,
    Emitter<RoutesState> emit,
  ) async {
    emit(RoutesLoading());
    try {
      // TODO: Replace with actual API call via RoutesRepository
      await Future.delayed(const Duration(milliseconds: 600));
      emit(RoutesLoaded(
        stops: _mockStops,
        completedCount: 1,
        totalDistanceLeft: 15.7,
      ));
    } catch (e) {
      emit(RoutesError(e.toString()));
    }
  }

  static final _mockStops = [
    const RouteStopModel(
      id: '1',
      name: 'Al-Fatah Sports Hub',
      address: 'Gulberg III',
      latitude: 31.5204,
      longitude: 74.3587,
      status: StopStatus.completed,
      distanceKm: 0,
      taskCount: 3,
      completedTime: '8:45 AM',
    ),
    const RouteStopModel(
      id: '2',
      name: 'Metro Sports Center',
      address: 'DHA Phase 5',
      latitude: 31.4712,
      longitude: 74.4000,
      status: StopStatus.active,
      distanceKm: 2.1,
      taskCount: 3,
      eta: '~8 min',
    ),
    const RouteStopModel(
      id: '3',
      name: 'National Sports Depot',
      address: 'Johar Town',
      latitude: 31.4697,
      longitude: 74.2728,
      status: StopStatus.pending,
      distanceKm: 5.4,
      taskCount: 4,
    ),
    const RouteStopModel(
      id: '4',
      name: 'Champion Gear Outlet',
      address: 'Model Town',
      latitude: 31.4830,
      longitude: 74.3254,
      status: StopStatus.pending,
      distanceKm: 8.2,
      taskCount: 2,
    ),
  ];
}
