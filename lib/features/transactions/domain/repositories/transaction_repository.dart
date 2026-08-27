import '../../data/models/transaction.dart';
import '../../../../core/database/local_database_service.dart';

class TransactionRepository {
  final LocalDatabaseService _dbService;

  TransactionRepository({LocalDatabaseService? dbService})
      : _dbService = dbService ?? LocalDatabaseService();

  Future<void> addTransaction(TransactionRecord transaction) async {
    await _dbService.addTransaction(transaction);
  }

  Future<void> updateTransaction(TransactionRecord transaction) async {
    await _dbService.updateTransaction(transaction);
  }

  Future<void> deleteTransaction(String id) async {
    await _dbService.deleteTransaction(id);
  }

  List<TransactionRecord> getAllTransactions() {
    return _dbService.getAllTransactions();
  }

  List<TransactionRecord> getTransactionsForCustomer(String customerId) {
    return _dbService.getTransactionsForCustomer(customerId);
  }

  List<TransactionRecord> getTransactionsByDateRange(DateTime start, DateTime end) {
    return _dbService.getTransactionsByDateRange(start, end);
  }
}
