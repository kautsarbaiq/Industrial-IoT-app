enum OrderStatus { queued, inProgress, completed, onHold }

extension OrderStatusX on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.queued:
        return 'Queued';
      case OrderStatus.inProgress:
        return 'In Progress';
      case OrderStatus.completed:
        return 'Completed';
      case OrderStatus.onHold:
        return 'On Hold';
    }
  }
}

/// A production / work order flowing through a line.
class ProductionOrder {
  final String id;
  final String orderNo;
  final String product;
  final String line;
  final int targetQty;
  final int producedQty;
  final int goodQty;
  final int rejectQty;
  final OrderStatus status;
  final DateTime startTime;
  final DateTime? dueTime;

  const ProductionOrder({
    required this.id,
    required this.orderNo,
    required this.product,
    required this.line,
    required this.targetQty,
    required this.producedQty,
    required this.goodQty,
    required this.rejectQty,
    required this.status,
    required this.startTime,
    this.dueTime,
  });

  double get progress => targetQty == 0 ? 0 : (producedQty / targetQty).clamp(0.0, 1.0);
  double get yieldPct => producedQty == 0 ? 0 : (goodQty / producedQty) * 100;

  factory ProductionOrder.fromJson(Map<String, dynamic> json) => ProductionOrder(
        id: json['id'] as String,
        orderNo: json['orderNo'] as String,
        product: json['product'] as String,
        line: json['line'] as String,
        targetQty: (json['targetQty'] as num).toInt(),
        producedQty: (json['producedQty'] as num).toInt(),
        goodQty: (json['goodQty'] as num).toInt(),
        rejectQty: (json['rejectQty'] as num).toInt(),
        status: OrderStatus.values.firstWhere(
          (s) => s.name == json['status'],
          orElse: () => OrderStatus.queued,
        ),
        startTime: DateTime.parse(json['startTime'] as String),
        dueTime: json['dueTime'] == null
            ? null
            : DateTime.parse(json['dueTime'] as String),
      );
}
