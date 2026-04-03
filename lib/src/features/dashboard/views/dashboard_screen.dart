import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_text_styles.dart';
import '../../../core/utils/current_user.dart';
import '../../../core/utils/distance_utils.dart';
import '../../../core/utils/location_helper.dart';
import '../../../core/models/route_stop_model.dart';
import '../../../components/app_card.dart';
import '../../../components/progress_bar_widget.dart';
import '../../../components/badge_widget.dart';
import '../../main_shell/cubit/navigation_cubit.dart';
import '../../routes/bloc/routes_bloc.dart';
import '../../routes/bloc/routes_event.dart';
import '../../routes/bloc/routes_state.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  LatLng? _userPos;
  bool _locLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLocation();
  }

  Future<void> _loadLocation() async {
    setState(() => _locLoading = true);
    final pos = await LocationHelper.getCurrentLatLng();
    if (!mounted) return;
    setState(() {
      _userPos = pos;
      _locLoading = false;
    });
  }

  Future<void> _onRefresh() async {
    final bloc = context.read<RoutesBloc>();
    bloc.add(LoadRoutes(employeeId: CurrentUser.instance.employeeId));
    await bloc.stream.firstWhere(
      (s) => s is RoutesLoaded || s is RoutesError,
    );
    await _loadLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Good morning,',
              style: AppTextStyles.caption.copyWith(fontSize: 12),
            ),
            Text(CurrentUser.instance.fullName, style: AppTextStyles.title),
          ],
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.notifications_outlined,
                  color: AppColors.textHigh,
                ),
                onPressed: () {},
              ),
              Positioned(
                right: 10,
                top: 10,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.errorText,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.surface, width: 1.5),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primaryLight,
              child: Text(
                CurrentUser.instance.initials,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _onRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BlocBuilder<RoutesBloc, RoutesState>(
                builder: (context, state) {
                  if (state is RoutesLoaded) {
                    return _buildKpiGrid(state.stops);
                  }
                  return _buildKpiPlaceholder();
                },
              ),
              const SizedBox(height: 16),
              BlocBuilder<RoutesBloc, RoutesState>(
                builder: (context, state) {
                  return _buildTodayRoute(context, state);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKpiPlaceholder() {
    return Row(
      children: [
        Expanded(child: AppKpiCard(value: '—', label: '…')),
        const SizedBox(width: 8),
        Expanded(child: AppKpiCard(value: '—', label: '…')),
        const SizedBox(width: 8),
        Expanded(child: AppKpiCard(value: '—', label: '…')),
        const SizedBox(width: 8),
        Expanded(child: AppKpiCard(value: '—', label: '…')),
      ],
    );
  }

  Widget _buildKpiGrid(List<RouteStopModel> stops) {
    final total = stops.length;
    final completed =
        stops.where((s) => s.status == StopStatus.completed).length;
    final inProcess = stops.where((s) => s.isInProgress).length;
    final pending = stops.where((s) => s.isNotStarted).length;

    return Row(
      children: [
        Expanded(child: AppKpiCard(value: '$total', label: 'Total Tasks')),
        const SizedBox(width: 8),
        Expanded(
          child: AppKpiCard(
            value: '$completed',
            label: 'Completed',
            valueColor: AppColors.successText,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: AppKpiCard(
            value: '$inProcess',
            label: 'In-Process',
            valueColor: AppColors.infoText,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: AppKpiCard(
            value: '$pending',
            label: 'Pending',
            valueColor: AppColors.warningText,
          ),
        ),
      ],
    );
  }

  Widget _buildTodayRoute(BuildContext context, RoutesState state) {
    if (state is RoutesLoading || state is RoutesInitial) {
      return AppCard(
        child: SizedBox(
          height: 120,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Loading today\'s tasks…',
                  style: AppTextStyles.caption.copyWith(fontSize: 13),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (state is RoutesError) {
      return AppCard(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Today\'s Route',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textHigh,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                state.message,
                style: const TextStyle(fontSize: 13, color: AppColors.textMedium),
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: () {
                  context.read<RoutesBloc>().add(
                        LoadRoutes(
                          employeeId: CurrentUser.instance.employeeId,
                        ),
                      );
                },
                icon: const Icon(Icons.refresh, size: 18, color: AppColors.primary),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (state is! RoutesLoaded) {
      return const SizedBox.shrink();
    }

    final stops = state.stops;
    if (stops.isEmpty) {
      return AppCard(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Icon(Icons.task_alt, size: 40, color: AppColors.textLow),
              const SizedBox(height: 12),
              const Text(
                'No tasks for today',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textHigh,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'When tasks are assigned they will appear here.',
                textAlign: TextAlign.center,
                style: AppTextStyles.caption.copyWith(fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    final badgeText =
        stops.length == 1 ? stops.first.id : '${stops.length} stops';
    final progress = state.progress.clamp(0.0, 1.0);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Today\'s Route',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textHigh,
                ),
              ),
              AppBadge(text: badgeText, type: BadgeType.primary),
            ],
          ),
          const SizedBox(height: 12),
          ...List.generate(stops.length, (index) {
            final stop = stops[index];
            final isLast = index == stops.length - 1;
            return _routeStopRow(
              stop,
              isLast: isLast,
            );
          }),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Route Progress', style: AppTextStyles.caption),
              Text(
                '${state.completedCount} of ${stops.length} stops',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          AppProgressBar(progress: progress),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                context.read<NavigationCubit>().goToRoutes();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                shadowColor: Colors.transparent,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.map_outlined, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'View Route',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _detailLine(RouteStopModel stop) {
    if (stop.isFullyCompleted) {
      return 'Done';
    }
    if (!_hasTaskCoords(stop)) {
      return 'Location not available for distance';
    }
    if (_locLoading) {
      return 'Calculating distance…';
    }
    if (_userPos == null) {
      return 'Enable location to see distance';
    }
    final km = DistanceUtils.kmBetween(
      _userPos!,
      LatLng(stop.latitude, stop.longitude),
    );
    return DistanceUtils.formatDistanceKm(km);
  }

  bool _hasTaskCoords(RouteStopModel stop) {
    return stop.latitude != 0 || stop.longitude != 0;
  }

  Widget _routeStopRow(
    RouteStopModel stop, {
    required bool isLast,
  }) {
    final isDone = stop.status == StopStatus.completed;
    final isActive = stop.status == StopStatus.active;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDone
                    ? AppColors.successText
                    : isActive
                        ? AppColors.primary
                        : AppColors.border,
                border: Border.all(
                  color: isDone
                      ? AppColors.successText
                      : isActive
                          ? AppColors.primary
                          : AppColors.border,
                  width: 2,
                ),
              ),
            ),
            if (!isLast)
              Container(width: 1, height: 28, color: AppColors.border),
          ],
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stop.name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textHigh,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  stop.address,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMedium,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _detailLine(stop),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDone ? AppColors.successText : AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
