import 'package:equatable/equatable.dart';
import '../../../core/models/stock_item_model.dart';

abstract class StockRequestState extends Equatable {
  const StockRequestState();
  @override
  List<Object?> get props => [];
}

class StockRequestInitial extends StockRequestState {}

class StockRequestLoading extends StockRequestState {}

class StockRequestLoaded extends StockRequestState {
  final List<StockItemModel> items;
  final List<StockItemModel> filteredItems;
  final bool isUrgent;
  final String searchQuery;

  const StockRequestLoaded({
    required this.items,
    required this.filteredItems,
    this.isUrgent = false,
    this.searchQuery = '',
  });

  int get selectedCount => items.where((i) => i.requestedQty > 0).length;
  int get totalQty =>
      items.fold(0, (sum, i) => sum + i.requestedQty);

  StockRequestLoaded copyWith({
    List<StockItemModel>? items,
    List<StockItemModel>? filteredItems,
    bool? isUrgent,
    String? searchQuery,
  }) {
    return StockRequestLoaded(
      items: items ?? this.items,
      filteredItems: filteredItems ?? this.filteredItems,
      isUrgent: isUrgent ?? this.isUrgent,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [items, filteredItems, isUrgent, searchQuery];
}

class StockRequestSubmitting extends StockRequestState {}

class StockRequestSubmitted extends StockRequestState {}

class StockRequestError extends StockRequestState {
  final String message;
  const StockRequestError(this.message);

  @override
  List<Object?> get props => [message];
}
