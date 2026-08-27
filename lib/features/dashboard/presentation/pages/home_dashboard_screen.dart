import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:kada_kanakku/features/customer_details/presentation/pages/customer_details_screen.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/services/premium_service.dart';
import '../../../../core/services/shop_settings_service.dart';
import '../../../customers/presentation/bloc/customer_bloc.dart';
import '../../../customers/presentation/bloc/customer_event.dart';
import '../../../customers/presentation/bloc/customer_state.dart';
import '../../../settings/presentation/widgets/ad_banner_widget.dart';

class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  bool _isPremium = true;
  String _shopName = 'My Shop';

  @override
  void initState() {
    super.initState();
    context.read<CustomerBloc>().add(LoadCustomersEvent());
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final status = await PremiumService.isPremium();
    final name = await ShopSettingsService.getShopName();
    setState(() {
      _isPremium = status;
      _shopName = name;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('app_name'.tr()),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () {
              if (context.locale.languageCode == 'en') {
                context.setLocale(const Locale('ml'));
              } else {
                context.setLocale(const Locale('en'));
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<CustomerBloc, CustomerState>(
              builder: (context, state) {
                if (state is CustomerLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is CustomerLoaded) {
                  int totalOutstanding = 0;
                  for (var c in state.customers) {
                    if (c.currentBalance > 0) {
                      totalOutstanding += c.currentBalance;
                    }
                  }

                  final topDueCustomers =
                      state.customers
                          .where((c) => c.currentBalance > 0)
                          .toList()
                        ..sort(
                          (a, b) =>
                              b.currentBalance.compareTo(a.currentBalance),
                        );

                  final displayDueCustomers = topDueCustomers.take(5).toList();

                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<CustomerBloc>().add(LoadCustomersEvent());
                      _loadSettings();
                    },
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        _buildGreeting(),
                        const SizedBox(height: 16),
                        _buildSummaryCards(
                          totalOutstanding,
                          state.customers.length,
                        ),
                        const SizedBox(height: 24),
                        Text('top_due_customers'.tr(), style: AppTextStyles.h3),
                        const SizedBox(height: 8),
                        _buildTopDueList(displayDueCustomers),
                      ],
                    ),
                  );
                }
                return const Center(child: Text('Error loading dashboard'));
              },
            ),
          ),
          if (!_isPremium) const AdBannerWidget(),
        ],
      ),
    );
  }

  Widget _buildGreeting() {
    final date = DateFormat('EEEE, dd MMM yyyy').format(DateTime.now());
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Welcome, $_shopName', style: AppTextStyles.h2),
        const SizedBox(height: 4),
        Text(date, style: AppTextStyles.bodyMedium),
      ],
    );
  }

  Widget _buildSummaryCards(int totalOutstanding, int totalCustomers) {
    return Row(
      children: [
        Expanded(
          child: Card(
            color: AppColors.primary,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'total_outstanding'.tr(),
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textInverse,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '₹${totalOutstanding.toStringAsFixed(2)}',
                    style: AppTextStyles.h3.copyWith(
                      color: AppColors.textInverse,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Card(
            color: AppColors.surface,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('total_customers'.tr(), style: AppTextStyles.bodyMedium),
                  const SizedBox(height: 8),
                  Text('$totalCustomers', style: AppTextStyles.h3),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopDueList(List customers) {
    if (customers.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Center(child: Text('No customers with pending dues! 🎉')),
        ),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: customers.length,
      itemBuilder: (context, index) {
        final customer = customers[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.credit.withOpacity(0.1),
              child: const Icon(Icons.person, color: AppColors.credit),
            ),
            title: Text(customer.name, style: AppTextStyles.bodyLarge),
            subtitle: Text(customer.mobileNumber ?? 'No Phone'),
            trailing: Text(
              '₹${customer.currentBalance.toStringAsFixed(2)}',
              style: AppTextStyles.h3.copyWith(color: AppColors.credit),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      CustomerDetailsScreen(customer: customer),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
