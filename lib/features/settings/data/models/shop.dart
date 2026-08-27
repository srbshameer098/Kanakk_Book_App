import 'package:hive/hive.dart';

part 'shop.g.dart';

@HiveType(typeId: 3)
class Shop extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String shopName;

  @HiveField(2)
  final String? ownerName;

  @HiveField(3)
  final String? mobileNumber;

  @HiveField(4)
  final String? category;

  @HiveField(5)
  final String? logoPath;

  @HiveField(6)
  final String language;

  @HiveField(7)
  final DateTime createdAt;

  Shop({
    required this.id,
    required this.shopName,
    this.ownerName,
    this.mobileNumber,
    this.category,
    this.logoPath,
    required this.language,
    required this.createdAt,
  });

  Shop copyWith({
    String? id,
    String? shopName,
    String? ownerName,
    String? mobileNumber,
    String? category,
    String? logoPath,
    String? language,
    DateTime? createdAt,
  }) {
    return Shop(
      id: id ?? this.id,
      shopName: shopName ?? this.shopName,
      ownerName: ownerName ?? this.ownerName,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      category: category ?? this.category,
      logoPath: logoPath ?? this.logoPath,
      language: language ?? this.language,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
