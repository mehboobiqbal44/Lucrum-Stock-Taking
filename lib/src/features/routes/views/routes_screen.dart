import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_text_styles.dart';
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
    return BlocProvider(
      create: (_) => RoutesBloc()..add(LoadRoutes()),
      child: const _RoutesView(),
    );
  }
}

class _RoutesView extends StatefulWidget {
  const _RoutesView();

  @override
  State<_RoutesView> createState() => _RoutesViewState();
}

class _RoutesViewState extends State<_RoutesView> {
  final MapController _mapController = MapController();
  bool _journeyStarted = false;

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
              onPressed: () => setState(() => _journeyStarted = false),
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
      body: BlocBuilder<RoutesBloc, RoutesState>(
        builder: (context, state) {
          if (state is RoutesLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          if (state is RoutesLoaded) {
            return _buildMapView(context, state);
          }
          if (state is RoutesError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(state.message, style: AppTextStyles.caption),
                  const SizedBox(height: 12),
                  AppButton(
                    text: 'Retry',
                    width: 120,
                    onPressed: () =>
                        context.read<RoutesBloc>().add(LoadRoutes()),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildMapView(BuildContext context, RoutesLoaded state) {
    final center = LatLng(
      state.stops.first.latitude,
      state.stops.first.longitude,
    );

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: center,
            initialZoom: 13,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.lucrumx.stocktaking',
            ),
            PolylineLayer(
              polylines: [
                Polyline(
                  points: state.stops
                      .map((s) => LatLng(s.latitude, s.longitude))
                      .toList(),
                  color: AppColors.primary.withValues(alpha: 0.6),
                  strokeWidth: 3,
                  pattern: const StrokePattern.dotted(),
                ),
              ],
            ),
            MarkerLayer(
              markers: _buildMarkers(context, state),
            ),
          ],
        ),
        _buildBottomSheet(context, state),
      ],
    );
  }

  List<Marker> _buildMarkers(BuildContext context, RoutesLoaded state) {
    final markers = <Marker>[];

    for (var i = 0; i < state.stops.length; i++) {
      final stop = state.stops[i];
      markers.add(
        Marker(
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
        ),
      );
    }

    return markers;
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

  void _onMarkerTap(BuildContext context, RouteStopModel stop) {
    if (_journeyStarted) {
      _showAutoCheckinDialog(context, stop);
    } else {
      _showStopInfo(context, stop);
    }
  }

  void _showAutoCheckinDialog(BuildContext context, RouteStopModel stop) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _AutoCheckinDialog(stop: stop),
    ).then((_) {
      if (context.mounted) {
        Navigator.pushNamed(context, AppRouter.checkin, arguments: stop);
      }
    });
  }

  void _showStopInfo(BuildContext context, RouteStopModel stop) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
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
            const SizedBox(height: 16),
            Row(
              children: [
                _infoChip('Distance', '${stop.distanceKm} km'),
                const SizedBox(width: 12),
                _infoChip('Tasks', '${stop.taskCount}'),
                if (stop.eta != null) ...[
                  const SizedBox(width: 12),
                  _infoChip('ETA', stop.eta!),
                ],
              ],
            ),
            const SizedBox(height: 20),
            AppButton(
              text: 'Navigate Here',
              icon: const Icon(Icons.navigation, size: 18, color: Colors.white),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(
                  context,
                  AppRouter.checkin,
                  arguments: stop,
                );
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
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
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: AppColors.textMedium),
          ),
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

  Widget _buildBottomSheet(BuildContext context, RoutesLoaded state) {
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                if (!_journeyStarted) ...[
                  const Text(
                    'CURRENT LEG',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMedium,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(activeStop.name, style: AppTextStyles.subtitle),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _legInfo('Distance', '${activeStop.distanceKm} km'),
                      _legInfo('ETA', activeStop.eta ?? '--'),
                      _legInfo('Tasks', '${activeStop.taskCount}'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  AppButton(
                    text: 'Start Journey',
                    icon: const Icon(Icons.play_arrow, size: 20, color: Colors.white),
                    onPressed: () {
                      setState(() => _journeyStarted = true);
                    },
                  ),
                ] else ...[
                  Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.successText,
                          border: Border.all(color: AppColors.surface, width: 2),
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
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Heading to: ${activeStop.name}',
                    style: AppTextStyles.bodySmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap on a stop marker when you arrive to auto check-in',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textLow,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _legInfo('Distance', '${activeStop.distanceKm} km'),
                      _legInfo('ETA', activeStop.eta ?? '--'),
                      _legInfo(
                        'Progress',
                        '${state.completedCount}/${state.stops.length}',
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _legInfo(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppColors.textMedium),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textHigh,
            ),
          ),
        ],
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
