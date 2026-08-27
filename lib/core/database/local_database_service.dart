import 'package:hive_flutter/hive_flutter.dart';
import '../constants/database_constants.dart';
import '../../features/customers/data/models/customer.dart';
import '../../features/transactions/data/models/transaction.dart';
import '../../features/settings/data/models/shop.dart';

class LocalDatabaseService {
  static final LocalDatabaseService _instance = LocalDatabaseService._internal();
  factory LocalDatabaseService() => _instance;
  LocalDatabaseService._internal();

  Future<void> init() async {
    await Hive.initFlutter();

    // Register Adapters
    Hive.registerAdapter(CustomerAdapter());
    Hive.registerAdapter(TransactionRecordAdapter());
    Hive.registerAdapter(ShopAdapter());

    // Open Boxes
    await Hive.openBox<Customer>(DatabaseConstants.customerBox);
    await Hive.openBox<TransactionRecord>(DatabaseConstants.transactionBox);
    await Hive.openBox<Shop>(DatabaseConstants.shopBox);
  }

  // --- Customers ---
  Box<Customer> get _customerBox => Hive.box<Customer>(DatabaseConstants.customerBox);

  Future<void> addCustomer(Customer customer) async {
    await _customerBox.put(customer.id, customer);
  }

  Future<void> updateCustomer(Customer customer) async {
    await _customerBox.put(customer.id, customer);
  }

  Future<void> deleteCustomer(String id) async {
    await _customerBox.delete(id);
  }

  List<Customer> getAllCustomers() {
    return _customerBox.values.toList();
  }

  Customer? getCustomerById(String id) {
    return _customerBox.get(id);
  }

  // --- Transactions ---
  Box<TransactionRecord> get _transactionBox => Hive.box<TransactionRecord>(DatabaseConstants.transactionBox);

  Future<void> addTransaction(TransactionRecord transaction) async {
    await _transactionBox.put(transaction.id, transaction);
  }

  Future<void> updateTransaction(TransactionRecord transaction) async {
    await _transactionBox.put(transaction.id, transaction);
  }

  Future<void> deleteTransaction(String id) async {
    await _transactionBox.delete(id);
  }

  List<TransactionRecord> getAllTransactions() {
    return _transactionBox.values.toList();
  }

  List<TransactionRecord> getTransactionsForCustomer(String customerId) {
    return _transactionBox.values.where((t) => t.customerId == customerId).toList();
  }

  List<TransactionRecord> getTransactionsByDateRange(DateTime start, DateTime end) {
    return _transactionBox.values.where((t) {
      return t.transactionDate.isAfter(start.subtract(const Duration(days: 1))) && 
             t.transactionDate.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  int getCustomerBalance(String customerId) {
    final customer = getCustomerById(customerId);
    if (customer == null) return 0;
    
    int balance = customer.openingBalance;
    final transactions = getTransactionsForCustomer(customerId);
    
    for (var t in transactions) {
      if (t.type == 'credit') {
        balance += t.amount;
      } else {
        balance -= t.amount;
      }
    }
    return balance;
  }

  // --- Shop ---
  Box<Shop> get _shopBox => Hive.box<Shop>(DatabaseConstants.shopBox);

  Future<void> saveShop(Shop shop) async {
    await _shopBox.put('shop_info', shop);
  }

  Shop? getShop() {
    return _shopBox.get('shop_info');
  }

  bool get isShopSetupCompleted => _shopBox.containsKey('shop_info');
}
