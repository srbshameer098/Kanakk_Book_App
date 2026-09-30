import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/services/premium_service.dart';
import '../../../../core/services/pdf_export_service.dart';
import '../../../../core/services/shop_settings_service.dart';
import '../../../customers/data/models/customer.dart';
import '../bloc/report_bloc.dart';
import '../bloc/report_event.dart';
import '../bloc/report_state.dart';
import '../../../settings/presentation/widgets/ad_banner_widget.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _selectedRange = 'Daily'; // 'Daily', 'Weekly', 'Monthly', 'Custom'
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _fetchReport();
  }

  void _fetchReport() {
    final now = DateTime.now();
    if (_selectedRange == 'Daily') {
      _startDate = DateTime(now.year, now.month, now.day);
      _endDate = _startDate;
    } else if (_selectedRange == 'Weekly') {
      _startDate = now.subtract(Duration(days: now.weekday - 1));
      _endDate = _startDate.add(const Duration(days: 6));
    } else if (_selectedRange == 'Monthly') {
      _startDate = DateTime(now.year, now.month, 1);
      _endDate = DateTime(now.year, now.month + 1, 0);
    }
    context.read<ReportBloc>().add(GenerateReportEvent(startDate: _startDate, endDate: _endDate));
  }

  Future<void> _selectCustomDateRange(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
    );

    if (picked != null) {
      setState(() {
        _selectedRange = 'Custom';
        _startDate = picked.start;
        _endDate = picked.end;
      });
      context.read<ReportBloc>().add(GenerateReportEvent(startDate: _startDate, endDate: _endDate));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('reports'.tr()),
        actions: [
          BlocBuilder<ReportBloc, ReportState>(
            builder: (context, state) {
              return IconButton(
                icon: const Icon(Icons.picture_as_pdf),
                onPressed: () async {
                  if (state is ReportLoaded) {
                    final isPremium = await PremiumService.isPremium();
                    if (!isPremium) {
                      if (context.mounted) {
                        PremiumService.showUpgradePrompt(
                          context,
                          feature: 'PDF Reports Export',
                        );
                      }
                      return;
                    }

                    try {
                      // We can reuse the same PDF service if we make it generic, 
                      // or just pass a dummy customer. 
                      // For now, let's just use the CustomerLedger method and pass a dummy customer "All Customers"
                      final dummyCustomer = Customer(
                        id: '0', 
                        name: 'All Customers', 
                        openingBalance: 0, 
                        createdAt: DateTime.now(), 
                        updatedAt: DateTime.now(),
                        currentBalance: state.totalCredit - state.totalPayment
                      );
                      final shopName = await ShopSettingsService.getShopName();
                      final pdfBytes = await PdfExportService.generateCustomerLedger(
                        shopName: shopName,
                        customer: dummyCustomer,
                        transactions: state.transactions,
                        startDate: state.startDate,
                        endDate: state.endDate,
                      );
                      await PdfExportService.printOrSharePdf(pdfBytes, 'report_${DateFormat('yyyyMMdd').format(state.startDate)}.pdf');
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                      }
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Generate a report first.')));
                  }
                },
              );
            },
          )
        ],
      ),
      body: Column(
        children: [
          _buildFilterRow(context),
          Expanded(
            child: BlocBuilder<ReportBloc, ReportState>(
              builder: (context, state) {
                if (state is ReportLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is ReportLoaded) {
                  return _buildReportContent(state);
                } else if (state is ReportError) {
                  return Center(child: Text('Error: ${state.message}'));
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          const AdBannerWidget(
            // TODO: Replace with your actual Ad Unit IDs for the Report Page
            androidAdUnitId: 'ca-app-pub-3269435850779402/8066534102', 
            iosAdUnitId: 'ca-app-pub-3269435850779402/2535987733',
          ),
        ],
      ),
    );
  }

  Widget _buildFilterRow(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.surface,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedRange,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Daily', child: Text('Daily Report')),
                    DropdownMenuItem(value: 'Weekly', child: Text('Weekly Report')),
                    DropdownMenuItem(value: 'Monthly', child: Text('Monthly Report')),
                    DropdownMenuItem(value: 'Custom', child: Text('Custom Range')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedRange = value;
                      });
                      if (value == 'Custom') {
                        _selectCustomDateRange(context);
                      } else {
                        _fetchReport();
                      }
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${DateFormat('dd MMM yyyy').format(_startDate)} - ${DateFormat('dd MMM yyyy').format(_endDate)}',
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildReportContent(ReportLoaded state) {
    final int netBalance = state.totalCredit - state.totalPayment;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSummaryCards(state),
        const SizedBox(height: 16),
        Card(
          color: AppColors.surface,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text('Net Period Balance', style: AppTextStyles.bodyMedium),
                const SizedBox(height: 8),
                Text(
                  '₹${netBalance.abs().toStringAsFixed(2)}',
                  style: AppTextStyles.amountLarge.copyWith(
                    color: netBalance > 0 ? AppColors.credit : (netBalance < 0 ? AppColors.payment : AppColors.textPrimary),
                  ),
                ),
                Text(
                  netBalance > 0 ? 'Credit given exceeds collection' : (netBalance < 0 ? 'Collection exceeds credit given' : 'Balanced'),
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Text('Transaction List', style: AppTextStyles.h3),
        const SizedBox(height: 8),
        if (state.transactions.isEmpty)
          const Padding(
            padding: EdgeInsets.all(32.0),
            child: Center(child: Text('No transactions in this period.')),
          )
        else
          ...state.transactions.map((tx) {
            final isCredit = tx.type == 'credit';
            final color = isCredit ? AppColors.credit : AppColors.payment;
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: color.withOpacity(0.1),
                  child: Icon(isCredit ? Icons.arrow_upward : Icons.arrow_downward, color: color),
                ),
                title: Text(tx.description.isNotEmpty ? tx.description : (isCredit ? 'Credit' : 'Payment')),
                subtitle: Text(DateFormat('dd MMM yyyy').format(tx.transactionDate)),
                trailing: Text('₹${tx.amount.toStringAsFixed(2)}', style: AppTextStyles.h3.copyWith(color: color)),
              ),
            );
          }).toList(),
      ],
    );
  }

  Widget _buildSummaryCards(ReportLoaded state) {
    return Row(
      children: [
        Expanded(
          child: Card(
            color: AppColors.credit.withOpacity(0.1),
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Total Credit', style: AppTextStyles.bodyMedium),
                  const SizedBox(height: 8),
                  Text('₹${state.totalCredit.toStringAsFixed(2)}', style: AppTextStyles.h3.copyWith(color: AppColors.credit)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Card(
            color: AppColors.payment.withOpacity(0.1),
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Total Collection', style: AppTextStyles.bodyMedium),
                  const SizedBox(height: 8),
                  Text('₹${state.totalPayment.toStringAsFixed(2)}', style: AppTextStyles.h3.copyWith(color: AppColors.payment)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
