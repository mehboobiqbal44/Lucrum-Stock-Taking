import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_text_styles.dart';
import '../../../components/app_button.dart';
import '../bloc/stock_take_bloc.dart';
import '../bloc/stock_take_event.dart';
import '../bloc/stock_take_state.dart';
import '../widgets/stock_take_item_card.dart';

class StockTakeScreen extends StatelessWidget {
  final String stopId;

  const StockTakeScreen({super.key, required this.stopId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => StockTakeBloc()..add(LoadInventoryItems(stopId)),
      child: const _StockTakeView(),
    );
  }
}

class _StockTakeView extends StatelessWidget {
  const _StockTakeView();

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
            Navigator.pop(context);
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
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (state is StockTakeSubmitting) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: AppColors.primary),
                  SizedBox(height: 16),
                  Text('Submitting...', style: AppTextStyles.caption),
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
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.items.length,
            itemBuilder: (context, index) {
              final item = state.items[index];
              return StockTakeItemCard(
                item: item,
                onActualQtyChanged: (qty) {
                  context.read<StockTakeBloc>().add(
                    UpdateActualQty(itemId: item.id, quantity: qty),
                  );
                },
              );
            },
          ),
        ),
        _buildBottomBar(context, state),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context, StockTakeLoaded state) {
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
            AppButton(
              text: 'Submit Item Count',
              icon: const Icon(Icons.check, size: 20, color: Colors.white),
              onPressed: state.auditedCount > 0
                  ? () {
                      context.read<StockTakeBloc>().add(SubmitStockTake());
                    }
                  : null,
            ),
            const SizedBox(height: 8),
            AppButton(
              text: 'Next Item',
              isSecondary: true,
              icon: const Icon(Icons.arrow_forward, size: 20, color: AppColors.textHigh),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
