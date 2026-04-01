import 'package:flutter/material.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_text_styles.dart';
import '../../../components/app_card.dart';
import '../../../components/progress_bar_widget.dart';
import '../../../components/badge_widget.dart';
import '../../main_shell/cubit/navigation_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

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
            const Text('Ahmed Raza', style: AppTextStyles.title),
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
              child: const Text(
                'AR',
                style: TextStyle(
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildKpiGrid(),
            const SizedBox(height: 16),
            _buildTodayRoute(context),
            const SizedBox(height: 16),
            const Text('QUICK ACTIONS', style: AppTextStyles.sectionHeader),
            const SizedBox(height: 8),
            _buildQuickActions(context),
            const SizedBox(height: 16),
            const Text('RECENT ALERTS', style: AppTextStyles.sectionHeader),
            const SizedBox(height: 8),
            _buildAlerts(),
          ],
        ),
      ),
    );
  }

  Widget _buildKpiGrid() {
    return Row(
      children: [
        Expanded(
          child: AppKpiCard(value: '12', label: 'Total Tasks'),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: AppKpiCard(
            value: '7',
            label: 'Completed',
            valueColor: AppColors.successText,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: AppKpiCard(
            value: '2',
            label: 'In-Process',
            valueColor: AppColors.infoText,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: AppKpiCard(
            value: '3',
            label: 'Pending',
            valueColor: AppColors.warningText,
          ),
        ),
      ],
    );
  }

  Widget _buildTodayRoute(BuildContext context) {
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
              const AppBadge(text: 'MAT-DT-2026-00001', type: BadgeType.primary),
            ],
          ),
          const SizedBox(height: 12),
          _routeStop('Al-Fatah Sports Hub', 'Gulberg III · Done 8:45 AM', true),
          _routeStop('Metro Sports Center', 'DHA Phase 5 · 2.1 km away', false, isActive: true),
          _routeStop('National Sports Depot', 'Johar Town · 5.4 km away', false),
          _routeStop('Champion Gear Outlet', 'Model Town · 8.2 km away', false, isLast: true),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Route Progress', style: AppTextStyles.caption),
              const Text(
                '1 of 4 stops',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const AppProgressBar(progress: 0.25),
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

  Widget _routeStop(
    String name,
    String detail,
    bool isDone, {
    bool isActive = false,
    bool isLast = false,
  }) {
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
                  name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textHigh,
                  ),
                ),
                Text(
                  detail,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMedium,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _quickAction(
            Icons.map_outlined,
            'View Route',
            () => context.read<NavigationCubit>().goToRoutes(),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _quickAction(Icons.location_on_outlined, 'New Visit', () {}),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _quickAction(Icons.description_outlined, 'Reports', () {}),
        ),
      ],
    );
  }

  Widget _quickAction(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
          boxShadow: AppColors.shadow,
        ),
        child: Column(
          children: [
            Icon(icon, size: 24, color: AppColors.primary),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textMedium,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlerts() {
    return AppCard(
      child: Column(
        children: [
          _alertItem(
            AppColors.warningText,
            'Stock Request SR-2026-0401-00023 approved',
            '2 hours ago',
          ),
          const Divider(color: AppColors.border, height: 16),
          _alertItem(
            AppColors.errorText,
            'Inventory discrepancy detected at Stop 1',
            '3 hours ago',
          ),
        ],
      ),
    );
  }

  Widget _alertItem(Color dotColor, String text, String time) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.only(top: 4),
          decoration: BoxDecoration(shape: BoxShape.circle, color: dotColor),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                text,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textHigh,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                time,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textMedium,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
