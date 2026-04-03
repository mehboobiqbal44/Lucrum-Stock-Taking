import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_text_styles.dart';
import '../../../core/utils/checkin_proximity.dart';
import '../../../core/routes/app_router.dart';
import '../../../core/models/route_stop_model.dart';
import '../../../components/app_button.dart';
import '../../../components/app_card.dart';
import '../bloc/checkin_bloc.dart';
import '../bloc/checkin_event.dart';
import '../bloc/checkin_state.dart';

class CheckinScreen extends StatefulWidget {
  final RouteStopModel stop;

  const CheckinScreen({super.key, required this.stop});

  @override
  State<CheckinScreen> createState() => _CheckinScreenState();
}

class _CheckinScreenState extends State<CheckinScreen> {
  bool _checkingLocation = true;
  bool _proximityDenied = false;
  String _proximityMessage = '';

  @override
  void initState() {
    super.initState();
    _verifyProximity();
  }

  Future<void> _verifyProximity() async {
    final result = await CheckinProximity.validate(widget.stop);
    if (!mounted) return;
    setState(() {
      _checkingLocation = false;
      if (!result.allowed) {
        _proximityDenied = true;
        _proximityMessage = result.message;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // if (_checkingLocation) {
    //   return Scaffold(
    //     backgroundColor: AppColors.background,
    //     appBar: AppBar(
    //       backgroundColor: AppColors.surface,
    //       elevation: 0,
    //       leading: IconButton(
    //         icon: const Icon(Icons.arrow_back, color: AppColors.textHigh),
    //         onPressed: () => Navigator.pop(context),
    //       ),
    //       title: Text('${widget.stop.name} Hub', style: AppTextStyles.title),
    //       centerTitle: false,
    //       bottom: PreferredSize(
    //         preferredSize: const Size.fromHeight(1),
    //         child: Container(height: 1, color: AppColors.border),
    //       ),
    //     ),
    //     body: const Center(
    //       child: Column(
    //         mainAxisSize: MainAxisSize.min,
    //         children: [
    //           CircularProgressIndicator(color: AppColors.primary),
    //           SizedBox(height: 16),
    //           Text(
    //             'Verifying your location…',
    //             style: TextStyle(fontSize: 14, color: AppColors.textMedium),
    //           ),
    //         ],
    //       ),
    //     ),
    //   );
    // }

    // if (_proximityDenied) {
    //   return Scaffold(
    //     backgroundColor: AppColors.background,
    //     appBar: AppBar(
    //       backgroundColor: AppColors.surface,
    //       elevation: 0,
    //       leading: IconButton(
    //         icon: const Icon(Icons.arrow_back, color: AppColors.textHigh),
    //         onPressed: () => Navigator.pop(context),
    //       ),
    //       title: Text('${widget.stop.name} Hub', style: AppTextStyles.title),
    //       centerTitle: false,
    //       bottom: PreferredSize(
    //         preferredSize: const Size.fromHeight(1),
    //         child: Container(height: 1, color: AppColors.border),
    //       ),
    //     ),
    //     body: Padding(
    //       padding: const EdgeInsets.all(24),
    //       child: Column(
    //         mainAxisAlignment: MainAxisAlignment.center,
    //         children: [
    //           const Icon(Icons.location_off_outlined,
    //               size: 56, color: AppColors.errorText),
    //           const SizedBox(height: 16),
    //           Text(
    //             _proximityMessage,
    //             textAlign: TextAlign.center,
    //             style: const TextStyle(
    //               fontSize: 15,
    //               height: 1.4,
    //               color: AppColors.textHigh,
    //             ),
    //           ),
    //           const SizedBox(height: 24),
    //           AppButton(
    //             text: 'Go back',
    //             isSecondary: true,
    //             onPressed: () => Navigator.pop(context),
    //           ),
    //         ],
    //       ),
    //     ),
    //   );
    // }

    return BlocProvider(
      create: (_) => CheckinBloc()..add(PerformCheckin(widget.stop.id)),
      child: _CheckinView(stop: widget.stop),
    );
  }
}

class _CheckinView extends StatefulWidget {
  final RouteStopModel stop;

  const _CheckinView({required this.stop});

  @override
  State<_CheckinView> createState() => _CheckinViewState();
}

class _CheckinViewState extends State<_CheckinView> {
  bool _stockRequestDoneLocal = false;
  bool _stockTakeDoneLocal = false;

  RouteStopModel get stop => widget.stop;

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
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 12),
          _buildTaskHubGrid(context),
          const SizedBox(height: 20),
          AppButton(
            text: 'Resume Route',
            isSecondary: true,
            icon: const Icon(
              Icons.directions,
              size: 20,
              color: AppColors.textHigh,
            ),
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
          style: const TextStyle(fontSize: 14, color: AppColors.textMedium),
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
            style: const TextStyle(fontSize: 13, color: AppColors.textMedium),
          ),
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
        ],
      ),
    );
  }

  Widget _buildTaskHubGrid(BuildContext context) {
    final cards = <Widget>[];

    final requestDone =
        stop.isStockRequestCompleted || _stockRequestDoneLocal;
    final takeDone = stop.isStockTakeCompleted || _stockTakeDoneLocal;

    if (stop.hasStockRequest) {
      cards.add(
        Expanded(
          child: _TaskHubCard(
            icon: Icons.shopping_cart,
            label: 'Stock\nRequest',
            showCompleted: requestDone,
            onTap: () async {
              final result = await Navigator.pushNamed(
                context,
                AppRouter.stockRequest,
                arguments: stop,
              );
              if (result == true && mounted) {
                setState(() => _stockRequestDoneLocal = true);
              }
            },
          ),
        ),
      );
    }

    if (stop.hasStockTake) {
      cards.add(
        Expanded(
          child: _TaskHubCard(
            icon: Icons.inventory,
            label: 'Stock Take /\nInventory',
            showCompleted: takeDone,
            onTap: () async {
              final result = await Navigator.pushNamed(
                context,
                AppRouter.stockTake,
                arguments: stop,
              );
              if (result == true && mounted) {
                setState(() => _stockTakeDoneLocal = true);
              }
            },
          ),
        ),
      );
    }

    if (cards.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          'No tasks available for this stop.',
          style: TextStyle(fontSize: 14, color: AppColors.textMedium),
        ),
      );
    }

    if (cards.length == 1) {
      return Row(
        children: [
          ...cards,
          const Expanded(child: SizedBox()),
        ],
      );
    }

    return Row(children: [cards[0], const SizedBox(width: 12), cards[1]]);
  }
}

class _TaskHubCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool showCompleted;

  const _TaskHubCard({
    required this.icon,
    required this.label,
    required this.onTap,
    this.showCompleted = false,
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
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
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
            if (showCompleted)
              Positioned(
                top: -4,
                right: -4,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.successBg,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: AppColors.successText.withValues(alpha: 0.35),
                    ),
                  ),
                  child: const Text(
                    'Completed',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                      color: AppColors.successText,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
