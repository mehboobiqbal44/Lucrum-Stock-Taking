import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/models/stock_item_model.dart';
import 'stock_take_event.dart';
import 'stock_take_state.dart';

class StockTakeBloc extends Bloc<StockTakeEvent, StockTakeState> {
  StockTakeBloc() : super(StockTakeInitial()) {
    on<LoadInventoryItems>(_onLoadItems);
    on<UpdateActualQty>(_onUpdateQty);
    on<SubmitStockTake>(_onSubmit);
  }

  Future<void> _onLoadItems(
    LoadInventoryItems event,
    Emitter<StockTakeState> emit,
  ) async {
    emit(StockTakeLoading());
    try {
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(milliseconds: 500));
      emit(StockTakeLoaded(items: _mockItems));
    } catch (e) {
      emit(StockTakeError(e.toString()));
    }
  }

  void _onUpdateQty(
    UpdateActualQty event,
    Emitter<StockTakeState> emit,
  ) {
    final current = state;
    if (current is! StockTakeLoaded) return;

    final updated = current.items.map((item) {
      if (item.id == event.itemId) {
        return item.copyWith(actualQty: event.quantity);
      }
      return item;
    }).toList();

    emit(current.copyWith(items: updated));
  }

  Future<void> _onSubmit(
    SubmitStockTake event,
    Emitter<StockTakeState> emit,
  ) async {
    emit(StockTakeSubmitting());
    try {
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(seconds: 1));
      emit(StockTakeSubmitted());
    } catch (e) {
      emit(StockTakeError(e.toString()));
    }
  }

  static final _mockItems = [
    const StockItemModel(
      id: '1',
      name: 'Cricket Bat - English Willow',
      sku: 'CB-EW-042',
      availableQty: 45,
      systemQty: 45,
      actualQty: 0,
      unit: 'pcs',
    ),
    const StockItemModel(
      id: '2',
      name: 'Football (Size 5 - Match)',
      sku: 'FB-S5-M-018',
      availableQty: 45,
      systemQty: 45,
      actualQty: 0,
      unit: 'pcs',
    ),
    const StockItemModel(
      id: '3',
      name: 'Running Shoes - Size 8-10',
      sku: 'RS-8-10-007',
      availableQty: 30,
      systemQty: 30,
      actualQty: 0,
      unit: 'pairs',
    ),
    const StockItemModel(
      id: '4',
      name: 'Tennis Racket Pro Series',
      sku: 'TR-PS-033',
      availableQty: 32,
      systemQty: 32,
      actualQty: 0,
      unit: 'pcs',
    ),
    const StockItemModel(
      id: '5',
      name: 'Badminton Shuttlecocks',
      sku: 'BS-FTR-055',
      availableQty: 120,
      systemQty: 120,
      actualQty: 0,
      unit: 'pcs',
    ),
    const StockItemModel(
      id: '6',
      name: 'Gym Dumbbells 10kg',
      sku: 'GD-10K-066',
      availableQty: 20,
      systemQty: 20,
      actualQty: 0,
      unit: 'pairs',
    ),
  ];
}
