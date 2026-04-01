import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/models/stock_item_model.dart';
import 'stock_request_event.dart';
import 'stock_request_state.dart';

class StockRequestBloc extends Bloc<StockRequestEvent, StockRequestState> {
  StockRequestBloc() : super(StockRequestInitial()) {
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
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(milliseconds: 500));
      final items = _mockItems;
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
    emit(StockRequestSubmitting());
    try {
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(seconds: 1));
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

  static final _mockItems = [
    const StockItemModel(
      id: '1',
      name: 'Cricket Bat - English Willow',
      sku: 'CB-EW-042',
      availableQty: 45,
      systemQty: 45,
      requestedQty: 0,
      unit: 'pcs',
      reorderLevel: 20,
      dailyUsage: 8,
    ),
    const StockItemModel(
      id: '2',
      name: 'Football (Size 5 - Match)',
      sku: 'FB-S5-M-018',
      availableQty: 18,
      systemQty: 18,
      requestedQty: 0,
      unit: 'pcs',
      reorderLevel: 20,
      dailyUsage: 15,
    ),
    const StockItemModel(
      id: '3',
      name: 'Running Shoes - Size 8-10',
      sku: 'RS-8-10-007',
      availableQty: 0,
      systemQty: 0,
      requestedQty: 0,
      unit: 'pairs',
      reorderLevel: 10,
      dailyUsage: 6,
    ),
    const StockItemModel(
      id: '4',
      name: 'Tennis Racket Pro Series',
      sku: 'TR-PS-033',
      availableQty: 32,
      systemQty: 32,
      requestedQty: 0,
      unit: 'pcs',
      reorderLevel: 15,
      dailyUsage: 4,
    ),
  ];
}
