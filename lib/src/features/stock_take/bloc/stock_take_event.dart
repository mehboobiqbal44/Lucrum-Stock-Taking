import 'package:equatable/equatable.dart';

abstract class StockTakeEvent extends Equatable {
  const StockTakeEvent();
  @override
  List<Object?> get props => [];
}

class LoadInventoryItems extends StockTakeEvent {
  final String targetWarehouse;
  const LoadInventoryItems(this.targetWarehouse);

  @override
  List<Object?> get props => [targetWarehouse];
}

class UpdateActualQty extends StockTakeEvent {
  final String itemId;
  final int quantity;

  const UpdateActualQty({required this.itemId, required this.quantity});

  @override
  List<Object?> get props => [itemId, quantity];
}

class SubmitStockTake extends StockTakeEvent {
  final String sourceWarehouse;
  final String customTask;

  const SubmitStockTake({
    required this.sourceWarehouse,
    required this.customTask,
  });

  @override
  List<Object?> get props => [sourceWarehouse, customTask];
}
