import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import '../../features/customers/data/models/customer.dart';
import '../../features/transactions/data/models/transaction.dart';
import '../../features/settings/data/models/shop.dart';
import '../database/local_database_service.dart';

class BackupRestoreService {
  static const String _kLastBackupDate = 'last_backup_date';

  static Future<void> createDailyBackup() async {
    final prefs = await SharedPreferences.getInstance();
    final lastBackup = prefs.getString(_kLastBackupDate);
    final today = DateFormat('yyyyMMdd').format(DateTime.now());

    if (lastBackup != today) {
      debugPrint('Creating daily backup for $today...');
      final success = await _exportDataToFile('kada_kanakku_backup_$today.json');
      if (success) {
        await prefs.setString(_kLastBackupDate, today);
        debugPrint('Daily backup created successfully.');
      }
    } else {
      debugPrint('Backup already created today.');
    }
  }

  static Future<void> manualBackup(BuildContext context) async {
    final today = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final success = await _exportDataToFile('kada_kanakku_manual_backup_$today.json');
    if (context.mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Backup created successfully in Documents folder.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to create backup.')),
        );
      }
    }
  }

  static Future<void> restoreBackup(BuildContext context) async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && result.files.single.path != null) {
        File file = File(result.files.single.path!);
        String jsonString = await file.readAsString();
        
        await _importDataFromJson(jsonString);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Data restored successfully! Please restart the app.')),
          );
        }
      }
    } catch (e) {
      debugPrint('Restore error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error restoring backup: $e')),
        );
      }
    }
  }

  static Future<bool> _exportDataToFile(String fileName) async {
    try {
      final db = LocalDatabaseService();
      final customers = db.getAllCustomers();
      final transactions = db.getAllTransactions();
      final shop = db.getShop();

      final backupData = {
        'version': 1,
        'timestamp': DateTime.now().toIso8601String(),
        'shop': shop != null ? _shopToJson(shop) : null,
        'customers': customers.map((c) => _customerToJson(c)).toList(),
        'transactions': transactions.map((t) => _transactionToJson(t)).toList(),
      };

      final jsonString = jsonEncode(backupData);
      
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(jsonString);
      
      return true;
    } catch (e) {
      debugPrint('Backup error: $e');
      return false;
    }
  }

  static Future<void> _importDataFromJson(String jsonString) async {
    final Map<String, dynamic> data = jsonDecode(jsonString);
    final db = LocalDatabaseService();

    // Import Shop
    if (data['shop'] != null) {
      await db.saveShop(_shopFromJson(data['shop']));
    }

    // Import Customers
    if (data['customers'] != null) {
      final List customersList = data['customers'];
      for (var c in customersList) {
        await db.updateCustomer(_customerFromJson(c));
      }
    }

    // Import Transactions
    if (data['transactions'] != null) {
      final List txList = data['transactions'];
      for (var t in txList) {
        await db.updateTransaction(_transactionFromJson(t));
      }
    }
  }

  // --- Serialization Helpers ---
  
  static Map<String, dynamic> _customerToJson(Customer c) => {
    'id': c.id,
    'name': c.name,
    'mobileNumber': c.mobileNumber,
    'address': c.address,
    'openingBalance': c.openingBalance,
    'notes': c.notes,
    'isArchived': c.isArchived,
    'createdAt': c.createdAt.toIso8601String(),
    'updatedAt': c.updatedAt.toIso8601String(),
    'currentBalance': c.currentBalance,
  };

  static Customer _customerFromJson(Map<String, dynamic> json) => Customer(
    id: json['id'],
    name: json['name'],
    mobileNumber: json['mobileNumber'],
    address: json['address'],
    openingBalance: json['openingBalance'],
    notes: json['notes'],
    isArchived: json['isArchived'] ?? false,
    createdAt: DateTime.parse(json['createdAt']),
    updatedAt: DateTime.parse(json['updatedAt']),
    currentBalance: json['currentBalance'] ?? 0,
  );

  static Map<String, dynamic> _transactionToJson(TransactionRecord t) => {
    'id': t.id,
    'customerId': t.customerId,
    'type': t.type,
    'amount': t.amount,
    'description': t.description,
    'paymentMethod': t.paymentMethod,
    'transactionDate': t.transactionDate.toIso8601String(),
    'createdAt': t.createdAt.toIso8601String(),
    'updatedAt': t.updatedAt.toIso8601String(),
  };

  static TransactionRecord _transactionFromJson(Map<String, dynamic> json) => TransactionRecord(
    id: json['id'],
    customerId: json['customerId'],
    type: json['type'],
    amount: json['amount'],
    description: json['description'],
    paymentMethod: json['paymentMethod'],
    transactionDate: DateTime.parse(json['transactionDate']),
    createdAt: DateTime.parse(json['createdAt']),
    updatedAt: DateTime.parse(json['updatedAt']),
  );

  static Map<String, dynamic> _shopToJson(Shop s) => {
    'id': s.id,
    'shopName': s.shopName,
    'ownerName': s.ownerName,
    'mobileNumber': s.mobileNumber,
    'category': s.category,
    'logoPath': s.logoPath,
    'language': s.language,
    'createdAt': s.createdAt.toIso8601String(),
  };

  static Shop _shopFromJson(Map<String, dynamic> json) => Shop(
    id: json['id'],
    shopName: json['shopName'],
    ownerName: json['ownerName'],
    mobileNumber: json['mobileNumber'],
    category: json['category'],
    logoPath: json['logoPath'],
    language: json['language'],
    createdAt: DateTime.parse(json['createdAt']),
  );
}
