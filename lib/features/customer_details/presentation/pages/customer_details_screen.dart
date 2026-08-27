import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../customers/data/models/customer.dart';
import '../../../customers/presentation/bloc/customer_bloc.dart';
import '../../../customers/presentation/bloc/customer_state.dart';
import '../../../transactions/presentation/bloc/transaction_bloc.dart';
import '../../../transactions/presentation/bloc/transaction_state.dart';
import '../../../transactions/presentation/bloc/transaction_event.dart';
import '../../../transactions/presentation/pages/add_transaction_screen.dart';
import '../../../reminders/presentation/pages/whatsapp_reminder_screen.dart';
import '../../../../core/services/pdf_export_service.dart';
import '../../../../core/services/shop_settings_service.dart';
import '../widgets/transaction_list_tab.dart';
import '../widgets/customer_info_tab.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

class CustomerDetailsScreen extends StatefulWidget {
  final Customer customer;

  const CustomerDetailsScreen({super.key, required this.customer});

  @override
  State<CustomerDetailsScreen> createState() => _CustomerDetailsScreenState();
}

class _CustomerDetailsScreenState extends State<CustomerDetailsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Customer _currentCustomer;

  @override
  void initState() {
    super.initState();
    _currentCustomer = widget.customer;
    _tabController = TabController(length: 2, vsync: this);
    context.read<TransactionBloc>().add(LoadCustomerTransactionsEvent(_currentCustomer.id));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CustomerBloc, CustomerState>(
      listener: (context, state) {
        if (state is CustomerLoaded) {
          final updatedCustomer = state.customers.firstWhere(
            (c) => c.id == _currentCustomer.id,
            orElse: () => _currentCustomer,
          );
          setState(() {
            _currentCustomer = updatedCustomer;
          });
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_currentCustomer.name),
          actions: [
            IconButton(
              icon: const Icon(Icons.call),
              onPressed: () async {
                final phone = _currentCustomer.mobileNumber;
                if (phone != null && phone.isNotEmpty) {
                  final url = Uri.parse('tel:$phone');
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url);
                  } else {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not launch phone app')));
                    }
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No phone number available')));
                }
              },
            ),
            BlocBuilder<TransactionBloc, TransactionState>(
              builder: (context, state) {
                return IconButton(
                  icon: const Icon(Icons.picture_as_pdf),
                  onPressed: () async {
                    if (state is CustomerTransactionsLoaded) {
                      try {
                        final shopName = await ShopSettingsService.getShopName();
                        final pdfBytes = await PdfExportService.generateCustomerLedger(
                          shopName: shopName,
                          customer: _currentCustomer,
                          transactions: state.transactions,
                          startDate: DateTime(2000), // All time for now
                          endDate: DateTime.now(),
                        );
                        await PdfExportService.printOrSharePdf(pdfBytes, 'ledger_${_currentCustomer.name}.pdf');
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error generating PDF: $e')));
                        }
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please wait, loading transactions...')));
                    }
                  },
                );
              }
            ),
            IconButton(
              icon: const Icon(Icons.message),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => WhatsappReminderScreen(customer: _currentCustomer)),
                );
              },
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            labelColor: AppColors.textInverse,
            unselectedLabelColor: AppColors.textInverse.withOpacity(0.7),
            indicatorColor: AppColors.textInverse,
            tabs: const [
              Tab(text: 'TRANSACTIONS'),
              Tab(text: 'INFORMATION'),
            ],
          ),
        ),
        body: Column(
          children: [
            _buildBalanceCard(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  TransactionListTab(customer: _currentCustomer),
                  CustomerInfoTab(customer: _currentCustomer),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: _buildActionButtons(context),
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text('Current Due', style: AppTextStyles.bodyMedium),
            const SizedBox(height: 8),
            // We'll calculate the dynamic balance in the UI for now based on transactions, 
            // or use a pre-calculated field from the Customer object.
            // In Phase 4, the instruction says to calculate dynamically or maintain carefully.
            // Let's use the current Customer's opening balance as a starting point and wait for Bloc to supply transactions.
            // Since we might need the transaction state to calculate the real-time balance if not stored:
            BlocBuilder<TransactionBloc, TransactionState>(
              builder: (context, state) {
                int currentBalance = _currentCustomer.currentBalance;

                final isDue = currentBalance > 0;
                
                DateTime? lastTxDate;
                DateTime? lastPaymentDate;
                
                if (state is CustomerTransactionsLoaded && state.transactions.isNotEmpty) {
                  var sorted = List.of(state.transactions)..sort((a, b) => b.transactionDate.compareTo(a.transactionDate));
                  lastTxDate = sorted.first.transactionDate;
                  try {
                    lastPaymentDate = sorted.firstWhere((tx) => tx.type == 'payment').transactionDate;
                  } catch (_) {}
                }
                
                String lastTxString = lastTxDate != null ? DateFormat('dd MMM yyyy').format(lastTxDate) : 'N/A';
                String lastPaymentString = lastPaymentDate != null ? DateFormat('dd MMM yyyy').format(lastPaymentDate) : 'N/A';

                return Column(
                  children: [
                    Text(
                      '₹${currentBalance.abs().toStringAsFixed(2)}',
                      style: AppTextStyles.amountLarge.copyWith(
                        color: isDue ? AppColors.credit : AppColors.payment,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Last payment', style: AppTextStyles.bodySmall),
                            Text(lastPaymentString, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text('Last transaction', style: AppTextStyles.bodySmall),
                            Text(lastTxString, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    )
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, -4)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AddTransactionScreen(customer: _currentCustomer, transactionType: 'payment')),
                );
              },
              icon: const Icon(Icons.arrow_downward),
              label: const Text('PAYMENT'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.payment,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AddTransactionScreen(customer: _currentCustomer, transactionType: 'credit')),
                );
              },
              icon: const Icon(Icons.arrow_upward),
              label: const Text('CREDIT'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.credit,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
