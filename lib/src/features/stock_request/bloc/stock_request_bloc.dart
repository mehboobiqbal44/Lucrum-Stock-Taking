import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/models/stock_item_model.dart';
import '../data/stock_request_repository.dart';
import 'stock_request_event.dart';
import 'stock_request_state.dart';

class StockRequestBloc extends Bloc<StockRequestEvent, StockRequestState> {
  final StockRequestRepository _repository;

  StockRequestBloc({required StockRequestRepository repository})
      : _repository = repository,
        super(StockRequestInitial()) {
    on<LoadWarehouseItems>(_onLoadItems);
    on<UpdateItemQty>(_onUpdateQty);
    on<AddItemToRequest>(_onAddItem);
    on<ToggleUrgent>(_onToggleUrgent);
    on<SubmitStockRequest>(_onSubmit);
    on<SearchItems>(_onSearch);
  }

  Future<void> _onLoadItems(
    LoadWarehouseItems event,
    Emitter<StockRequestState> emit,
  ) async {
    emit(StockRequestLoading());
    try {
      final items = await _repository.getWarehouseItems(event.targetWarehouse);
      emit(StockRequestLoaded(items: items, filteredItems: items));
    } catch (e) {
      emit(StockRequestError(e.toString()));
    }
  }

  void _onUpdateQty(
    UpdateItemQty event,
    Emitter<StockRequestState> emit,
  ) {
    final current = state;
    if (current is! StockRequestLoaded) return;

    final updated = current.items.map((item) {
      if (item.id == event.itemId) {
        return item.copyWith(requestedQty: event.quantity);
      }
      return item;
    }).toList();

    final filtered = _applySearch(updated, current.searchQuery);
    emit(current.copyWith(items: updated, filteredItems: filtered));
  }

  void _onAddItem(
    AddItemToRequest event,
    Emitter<StockRequestState> emit,
  ) {
    final current = state;
    if (current is! StockRequestLoaded) return;

    final exists = current.items.any((i) => i.id == event.item.id);
    if (exists) return;

    final updated = [...current.items, event.item.copyWith(requestedQty: 1)];
    final filtered = _applySearch(updated, current.searchQuery);
    emit(current.copyWith(items: updated, filteredItems: filtered));
  }

  void _onToggleUrgent(
    ToggleUrgent event,
    Emitter<StockRequestState> emit,
  ) {
    final current = state;
    if (current is! StockRequestLoaded) return;
    emit(current.copyWith(isUrgent: !current.isUrgent));
  }

  Future<void> _onSubmit(
    SubmitStockRequest event,
    Emitter<StockRequestState> emit,
  ) async {
    final current = state;
    if (current is! StockRequestLoaded) return;

    final itemsWithQty =
        current.items.where((i) => i.requestedQty > 0).toList();
    if (itemsWithQty.isEmpty) return;

    emit(StockRequestSubmitting());
    try {
      await _repository.submitRequest(
        sourceWarehouse: event.sourceWarehouse,
        targetWarehouse: event.targetWarehouse,
        customTask: event.customTask,
        items: itemsWithQty,
      );
      emit(StockRequestSubmitted());
    } catch (e) {
      emit(StockRequestError(e.toString()));
    }
  }

  void _onSearch(
    SearchItems event,
    Emitter<StockRequestState> emit,
  ) {
    final current = state;
    if (current is! StockRequestLoaded) return;

    final filtered = _applySearch(current.items, event.query);
    emit(current.copyWith(filteredItems: filtered, searchQuery: event.query));
  }

  List<StockItemModel> _applySearch(List<StockItemModel> items, String query) {
    if (query.isEmpty) return items;
    final lower = query.toLowerCase();
    return items
        .where((i) =>
            i.name.toLowerCase().contains(lower) ||
            i.sku.toLowerCase().contains(lower))
        .toList();
  }
}
