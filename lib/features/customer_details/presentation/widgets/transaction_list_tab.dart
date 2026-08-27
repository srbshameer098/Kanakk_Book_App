import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../customers/data/models/customer.dart';
import '../../../transactions/presentation/bloc/transaction_bloc.dart';
import '../../../transactions/presentation/bloc/transaction_state.dart';

class TransactionListTab extends StatelessWidget {
  final Customer customer;

  const TransactionListTab({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionBloc, TransactionState>(
      builder: (context, state) {
        if (state is TransactionLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is CustomerTransactionsLoaded) {
          if (state.transactions.isEmpty) {
            return const Center(child: Text('No transactions found.'));
          }
          
          return ListView.builder(
            itemCount: state.transactions.length,
            itemBuilder: (context, index) {
              final tx = state.transactions[index];
              final isCredit = tx.type == 'credit';
              final color = isCredit ? AppColors.credit : AppColors.payment;
              
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: color.withOpacity(0.1),
                  child: Icon(
                    isCredit ? Icons.arrow_upward : Icons.arrow_downward,
                    color: color,
                  ),
                ),
                title: Text(tx.description.isNotEmpty ? tx.description : (isCredit ? 'Credit' : 'Payment')),
                subtitle: Text(DateFormat('dd MMM yyyy').format(tx.transactionDate)),
                trailing: Text(
                  '₹${tx.amount.toStringAsFixed(2)}',
                  style: AppTextStyles.h3.copyWith(color: color),
                ),
              );
            },
          );
        } else if (state is TransactionError) {
          return Center(child: Text('Error: ${state.message}'));
        }
        return const SizedBox.shrink();
      },
    );
  }
}
