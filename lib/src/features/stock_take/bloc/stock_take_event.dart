import 'package:equatable/equatable.dart';

abstract class StockTakeEvent extends Equatable {
  const StockTakeEvent();
  @override
  List<Object?> get props => [];
}

class LoadInventoryItems extends StockTakeEvent {
  final String stopId;
  const LoadInventoryItems(this.stopId);

  @override
  List<Object?> get props => [stopId];
}

class UpdateActualQty extends StockTakeEvent {
  final String itemId;
  final int quantity;

  const UpdateActualQty({required this.itemId, required this.quantity});

  @override
  List<Object?> get props => [itemId, quantity];
}

class SubmitStockTake extends StockTakeEvent {}
