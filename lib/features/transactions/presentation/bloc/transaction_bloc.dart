import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../../../customers/domain/repositories/customer_repository.dart';
import 'transaction_event.dart';
import 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final TransactionRepository _repository;
  final CustomerRepository _customerRepository;

  TransactionBloc({
    required TransactionRepository repository,
    required CustomerRepository customerRepository,
  })
      : _repository = repository,
        _customerRepository = customerRepository,
        super(TransactionInitial()) {
    on<LoadCustomerTransactionsEvent>(_onLoadCustomerTransactions);
    on<AddTransactionEvent>(_onAddTransaction);
    on<UpdateTransactionEvent>(_onUpdateTransaction);
    on<DeleteTransactionEvent>(_onDeleteTransaction);
  }

  void _onLoadCustomerTransactions(LoadCustomerTransactionsEvent event, Emitter<TransactionState> emit) {
    emit(TransactionLoading());
    try {
      final transactions = _repository.getTransactionsForCustomer(event.customerId);
      // Sort by transactionDate descending
      transactions.sort((a, b) => b.transactionDate.compareTo(a.transactionDate));
      emit(CustomerTransactionsLoaded(transactions: transactions));
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }

  Future<void> _onAddTransaction(AddTransactionEvent event, Emitter<TransactionState> emit) async {
    try {
      await _repository.addTransaction(event.transaction);
      _updateCustomerBalance(event.transaction.customerId);
      add(LoadCustomerTransactionsEvent(event.transaction.customerId));
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }

  Future<void> _onUpdateTransaction(UpdateTransactionEvent event, Emitter<TransactionState> emit) async {
    try {
      await _repository.updateTransaction(event.transaction);
      _updateCustomerBalance(event.transaction.customerId);
      add(LoadCustomerTransactionsEvent(event.transaction.customerId));
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }

  Future<void> _onDeleteTransaction(DeleteTransactionEvent event, Emitter<TransactionState> emit) async {
    try {
      await _repository.deleteTransaction(event.transactionId);
      _updateCustomerBalance(event.customerId);
      add(LoadCustomerTransactionsEvent(event.customerId));
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }

  void _updateCustomerBalance(String customerId) {
    final customer = _customerRepository.getCustomerById(customerId);
    if (customer != null) {
      final newBalance = _customerRepository.getCustomerBalance(customerId);
      final updatedCustomer = customer.copyWith(currentBalance: newBalance);
      _customerRepository.updateCustomer(updatedCustomer);
    }
  }
}
