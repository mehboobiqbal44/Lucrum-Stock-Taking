import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_text_styles.dart';
import '../../../core/routes/app_router.dart';
import '../../../core/models/stock_item_model.dart';
import '../../../components/app_button.dart';
import '../../../components/app_text_field.dart';
import '../bloc/stock_request_bloc.dart';
import '../bloc/stock_request_event.dart';
import '../bloc/stock_request_state.dart';
import '../widgets/stock_request_item_card.dart';
import '../widgets/request_summary_widget.dart';

class StockRequestScreen extends StatelessWidget {
  final String stopId;

  const StockRequestScreen({super.key, required this.stopId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => StockRequestBloc()..add(LoadWarehouseItems(stopId)),
      child: _StockRequestView(stopId: stopId),
    );
  }
}

class _StockRequestView extends StatelessWidget {
  final String stopId;

  const _StockRequestView({required this.stopId});

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
            Navigator.pop(context);
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
              child: CircularProgressIndicator(color: AppColors.primary),
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppTextField(
            hint: 'Search items...',
            prefixIcon: const Icon(
              Icons.search,
              size: 20,
              color: AppColors.textMedium,
            ),
            onChanged: (query) {
              context.read<StockRequestBloc>().add(SearchItems(query));
            },
          ),
          const SizedBox(height: 16),
          ...state.filteredItems.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: StockRequestItemCard(
                item: item,
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
            onPressed: () async {
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
          const SizedBox(height: 16),
          // RequestSummaryWidget(
          //   selectedCount: state.selectedCount,
          //   totalQty: state.totalQty,
          //   isUrgent: state.isUrgent,
          //   onToggleUrgent: () {
          //     context.read<StockRequestBloc>().add(ToggleUrgent());
          //   },
          // ),
          const SizedBox(height: 20),
          AppButton(
            text: 'Submit Stock Request',
            icon: const Icon(Icons.check, size: 20, color: Colors.white),
            onPressed: state.selectedCount > 0
                ? () {
                    context.read<StockRequestBloc>().add(SubmitStockRequest());
                  }
                : null,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
