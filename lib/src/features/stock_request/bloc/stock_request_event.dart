import 'package:equatable/equatable.dart';
import '../../../core/models/stock_item_model.dart';

abstract class StockRequestEvent extends Equatable {
  const StockRequestEvent();
  @override
  List<Object?> get props => [];
}

class LoadWarehouseItems extends StockRequestEvent {
  final String stopId;
  const LoadWarehouseItems(this.stopId);

  @override
  List<Object?> get props => [stopId];
}

class UpdateItemQty extends StockRequestEvent {
  final String itemId;
  final int quantity;

  const UpdateItemQty({required this.itemId, required this.quantity});

  @override
  List<Object?> get props => [itemId, quantity];
}

class AddItemToRequest extends StockRequestEvent {
  final StockItemModel item;
  const AddItemToRequest(this.item);

  @override
  List<Object?> get props => [item];
}

class ToggleUrgent extends StockRequestEvent {}

class SubmitStockRequest extends StockRequestEvent {}

class SearchItems extends StockRequestEvent {
  final String query;
  const SearchItems(this.query);

  @override
  List<Object?> get props => [query];
}
