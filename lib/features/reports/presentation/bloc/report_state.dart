import 'package:equatable/equatable.dart';
import '../../../transactions/data/models/transaction.dart';

abstract class ReportState extends Equatable {
  const ReportState();

  @override
  List<Object?> get props => [];
}

class ReportInitial extends ReportState {}

class ReportLoading extends ReportState {}

class ReportLoaded extends ReportState {
  final List<TransactionRecord> transactions;
  final int totalCredit;
  final int totalPayment;
  final DateTime startDate;
  final DateTime endDate;

  const ReportLoaded({
    required this.transactions,
    required this.totalCredit,
    required this.totalPayment,
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [transactions, totalCredit, totalPayment, startDate, endDate];
}

class ReportError extends ReportState {
  final String message;

  const ReportError(this.message);

  @override
  List<Object?> get props => [message];
}
