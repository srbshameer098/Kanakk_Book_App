import '../../data/models/customer.dart';
import '../../../../core/database/local_database_service.dart';

class CustomerRepository {
  final LocalDatabaseService _dbService;

  CustomerRepository({LocalDatabaseService? dbService})
      : _dbService = dbService ?? LocalDatabaseService();

  Future<void> addCustomer(Customer customer) async {
    await _dbService.addCustomer(customer);
  }

  Future<void> updateCustomer(Customer customer) async {
    await _dbService.updateCustomer(customer);
  }

  Future<void> deleteCustomer(String id) async {
    await _dbService.deleteCustomer(id);
  }

  List<Customer> getAllCustomers() {
    return _dbService.getAllCustomers();
  }

  Customer? getCustomerById(String id) {
    return _dbService.getCustomerById(id);
  }

  int getCustomerBalance(String customerId) {
    return _dbService.getCustomerBalance(customerId);
  }
}
