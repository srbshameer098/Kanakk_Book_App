import 'package:hive/hive.dart';

part 'customer.g.dart';

@HiveType(typeId: 1)
class Customer extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String? mobileNumber;

  @HiveField(3)
  final String? address;

  @HiveField(4)
  final int openingBalance;

  @HiveField(5)
  final String? notes;

  @HiveField(6)
  final bool isArchived;

  @HiveField(7)
  final DateTime createdAt;

  @HiveField(8)
  final DateTime updatedAt;

  @HiveField(9, defaultValue: 0)
  final int currentBalance;

  Customer({
    required this.id,
    required this.name,
    this.mobileNumber,
    this.address,
    required this.openingBalance,
    this.notes,
    this.isArchived = false,
    required this.createdAt,
    required this.updatedAt,
    this.currentBalance = 0,
  });

  Customer copyWith({
    String? id,
    String? name,
    String? mobileNumber,
    String? address,
    int? openingBalance,
    String? notes,
    bool? isArchived,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? currentBalance,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      address: address ?? this.address,
      openingBalance: openingBalance ?? this.openingBalance,
      notes: notes ?? this.notes,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      currentBalance: currentBalance ?? this.currentBalance,
    );
  }
}
