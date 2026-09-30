import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
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
      final jsonString = await generateBackupJson();
      final success = await _exportDataToInternalFile('kanakk_book_backup_$today.json', jsonString: jsonString);
      if (success) {
        await prefs.setString(_kLastBackupDate, today);
        debugPrint('Daily backup created successfully.');
      }
    } else {
      debugPrint('Backup already created today.');
    }
  }

  static Future<void> manualBackup(BuildContext context) async {
    await saveBackupToDevice(context);
  }

  /// Prompts user to select destination folder (e.g. Documents, Downloads) to save the JSON backup file
  static Future<void> saveBackupToDevice(BuildContext context, {String? fileName}) async {
    try {
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final name = fileName ?? 'kanakk_book_backup_$timestamp.json';
      final jsonString = await generateBackupJson();
      final bytes = Uint8List.fromList(utf8.encode(jsonString));

      // Also save an internal copy as safety net
      await _exportDataToInternalFile(name, jsonString: jsonString);

      // Opens system file picker so user can pick Documents, Downloads, or any folder
      final selectedPath = await FilePicker.saveFile(
        dialogTitle: 'Select folder to save backup',
        fileName: name,
        type: FileType.custom,
        allowedExtensions: ['json'],
        bytes: bytes,
      );

      if (context.mounted) {
        if (selectedPath != null) {
          final savedName = selectedPath.split('/').last.split('\\').last;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Backup saved successfully: $savedName'),
              backgroundColor: Colors.green[700],
              action: SnackBarAction(
                label: 'SHARE',
                textColor: Colors.white,
                onPressed: () => shareBackup(context, fileName: name),
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Backup save cancelled.')),
          );
        }
      }
    } catch (e) {
      debugPrint('saveBackupToDevice error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Opening share options to export backup...')),
        );
        await shareBackup(context, fileName: fileName);
      }
    }
  }

  /// Exports backup via system share sheet (Google Drive, WhatsApp, Email, Files)
  static Future<void> shareBackup(BuildContext context, {String? fileName}) async {
    try {
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final name = fileName ?? 'kanakk_book_backup_$timestamp.json';
      final jsonString = await generateBackupJson();

      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/$name');
      await file.writeAsString(jsonString);

      // Also save internal backup
      await _exportDataToInternalFile(name, jsonString: jsonString);

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: 'application/json')],
          subject: 'Kanakk Book Backup',
          text: 'Kanakk Book Backup ($name)',
        ),
      );
    } catch (e) {
      debugPrint('shareBackup error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to share backup: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  static Future<void> restoreBackup(BuildContext context) async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final pickedFile = result.files.single;
        String jsonString;

        if (pickedFile.bytes != null) {
          jsonString = utf8.decode(pickedFile.bytes!);
        } else if (pickedFile.path != null) {
          final file = File(pickedFile.path!);
          jsonString = await file.readAsString();
        } else {
          throw Exception('Unable to read selected file');
        }
        
        await _importDataFromJson(jsonString);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Data restored successfully! Please restart the app.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Restore error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error restoring backup: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  static Future<String> generateBackupJson() async {
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

    return const JsonEncoder.withIndent('  ').convert(backupData);
  }

  static Future<bool> _exportDataToInternalFile(String fileName, {String? jsonString}) async {
    try {
      final content = jsonString ?? await generateBackupJson();
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(content);
      return true;
    } catch (e) {
      debugPrint('Internal backup error: $e');
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
