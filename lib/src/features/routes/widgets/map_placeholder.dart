import 'package:flutter/material.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/models/route_stop_model.dart';

class MapPlaceholder extends StatelessWidget {
  final List<RouteStopModel> stops;
  final RouteStopModel? activeStop;

  const MapPlaceholder({
    super.key,
    required this.stops,
    this.activeStop,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: const Color(0xFFE8ECEF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          _buildGridLines(),
          _buildRoutePath(),
          _buildPins(),
          _buildCurrentLocation(),
          if (activeStop != null) _buildOverlay(),
        ],
      ),
    );
  }

  Widget _buildGridLines() {
    return Positioned.fill(
      child: CustomPaint(painter: _GridPainter()),
    );
  }

  Widget _buildRoutePath() {
    return Positioned.fill(
      child: CustomPaint(painter: _RoutePathPainter(stops.length)),
    );
  }

  Widget _buildPins() {
    final positions = _pinPositions;
    return Stack(
      children: List.generate(stops.length, (i) {
        final stop = stops[i];
        final pos = positions[i];
        return Positioned(
          left: pos.dx - 10,
          top: pos.dy - 10,
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _pinColor(stop.status),
              border: Border.all(color: Colors.white, width: 2.5),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x30000000),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                '${i + 1}',
                style: const TextStyle(
                  fontSize: 9,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  List<Offset> get _pinPositions {
    return const [
      Offset(80, 70),
      Offset(190, 110),
      Offset(250, 70),
      Offset(160, 45),
    ];
  }

  Color _pinColor(StopStatus status) {
    switch (status) {
      case StopStatus.completed:
        return AppColors.successText;
      case StopStatus.active:
        return AppColors.primary;
      case StopStatus.pending:
        return AppColors.textLow;
    }
  }

  Widget _buildCurrentLocation() {
    return Positioned(
      left: 145,
      top: 90,
      child: Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.primary,
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: const [
            BoxShadow(
              color: Color(0x30000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverlay() {
    return Positioned(
      bottom: 12,
      left: 12,
      right: 12,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: AppColors.shadowLg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'CURRENT LEG',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textMedium,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              activeStop!.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textHigh,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _legInfoItem('Distance', '${activeStop!.distanceKm} km'),
                _legInfoItem('ETA', activeStop!.eta ?? '--'),
                _legInfoItem('Tasks', '${activeStop!.taskCount}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _legInfoItem(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textMedium,
            ),
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

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.textLow.withValues(alpha: 0.2)
      ..strokeWidth = 0.5;

    canvas.drawLine(
      Offset(0, size.height * 0.4),
      Offset(size.width, size.height * 0.4),
      paint,
    );
    canvas.drawLine(
      Offset(0, size.height * 0.65),
      Offset(size.width, size.height * 0.65),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.3, 0),
      Offset(size.width * 0.3, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.6, 0),
      Offset(size.width * 0.6, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RoutePathPainter extends CustomPainter {
  final int stopCount;
  _RoutePathPainter(this.stopCount);

  @override
  void paint(Canvas canvas, Size size) {
    if (stopCount < 2) return;
    final paint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.5)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    const points = [
      Offset(80, 70),
      Offset(190, 110),
      Offset(250, 70),
      Offset(160, 45),
    ];
    path.moveTo(points[0].dx, points[0].dy);
    for (var i = 1; i < points.length && i < stopCount; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    final dashPath = Path();
    const dashLength = 6.0;
    const gapLength = 4.0;
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final end = (distance + dashLength).clamp(0, metric.length).toDouble();
        dashPath.addPath(metric.extractPath(distance, end), Offset.zero);
        distance += dashLength + gapLength;
      }
    }
    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
