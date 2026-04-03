import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_text_styles.dart';
import '../../../core/utils/current_user.dart';
import '../../../core/utils/checkin_proximity.dart';
import '../../../core/utils/distance_utils.dart';
import '../../../core/utils/location_helper.dart';
import '../../../core/utils/route_directions_service.dart';
import '../../../core/routes/app_router.dart';
import '../../../core/models/route_stop_model.dart';
import '../../../components/app_button.dart';
import '../bloc/routes_bloc.dart';
import '../bloc/routes_event.dart';
import '../bloc/routes_state.dart';

class RoutesScreen extends StatelessWidget {
  const RoutesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _RoutesView();
  }
}

class _RoutesView extends StatefulWidget {
  const _RoutesView();

  @override
  State<_RoutesView> createState() => _RoutesViewState();
}

class _RoutesViewState extends State<_RoutesView> {
  final MapController _mapController = MapController();
  bool _mapReady = false;
  bool _journeyStarted = false;

  LatLng? _userPosition;
  RouteInfo? _routeInfo;
  bool _loadingRoute = false;
  bool _routeFetched = false;

  StreamSubscription<Position>? _positionSub;
  final Set<String> _autoCheckedStopIds = {};

  @override
  void initState() {
    super.initState();
    _initUserLocation();
  }

  Future<void> _initUserLocation() async {
    final pos = await LocationHelper.getCurrentLatLng();
    if (mounted && pos != null) {
      setState(() => _userPosition = pos);
    }
  }

  // ── Route polyline ──────────────────────────────────────

  Future<void> _fetchRoute(
    List<RouteStopModel> stops, {
    bool includeUser = false,
  }) async {
    if (_loadingRoute) return;
    setState(() => _loadingRoute = true);

    final waypoints = <LatLng>[];
    if (includeUser && _userPosition != null) {
      waypoints.add(_userPosition!);
    }
    for (final stop in stops) {
      if (stop.latitude != 0 || stop.longitude != 0) {
        waypoints.add(LatLng(stop.latitude, stop.longitude));
      }
    }

    if (waypoints.length >= 2) {
      final info = await RouteDirectionsService.getRoute(waypoints);
      if (mounted) {
        setState(() {
          _routeInfo = info;
          _loadingRoute = false;
          _routeFetched = true;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _loadingRoute = false;
          _routeFetched = true;
        });
      }
    }
  }

  // ── Journey lifecycle ───────────────────────────────────

  void _startJourney(List<RouteStopModel> stops) {
    setState(() => _journeyStarted = true);
    _fetchRoute(stops, includeUser: true);
    _startLocationTracking(stops);
    if (_userPosition != null && _mapReady) {
      _mapController.move(_userPosition!, 14);
    }
  }

  void _endJourney() {
    _positionSub?.cancel();
    _positionSub = null;
    setState(() {
      _journeyStarted = false;
      _autoCheckedStopIds.clear();
    });
  }

  // ── GPS tracking & geofence ─────────────────────────────

  void _startLocationTracking(List<RouteStopModel> stops) {
    _positionSub?.cancel();
    _positionSub = LocationHelper.positionStream().listen(
      (position) {
        if (!mounted) return;
        final newPos = LatLng(position.latitude, position.longitude);
        setState(() => _userPosition = newPos);
        _checkGeofence(stops, newPos);
      },
      onError: (_) {},
    );
  }

  void _checkGeofence(List<RouteStopModel> stops, LatLng userPos) {
    for (final stop in stops) {
      if (_autoCheckedStopIds.contains(stop.id)) continue;
      if (stop.latitude == 0 && stop.longitude == 0) continue;

      final km = DistanceUtils.kmBetween(
        userPos,
        LatLng(stop.latitude, stop.longitude),
      );

      if (km <= CheckinProximity.maxRadiusKm) {
        _autoCheckedStopIds.add(stop.id);
        _triggerAutoCheckin(stop);
        break;
      }
    }
  }

  Future<void> _triggerAutoCheckin(RouteStopModel stop) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _AutoCheckinDialog(stop: stop),
    );
    if (!mounted) return;
    Navigator.pushNamed(context, AppRouter.checkin, arguments: stop);
  }

  // ── Map helpers ─────────────────────────────────────────

  void _fitBounds(List<RouteStopModel> stops) {
    if (!_mapReady) return;

    final points = <LatLng>[];
    if (_userPosition != null) points.add(_userPosition!);
    for (final s in stops) {
      if (s.latitude != 0 || s.longitude != 0) {
        points.add(LatLng(s.latitude, s.longitude));
      }
    }
    if (points.length < 2) {
      if (points.length == 1) {
        _mapController.move(points.first, 14);
      }
      return;
    }

    var minLat = double.infinity, maxLat = -double.infinity;
    var minLng = double.infinity, maxLng = -double.infinity;
    for (final p in points) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }

    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: LatLngBounds(
          LatLng(minLat, minLng),
          LatLng(maxLat, maxLng),
        ),
        padding: const EdgeInsets.fromLTRB(60, 60, 60, 220),
      ),
    );
  }

  void _openNavigation(RouteStopModel stop) async {
    final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
      '&destination=${stop.latitude},${stop.longitude}'
      '&travelmode=driving',
    );
    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open navigation app')),
        );
      }
    }
  }

  void _reload() {
    context.read<RoutesBloc>().add(
          LoadRoutes(employeeId: CurrentUser.instance.employeeId),
        );
    setState(() => _routeFetched = false);
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  // ── Build ───────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          _journeyStarted ? 'Journey Active' : 'Route Map',
          style: AppTextStyles.title,
        ),
        centerTitle: false,
        actions: [
          if (_journeyStarted)
            TextButton(
              onPressed: _endJourney,
              child: const Text(
                'End',
                style: TextStyle(
                  color: AppColors.errorText,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body: BlocConsumer<RoutesBloc, RoutesState>(
        listener: (context, state) {
          if (state is RoutesLoaded && !_routeFetched) {
            _fetchRoute(state.stops);
          }
        },
        builder: (context, state) {
          if (state is RoutesLoading) return _buildLoadingState();
          if (state is RoutesLoaded) {
            if (state.stops.isEmpty) return _buildEmptyState();
            return _buildMapView(context, state);
          }
          if (state is RoutesError) return _buildErrorState(state.message);
          return const SizedBox.shrink();
        },
      ),
    );
  }

  // ── States ──────────────────────────────────────────────

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: AppColors.primary),
          SizedBox(height: 16),
          Text(
            'Loading tasks...',
            style: TextStyle(fontSize: 14, color: AppColors.textMedium),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.route_outlined,
                size: 64, color: AppColors.textLow),
            const SizedBox(height: 16),
            const Text(
              'No Tasks Assigned',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textHigh,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'You don\'t have any tasks assigned for today.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppColors.textMedium),
            ),
            const SizedBox(height: 20),
            AppButton(text: 'Refresh', width: 140, onPressed: _reload),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline,
                size: 56, color: AppColors.errorText),
            const SizedBox(height: 16),
            const Text(
              'Failed to load tasks',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textHigh,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: AppColors.textMedium),
            ),
            const SizedBox(height: 20),
            AppButton(text: 'Retry', width: 140, onPressed: _reload),
          ],
        ),
      ),
    );
  }

  // ── Map view ────────────────────────────────────────────

  Widget _buildMapView(BuildContext context, RoutesLoaded state) {
    final firstValid = state.stops.firstWhere(
      (s) => s.latitude != 0 || s.longitude != 0,
      orElse: () => state.stops.first,
    );
    final fallbackCenter =
        _userPosition ?? LatLng(firstValid.latitude, firstValid.longitude);

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: fallbackCenter,
            initialZoom: 13,
            onMapReady: () {
              _mapReady = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _fitBounds(state.stops);
              });
            },
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.lucrumx.stocktaking',
            ),
            _buildPolylineLayer(state),
            MarkerLayer(markers: _buildStopMarkers(context, state)),
            if (_userPosition != null)
              MarkerLayer(
                markers: [
                  Marker(
                    point: _userPosition!,
                    width: 32,
                    height: 32,
                    child: const _UserLocationDot(),
                  ),
                ],
              ),
          ],
        ),
        // Map control buttons
        Positioned(
          right: 16,
          top: 16,
          child: Column(
            children: [
              if (_userPosition != null)
                _MapFab(
                  heroTag: 'recenter',
                  icon: Icons.my_location,
                  onPressed: () {
                    if (_mapReady) {
                      _mapController.move(_userPosition!, 15);
                    }
                  },
                ),
              const SizedBox(height: 8),
              _MapFab(
                heroTag: 'fitall',
                icon: Icons.fit_screen,
                onPressed: () => _fitBounds(state.stops),
              ),
            ],
          ),
        ),
        // Route info chip
        if (_routeInfo != null && _routeInfo!.isRoadRoute)
          Positioned(
            top: 16,
            left: 16,
            child: _RouteInfoChip(info: _routeInfo!),
          ),
        if (_loadingRoute)
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                      color: Color(0x18000000), blurRadius: 8, offset: Offset(0, 2))
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.primary),
                  ),
                  SizedBox(width: 8),
                  Text('Loading route...',
                      style: TextStyle(fontSize: 12, color: AppColors.textMedium)),
                ],
              ),
            ),
          ),
        // Bottom panel
        _buildBottomPanel(context, state),
      ],
    );
  }

  // ── Polyline layer ──────────────────────────────────────

  Widget _buildPolylineLayer(RoutesLoaded state) {
    if (_routeInfo != null && _routeInfo!.points.length >= 2) {
      return PolylineLayer(
        polylines: [
          Polyline(
            points: _routeInfo!.points,
            color: AppColors.primary,
            strokeWidth: _routeInfo!.isRoadRoute ? 4.5 : 3,
            pattern: _routeInfo!.isRoadRoute
                ? const StrokePattern.solid()
                : const StrokePattern.dotted(),
          ),
        ],
      );
    }

    final fallbackPoints = state.stops
        .where((s) => s.latitude != 0 || s.longitude != 0)
        .map((s) => LatLng(s.latitude, s.longitude))
        .toList();
    if (fallbackPoints.length < 2) return const SizedBox.shrink();

    return PolylineLayer(
      polylines: [
        Polyline(
          points: fallbackPoints,
          color: AppColors.primary.withValues(alpha: 0.5),
          strokeWidth: 3,
          pattern: const StrokePattern.dotted(),
        ),
      ],
    );
  }

  // ── Stop markers ────────────────────────────────────────

  List<Marker> _buildStopMarkers(BuildContext context, RoutesLoaded state) {
    return List.generate(state.stops.length, (i) {
      final stop = state.stops[i];
      return Marker(
        point: LatLng(stop.latitude, stop.longitude),
        width: 40,
        height: 40,
        child: GestureDetector(
          onTap: () => _onMarkerTap(context, stop),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _markerColor(stop.status),
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x40000000),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: stop.status == StopStatus.completed
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : Text(
                      '${i + 1}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ),
      );
    });
  }

  Color _markerColor(StopStatus status) {
    switch (status) {
      case StopStatus.completed:
        return AppColors.successText;
      case StopStatus.active:
        return AppColors.primary;
      case StopStatus.pending:
        return AppColors.textLow;
    }
  }

  // ── Marker interactions ─────────────────────────────────

  void _onMarkerTap(BuildContext context, RouteStopModel stop) {
    if (_journeyStarted) {
      _autoCheckedStopIds.add(stop.id);
      _triggerAutoCheckin(stop);
    } else {
      _showStopInfo(context, stop);
    }
  }

  void _showStopInfo(BuildContext context, RouteStopModel stop) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(stop.name, style: AppTextStyles.subtitle),
            const SizedBox(height: 4),
            Text(stop.address, style: AppTextStyles.bodySmall),
            if (stop.subject != null && stop.subject!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                stop.subject!,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMedium,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            if (_userPosition != null &&
                (stop.latitude != 0 || stop.longitude != 0)) ...[
              const SizedBox(height: 12),
              _distanceRow(stop),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                _infoChip('Tasks', '${stop.taskCount}'),
                if (stop.hasStockRequest) ...[
                  const SizedBox(width: 12),
                  _infoChip('Request', 'Yes'),
                ],
                if (stop.hasStockTake) ...[
                  const SizedBox(width: 12),
                  _infoChip('Stock Take', 'Yes'),
                ],
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    text: 'Navigate',
                    icon: const Icon(Icons.navigation,
                        size: 18, color: Colors.white),
                    onPressed: () {
                      Navigator.pop(context);
                      _openNavigation(stop);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppButton(
                    text: 'Check-in',
                    isSecondary: true,
                    icon: const Icon(Icons.login,
                        size: 18, color: AppColors.textHigh),
                    onPressed: () async {
                      Navigator.pop(sheetContext);
                      final result = await CheckinProximity.validate(stop);
                      if (!context.mounted) return;
                      if (!result.allowed) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(result.message),
                            backgroundColor: AppColors.errorText,
                          ),
                        );
                        return;
                      }
                      Navigator.pushNamed(
                        context,
                        AppRouter.checkin,
                        arguments: stop,
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _distanceRow(RouteStopModel stop) {
    final km = DistanceUtils.kmBetween(
      _userPosition!,
      LatLng(stop.latitude, stop.longitude),
    );
    return Row(
      children: [
        const Icon(Icons.near_me, size: 14, color: AppColors.primary),
        const SizedBox(width: 6),
        Text(
          DistanceUtils.formatDistanceKm(km),
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _infoChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(label,
              style:
                  const TextStyle(fontSize: 10, color: AppColors.textMedium)),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textHigh,
            ),
          ),
        ],
      ),
    );
  }

  // ── Bottom panel ────────────────────────────────────────

  Widget _buildBottomPanel(BuildContext context, RoutesLoaded state) {
    final activeStop = state.activeStop;
    if (activeStop == null) return const SizedBox.shrink();

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          boxShadow: [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 20,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: _journeyStarted
                ? _journeyPanel(context, state, activeStop)
                : _preJourneyPanel(context, state, activeStop),
          ),
        ),
      ),
    );
  }

  Widget _preJourneyPanel(
      BuildContext context, RoutesLoaded state, RouteStopModel activeStop) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _handle(),
        const Text(
          'NEXT STOP',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textMedium,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(activeStop.name, style: AppTextStyles.subtitle),
        if (activeStop.subject != null &&
            activeStop.subject!.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            activeStop.subject!,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, color: AppColors.textMedium),
          ),
        ],
        const SizedBox(height: 12),
        Row(
          children: [
            _legInfo('Tasks', '${activeStop.taskCount}'),
            _legInfo(
              'Stops',
              '${state.completedCount}/${state.stops.length}',
            ),
            if (_routeInfo != null && _routeInfo!.isRoadRoute)
              _legInfo(
                'Distance',
                '${_routeInfo!.distanceKm.toStringAsFixed(1)} km',
              )
            else
              _legInfo('Warehouse', activeStop.sourceWarehouse ?? '--'),
          ],
        ),
        const SizedBox(height: 16),
        AppButton(
          text: 'Start Journey',
          icon:
              const Icon(Icons.play_arrow, size: 20, color: Colors.white),
          onPressed: () => _startJourney(state.stops),
        ),
      ],
    );
  }

  Widget _journeyPanel(
      BuildContext context, RoutesLoaded state, RouteStopModel activeStop) {
    final distStr = _userPosition != null &&
            (activeStop.latitude != 0 || activeStop.longitude != 0)
        ? DistanceUtils.formatDistanceKm(
            DistanceUtils.kmBetween(
              _userPosition!,
              LatLng(activeStop.latitude, activeStop.longitude),
            ),
          )
        : 'Calculating…';

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _handle(),
        Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.successText,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.successText.withValues(alpha: 0.4),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Journey in progress',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.successText,
              ),
            ),
            const Spacer(),
            Text(
              '${state.completedCount}/${state.stops.length} done',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textMedium,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.location_on,
                    color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activeStop.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textHigh,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      distStr,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _NavigateButton(
                  onTap: () => _openNavigation(activeStop)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Auto check-in triggers within 200 m of a stop',
          style: TextStyle(
            fontSize: 11,
            color: AppColors.textLow,
          ),
        ),
      ],
    );
  }

  Widget _handle() {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.border,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _legInfo(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style:
                  const TextStyle(fontSize: 11, color: AppColors.textMedium)),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textHigh,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Small widgets ─────────────────────────────────────────

class _UserLocationDot extends StatelessWidget {
  const _UserLocationDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.blue.withValues(alpha: 0.15),
      ),
      child: Center(
        child: Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.blue,
            border: Border.all(color: Colors.white, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withValues(alpha: 0.4),
                blurRadius: 8,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MapFab extends StatelessWidget {
  final String heroTag;
  final IconData icon;
  final VoidCallback onPressed;

  const _MapFab({
    required this.heroTag,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      mini: true,
      heroTag: heroTag,
      backgroundColor: AppColors.surface,
      elevation: 3,
      onPressed: onPressed,
      child: Icon(icon, color: AppColors.primary, size: 20),
    );
  }
}

class _RouteInfoChip extends StatelessWidget {
  final RouteInfo info;
  const _RouteInfoChip({required this.info});

  @override
  Widget build(BuildContext context) {
    final km = info.distanceKm.toStringAsFixed(1);
    final min = info.durationMin.round();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
              color: Color(0x18000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.route, size: 14, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            '$km km  ·  ~$min min',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textHigh,
            ),
          ),
        ],
      ),
    );
  }
}

class _NavigateButton extends StatelessWidget {
  final VoidCallback onTap;
  const _NavigateButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.navigation, size: 16, color: Colors.white),
              SizedBox(width: 6),
              Text(
                'Navigate',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AutoCheckinDialog extends StatefulWidget {
  final RouteStopModel stop;

  const _AutoCheckinDialog({required this.stop});

  @override
  State<_AutoCheckinDialog> createState() => _AutoCheckinDialogState();
}

class _AutoCheckinDialogState extends State<_AutoCheckinDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    _controller.forward();

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) Navigator.pop(context);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.successBg,
                ),
                child: const Icon(
                  Icons.check_circle,
                  size: 48,
                  color: AppColors.successText,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Auto Check-In',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textHigh,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Arrived at ${widget.stop.name}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textMedium,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Checking you in...',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
