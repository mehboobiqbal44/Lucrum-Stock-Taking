import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/stock_take_repository.dart';
import 'stock_take_event.dart';
import 'stock_take_state.dart';

class StockTakeBloc extends Bloc<StockTakeEvent, StockTakeState> {
  final StockTakeRepository _repository;

  StockTakeBloc({required StockTakeRepository repository})
      : _repository = repository,
        super(StockTakeInitial()) {
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
      final items =
          await _repository.getInventoryItems(event.targetWarehouse);
      emit(StockTakeLoaded(items: items));
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
    final current = state;
    if (current is! StockTakeLoaded) return;

    final counted = current.items.where((i) => i.actualQty > 0).toList();
    if (counted.isEmpty) return;

    emit(StockTakeSubmitting());
    try {
      await _repository.submitStockTake(
        sourceWarehouse: event.sourceWarehouse,
        customTask: event.customTask,
        items: counted,
      );
      emit(StockTakeSubmitted());
    } catch (e) {
      emit(StockTakeError(e.toString()));
    }
  }
}
