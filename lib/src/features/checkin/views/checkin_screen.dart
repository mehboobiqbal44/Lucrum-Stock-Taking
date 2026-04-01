import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_text_styles.dart';
import '../../../core/routes/app_router.dart';
import '../../../core/models/route_stop_model.dart';
import '../../../components/app_button.dart';
import '../../../components/app_card.dart';
import '../bloc/checkin_bloc.dart';
import '../bloc/checkin_event.dart';
import '../bloc/checkin_state.dart';

class CheckinScreen extends StatelessWidget {
  final RouteStopModel stop;

  const CheckinScreen({super.key, required this.stop});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CheckinBloc()..add(PerformCheckin(stop.id)),
      child: _CheckinView(stop: stop),
    );
  }
}

class _CheckinView extends StatelessWidget {
  final RouteStopModel stop;

  const _CheckinView({required this.stop});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textHigh),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('${stop.name} Hub', style: AppTextStyles.title),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body: BlocBuilder<CheckinBloc, CheckinState>(
        builder: (context, state) {
          if (state is CheckinLoading) {
            return _buildLoading();
          }
          if (state is CheckinSuccess) {
            return _buildSuccess(context, state);
          }
          if (state is CheckinError) {
            return Center(
              child: Text(state.message, style: AppTextStyles.caption),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: AppColors.primary),
          const SizedBox(height: 16),
          Text(
            'Checking in at ${stop.name}...',
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }

  Widget _buildSuccess(BuildContext context, CheckinSuccess state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSuccessHeader(state),
          const SizedBox(height: 16),
          _buildLocationCard(),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Complete Tasks',
              style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 12),
          _buildTaskHubGrid(context),
          const SizedBox(height: 20),
          AppButton(
            text: 'Resume Route',
            isSecondary: true,
            icon: const Icon(Icons.directions, size: 20, color: AppColors.textHigh),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessHeader(CheckinSuccess state) {
    return Column(
      children: [
        const SizedBox(height: 8),
        Container(
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
        const SizedBox(height: 16),
        const Text('Checked In Successfully', style: AppTextStyles.heading),
        const SizedBox(height: 4),
        Text(
          '${stop.name} · ${state.checkinTime}',
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textMedium,
          ),
        ),
      ],
    );
  }

  Widget _buildLocationCard() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'LOCATION DETAILS',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textMedium,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            stop.name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textHigh,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            stop.address,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskHubGrid(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _TaskHubCard(
                icon: Icons.shopping_cart,
                label: 'Stock\nRequest',
                onTap: () => Navigator.pushNamed(
                  context,
                  AppRouter.stockRequest,
                  arguments: stop.id,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _TaskHubCard(
                icon: Icons.inventory,
                label: 'Stock Take /\nInventory',
                onTap: () => Navigator.pushNamed(
                  context,
                  AppRouter.stockTake,
                  arguments: stop.id,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TaskHubCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _TaskHubCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary, width: 1.5),
        ),
        child: Column(
          children: [
            Icon(icon, size: 36, color: AppColors.primary),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
