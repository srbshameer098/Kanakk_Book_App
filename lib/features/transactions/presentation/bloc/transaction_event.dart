import 'package:equatable/equatable.dart';
import '../../data/models/transaction.dart';

abstract class TransactionEvent extends Equatable {
  const TransactionEvent();

  @override
  List<Object?> get props => [];
}

class LoadCustomerTransactionsEvent extends TransactionEvent {
  final String customerId;

  const LoadCustomerTransactionsEvent(this.customerId);

  @override
  List<Object?> get props => [customerId];
}

class AddTransactionEvent extends TransactionEvent {
  final TransactionRecord transaction;

  const AddTransactionEvent(this.transaction);

  @override
  List<Object?> get props => [transaction];
}

class UpdateTransactionEvent extends TransactionEvent {
  final TransactionRecord transaction;

  const UpdateTransactionEvent(this.transaction);

  @override
  List<Object?> get props => [transaction];
}

class DeleteTransactionEvent extends TransactionEvent {
  final String transactionId;
  final String customerId; // Needed to reload the list

  const DeleteTransactionEvent(this.transactionId, this.customerId);

  @override
  List<Object?> get props => [transactionId, customerId];
}
