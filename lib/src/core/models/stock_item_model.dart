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

  /// Parse from get_material_transfer_items response item.
  /// {item_code, item_name, actual_qty}
  factory StockItemModel.fromTransferItem(Map<String, dynamic> json) {
    final code = json['item_code'] as String? ?? '';
    return StockItemModel(
      id: code,
      name: json['item_name'] as String? ?? '',
      sku: code,
      availableQty: (json['actual_qty'] as num?)?.toInt() ?? 0,
      systemQty: (json['actual_qty'] as num?)?.toInt() ?? 0,
    );
  }

  /// Parse from get_all_items response item.
  /// {item_code, item_name}
  factory StockItemModel.fromCatalogItem(Map<String, dynamic> json) {
    final code = json['item_code'] as String? ?? '';
    return StockItemModel(
      id: code,
      name: json['item_name'] as String? ?? '',
      sku: code,
    );
  }

  factory StockItemModel.fromJson(Map<String, dynamic> json) {
    return StockItemModel(
      id: json['id'] as String? ?? json['item_code'] as String? ?? '',
      name: json['name'] as String? ?? json['item_name'] as String? ?? '',
      sku: json['sku'] as String? ?? json['item_code'] as String? ?? '',
      availableQty: (json['available_qty'] as num?)?.toInt() ?? 0,
      systemQty: (json['system_qty'] as num?)?.toInt() ?? 0,
      requestedQty: (json['requested_qty'] as num?)?.toInt() ?? 0,
      actualQty: (json['actual_qty'] as num?)?.toInt() ?? 0,
      unit: json['unit'] as String? ?? 'pcs',
      reorderLevel: (json['reorder_level'] as num?)?.toInt(),
      dailyUsage: (json['daily_usage'] as num?)?.toInt(),
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
