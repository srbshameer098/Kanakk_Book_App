import 'package:hive/hive.dart';

part 'transaction.g.dart';

@HiveType(typeId: 2)
class TransactionRecord extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String customerId;

  @HiveField(2)
  final String type; // 'credit' or 'payment'

  @HiveField(3)
  final int amount; // Stored in paise or lowest currency unit if needed, but let's store standard amount for simplicity, or we can use integer

  @HiveField(4)
  final String description;

  @HiveField(5)
  final String? paymentMethod; // 'cash', 'upi', 'bank', 'other'

  @HiveField(6)
  final DateTime transactionDate;

  @HiveField(7)
  final DateTime createdAt;

  @HiveField(8)
  final DateTime updatedAt;

  TransactionRecord({
    required this.id,
    required this.customerId,
    required this.type,
    required this.amount,
    required this.description,
    this.paymentMethod,
    required this.transactionDate,
    required this.createdAt,
    required this.updatedAt,
  });

  TransactionRecord copyWith({
    String? id,
    String? customerId,
    String? type,
    int? amount,
    String? description,
    String? paymentMethod,
    DateTime? transactionDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TransactionRecord(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      transactionDate: transactionDate ?? this.transactionDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
