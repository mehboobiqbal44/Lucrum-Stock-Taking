import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_text_styles.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/models/route_stop_model.dart';
import '../../../components/app_button.dart';
import '../data/stock_take_service.dart';
import '../data/stock_take_repository.dart';
import '../bloc/stock_take_bloc.dart';
import '../bloc/stock_take_event.dart';
import '../bloc/stock_take_state.dart';
import '../widgets/stock_take_item_card.dart';

class StockTakeScreen extends StatelessWidget {
  final RouteStopModel stop;

  const StockTakeScreen({super.key, required this.stop});

  @override
  Widget build(BuildContext context) {
    final dio = context.read<DioClient>();
    final repo = StockTakeRepository(StockTakeService(dio));

    return BlocProvider(
      create: (_) => StockTakeBloc(repository: repo)
        ..add(LoadInventoryItems(stop.targetWarehouse ?? '')),
      child: _StockTakeView(stop: stop),
    );
  }
}

class _StockTakeView extends StatelessWidget {
  final RouteStopModel stop;

  const _StockTakeView({required this.stop});

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
        title: const Text('Stock Take / Inventory', style: AppTextStyles.title),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body: BlocConsumer<StockTakeBloc, StockTakeState>(
        listener: (context, state) {
          if (state is StockTakeSubmitted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Stock take submitted successfully'),
                backgroundColor: AppColors.successText,
              ),
            );
            Navigator.pop(context, true);
          }
          if (state is StockTakeError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.errorText,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is StockTakeLoading) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: AppColors.primary),
                  SizedBox(height: 16),
                  Text('Loading inventory...', style: AppTextStyles.caption),
                ],
              ),
            );
          }

          if (state is StockTakeSubmitting) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: AppColors.primary),
                  SizedBox(height: 16),
                  Text('Submitting stock take...',
                      style: AppTextStyles.caption),
                ],
              ),
            );
          }

          if (state is StockTakeLoaded) {
            return _buildContent(context, state);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, StockTakeLoaded state) {
    final locked = stop.isStockTakeCompleted;

    return Column(
      children: [
        if (locked)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            color: AppColors.background,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.successBg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.successText.withValues(alpha: 0.35),
                ),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle_outline,
                      size: 18, color: AppColors.successText),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This stock take is already completed. You cannot submit again.',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.successText,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        Expanded(
          child: state.items.isEmpty
              ? const Center(
                  child: Text(
                    'No items found for this warehouse.',
                    style:
                        TextStyle(fontSize: 14, color: AppColors.textMedium),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.items.length,
                  itemBuilder: (context, index) {
                    final item = state.items[index];
                    return StockTakeItemCard(
                      item: item,
                      readOnly: locked,
                      onActualQtyChanged: (qty) {
                        context.read<StockTakeBloc>().add(
                          UpdateActualQty(
                              itemId: item.id, quantity: qty),
                        );
                      },
                    );
                  },
                ),
        ),
        _buildBottomBar(context, state, locked),
      ],
    );
  }

  Widget _buildBottomBar(
      BuildContext context, StockTakeLoaded state, bool locked) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.border),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Counted: ${state.auditedCount} / ${state.totalItems}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMedium,
                  ),
                ),
                if (state.discrepancyCount > 0)
                  Text(
                    '${state.discrepancyCount} variance(s)',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.warningText,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            AppButton(
              text: locked ? 'Already submitted' : 'Submit Item Count',
              icon: Icon(
                locked ? Icons.lock_outline : Icons.check,
                size: 20,
                color: Colors.white,
              ),
              onPressed: locked || state.auditedCount <= 0
                  ? null
                  : () {
                      context.read<StockTakeBloc>().add(
                        SubmitStockTake(
                          sourceWarehouse: stop.sourceWarehouse ?? '',
                          customTask: stop.id,
                        ),
                      );
                    },
            ),
          ],
        ),
      ),
    );
  }
}
