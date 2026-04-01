import 'package:equatable/equatable.dart';

class StockItemModel extends Equatable {
  final String id;
  final String name;
  final String sku;
  final int availableQty;
  final int systemQty;
  final int requestedQty;
  final int actualQty;
  final String unit;
  final int? reorderLevel;
  final int? dailyUsage;

  const StockItemModel({
    required this.id,
    required this.name,
    required this.sku,
    this.availableQty = 0,
    this.systemQty = 0,
    this.requestedQty = 0,
    this.actualQty = 0,
    this.unit = 'pcs',
    this.reorderLevel,
    this.dailyUsage,
  });

  StockItemModel copyWith({
    int? requestedQty,
    int? actualQty,
  }) {
    return StockItemModel(
      id: id,
      name: name,
      sku: sku,
      availableQty: availableQty,
      systemQty: systemQty,
      requestedQty: requestedQty ?? this.requestedQty,
      actualQty: actualQty ?? this.actualQty,
      unit: unit,
      reorderLevel: reorderLevel,
      dailyUsage: dailyUsage,
    );
  }

  factory StockItemModel.fromJson(Map<String, dynamic> json) {
    return StockItemModel(
      id: json['id'] as String,
      name: json['name'] as String,
      sku: json['sku'] as String,
      availableQty: json['available_qty'] as int? ?? 0,
      systemQty: json['system_qty'] as int? ?? 0,
      requestedQty: json['requested_qty'] as int? ?? 0,
      actualQty: json['actual_qty'] as int? ?? 0,
      unit: json['unit'] as String? ?? 'pcs',
      reorderLevel: json['reorder_level'] as int?,
      dailyUsage: json['daily_usage'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'sku': sku,
    'available_qty': availableQty,
    'system_qty': systemQty,
    'requested_qty': requestedQty,
    'actual_qty': actualQty,
    'unit': unit,
    'reorder_level': reorderLevel,
    'daily_usage': dailyUsage,
  };

  String get stockStatus {
    if (availableQty == 0) return 'out_of_stock';
    if (reorderLevel != null && availableQty <= reorderLevel!) return 'low';
    return 'in_stock';
  }

  @override
  List<Object?> get props => [id, name, sku, requestedQty, actualQty];
}
