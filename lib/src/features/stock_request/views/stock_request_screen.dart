import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_text_styles.dart';
import '../../../core/routes/app_router.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/models/stock_item_model.dart';
import '../../../core/models/route_stop_model.dart';
import '../../../components/app_button.dart';
import '../../../components/app_text_field.dart';
import '../data/stock_request_service.dart';
import '../data/stock_request_repository.dart';
import '../bloc/stock_request_bloc.dart';
import '../bloc/stock_request_event.dart';
import '../bloc/stock_request_state.dart';
import '../widgets/stock_request_item_card.dart';

class StockRequestScreen extends StatelessWidget {
  final RouteStopModel stop;

  const StockRequestScreen({super.key, required this.stop});

  @override
  Widget build(BuildContext context) {
    final dio = context.read<DioClient>();
    final repo = StockRequestRepository(StockRequestService(dio));

    return BlocProvider(
      create: (_) => StockRequestBloc(repository: repo)
        ..add(LoadWarehouseItems(stop.targetWarehouse ?? '')),
      child: _StockRequestView(stop: stop),
    );
  }
}

class _StockRequestView extends StatelessWidget {
  final RouteStopModel stop;

  const _StockRequestView({required this.stop});

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
        title: const Text('Stock Request', style: AppTextStyles.title),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body: BlocConsumer<StockRequestBloc, StockRequestState>(
        listener: (context, state) {
          if (state is StockRequestSubmitted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Stock request submitted successfully'),
                backgroundColor: AppColors.successText,
              ),
            );
            Navigator.pop(context, true);
          }
          if (state is StockRequestError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.errorText,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is StockRequestLoading) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: AppColors.primary),
                  SizedBox(height: 16),
                  Text('Loading items...', style: AppTextStyles.caption),
                ],
              ),
            );
          }

          if (state is StockRequestSubmitting) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: AppColors.primary),
                  SizedBox(height: 16),
                  Text('Submitting request...', style: AppTextStyles.caption),
                ],
              ),
            );
          }

          if (state is StockRequestLoaded) {
            return _buildContent(context, state);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, StockRequestLoaded state) {
    final locked = stop.isStockRequestCompleted;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (locked) ...[
            Container(
              width: double.infinity,
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
                      'This stock request is already completed. You cannot submit again.',
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
            const SizedBox(height: 12),
          ],
          if (stop.targetWarehouse != null &&
              stop.targetWarehouse!.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.infoBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warehouse_outlined,
                      size: 16, color: AppColors.infoText),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      stop.targetWarehouse!,
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.infoText),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          AppTextField(
            hint: 'Search items...',
            readOnly: locked,
            prefixIcon: const Icon(
              Icons.search,
              size: 20,
              color: AppColors.textMedium,
            ),
            onChanged: locked
                ? null
                : (query) {
                    context.read<StockRequestBloc>().add(SearchItems(query));
                  },
          ),
          const SizedBox(height: 16),
          if (state.filteredItems.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: Text(
                  'No items found for this warehouse.',
                  style: TextStyle(fontSize: 14, color: AppColors.textMedium),
                ),
              ),
            )
          else
            ...state.filteredItems.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: StockRequestItemCard(
                  item: item,
                  readOnly: locked,
                  onQtyChanged: (qty) {
                    context.read<StockRequestBloc>().add(
                      UpdateItemQty(itemId: item.id, quantity: qty),
                    );
                  },
                ),
              ),
            ),
          const SizedBox(height: 12),
          AppButton(
            text: 'Add More Items',
            isOutlined: true,
            icon: const Icon(Icons.add, size: 18, color: AppColors.primary),
            onPressed: locked
                ? null
                : () async {
                    final item = await Navigator.pushNamed(
                      context,
                      AppRouter.addItem,
                    );
                    if (item != null && context.mounted) {
                      context.read<StockRequestBloc>().add(
                        AddItemToRequest(item as StockItemModel),
                      );
                    }
                  },
          ),
          const SizedBox(height: 20),
          AppButton(
            text: locked ? 'Already submitted' : 'Submit Stock Request',
            icon: Icon(
              locked ? Icons.lock_outline : Icons.check,
              size: 20,
              color: Colors.white,
            ),
            onPressed: locked || state.selectedCount <= 0
                ? null
                : () {
                    context.read<StockRequestBloc>().add(
                      SubmitStockRequest(
                        sourceWarehouse: stop.sourceWarehouse ?? '',
                        targetWarehouse: stop.targetWarehouse ?? '',
                        customTask: stop.id,
                      ),
                    );
                  },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
