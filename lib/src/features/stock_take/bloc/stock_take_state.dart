import 'package:equatable/equatable.dart';
import '../../../core/models/stock_item_model.dart';

abstract class StockTakeState extends Equatable {
  const StockTakeState();
  @override
  List<Object?> get props => [];
}

class StockTakeInitial extends StockTakeState {}

class StockTakeLoading extends StockTakeState {}

class StockTakeLoaded extends StockTakeState {
  final List<StockItemModel> items;
  final int currentIndex;

  const StockTakeLoaded({
    required this.items,
    this.currentIndex = 0,
  });

  int get totalItems => items.length;
  int get auditedCount =>
      items.where((i) => i.actualQty > 0).length;
  int get discrepancyCount =>
      items.where((i) => i.actualQty > 0 && i.actualQty != i.systemQty).length;

  StockTakeLoaded copyWith({
    List<StockItemModel>? items,
    int? currentIndex,
  }) {
    return StockTakeLoaded(
      items: items ?? this.items,
      currentIndex: currentIndex ?? this.currentIndex,
    );
  }

  @override
  List<Object?> get props => [items, currentIndex];
}

class StockTakeSubmitting extends StockTakeState {}

class StockTakeSubmitted extends StockTakeState {}

class StockTakeError extends StockTakeState {
  final String message;
  const StockTakeError(this.message);

  @override
  List<Object?> get props => [message];
}
