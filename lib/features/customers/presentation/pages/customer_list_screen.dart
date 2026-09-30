import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../bloc/customer_bloc.dart';
import '../bloc/customer_event.dart';
import '../bloc/customer_state.dart';
import 'add_edit_customer_screen.dart';
import '../../../customer_details/presentation/pages/customer_details_screen.dart';
import '../../../settings/presentation/widgets/ad_banner_widget.dart';

class CustomerListScreen extends StatefulWidget {
  const CustomerListScreen({super.key});

  @override
  State<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<CustomerBloc>().add(LoadCustomersEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customers'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                context.read<CustomerBloc>().add(SearchCustomersEvent(value));
              },
              decoration: InputDecoration(
                hintText: 'Search customers...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    context.read<CustomerBloc>().add(const SearchCustomersEvent(''));
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<CustomerBloc, CustomerState>(
              builder: (context, state) {
                if (state is CustomerLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is CustomerLoaded) {
                  if (state.filteredCustomers.isEmpty) {
                    return _buildEmptyState();
                  }
                  return ListView.builder(
                    itemCount: state.filteredCustomers.length,
                    itemBuilder: (context, index) {
                      final customer = state.filteredCustomers[index];
                      final int currentBalance = customer.currentBalance; 
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: CircleAvatar(
                            backgroundColor: AppColors.primaryLight,
                            foregroundColor: AppColors.textInverse,
                            child: Text(customer.name.isNotEmpty ? customer.name[0].toUpperCase() : '?'),
                          ),
                          title: Text(customer.name, style: AppTextStyles.h3),
                          subtitle: Text(customer.mobileNumber ?? 'No Phone'),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '₹${currentBalance.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: currentBalance > 0 ? AppColors.credit : AppColors.payment,
                                ),
                              ),
                              Text(
                                currentBalance > 0 ? 'Due' : 'Cleared',
                                style: AppTextStyles.bodySmall,
                              )
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CustomerDetailsScreen(customer: customer),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                } else if (state is CustomerError) {
                  return Center(child: Text('Error: ${state.message}'));
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          const AdBannerWidget(
            androidAdUnitId: 'ca-app-pub-3269435850779402/4433024390',
            iosAdUnitId: 'ca-app-pub-3269435850779402/4433024390',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddEditCustomerScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.people_outline, size: 80, color: AppColors.textSecondary),
          const SizedBox(height: 16),
          const Text('No customers found', style: AppTextStyles.h3),
          const SizedBox(height: 8),
          const Text(
            'Add your first customer to start tracking credit.',
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
