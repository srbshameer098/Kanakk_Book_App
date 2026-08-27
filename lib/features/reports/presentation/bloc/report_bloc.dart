import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../transactions/domain/repositories/transaction_repository.dart';
import 'report_event.dart';
import 'report_state.dart';

class ReportBloc extends Bloc<ReportEvent, ReportState> {
  final TransactionRepository _repository;

  ReportBloc({required TransactionRepository repository})
      : _repository = repository,
        super(ReportInitial()) {
    on<GenerateReportEvent>(_onGenerateReport);
  }

  void _onGenerateReport(GenerateReportEvent event, Emitter<ReportState> emit) {
    emit(ReportLoading());
    try {
      final transactions = _repository.getTransactionsByDateRange(event.startDate, event.endDate);
      
      int totalCredit = 0;
      int totalPayment = 0;

      for (var tx in transactions) {
        if (tx.type == 'credit') {
          totalCredit += tx.amount;
        } else {
          totalPayment += tx.amount;
        }
      }

      // Sort descending by date
      transactions.sort((a, b) => b.transactionDate.compareTo(a.transactionDate));

      emit(ReportLoaded(
        transactions: transactions,
        totalCredit: totalCredit,
        totalPayment: totalPayment,
        startDate: event.startDate,
        endDate: event.endDate,
      ));
    } catch (e) {
      emit(ReportError(e.toString()));
    }
  }
}
