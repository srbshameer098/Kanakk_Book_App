import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../customers/presentation/pages/customer_list_screen.dart';
import '../../../customers/presentation/pages/add_edit_customer_screen.dart';
import '../../../customers/presentation/pages/select_customer_screen.dart';
import '../../../transactions/presentation/pages/add_transaction_screen.dart';
import '../../../reports/presentation/pages/reports_screen.dart';
import '../../../settings/presentation/pages/settings_screen.dart';
import 'home_dashboard_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeDashboardScreen(),
    const CustomerListScreen(),
    const Center(child: Text('Add Transaction Quick Action')), // Placeholder
    const ReportsScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 2) {
            _showQuickAddOptions(context);
          } else {
            setState(() {
              _currentIndex = index;
            });
          }
        },
        items: [
          BottomNavigationBarItem(icon: const Icon(Icons.dashboard), label: 'home'.tr()),
          BottomNavigationBarItem(icon: const Icon(Icons.people), label: 'customers'.tr()),
          BottomNavigationBarItem(
            icon: const CircleAvatar(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textInverse,
              child: Icon(Icons.add),
            ),
            label: 'add'.tr(),
          ),
          BottomNavigationBarItem(icon: const Icon(Icons.bar_chart), label: 'reports'.tr()),
          BottomNavigationBarItem(icon: const Icon(Icons.settings), label: 'settings'.tr()),
        ],
      ),
    );
  }

  void _showQuickAddOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppColors.primaryLight,
                  child: Icon(Icons.person_add, color: AppColors.textInverse),
                ),
                title: Text('add_customer'.tr()),
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AddEditCustomerScreen()),
                  );
                },
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppColors.credit,
                  child: Icon(Icons.arrow_upward, color: AppColors.textInverse),
                ),
                title: Text('add_credit'.tr()),
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  _navigateToSelectCustomer(context, 'credit');
                },
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppColors.payment,
                  child: Icon(Icons.arrow_downward, color: AppColors.textInverse),
                ),
                title: Text('add_payment'.tr()),
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  _navigateToSelectCustomer(context, 'payment');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _navigateToSelectCustomer(BuildContext context, String initialType) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SelectCustomerScreen(
          onCustomerSelected: (customer) {
            // Pop the selection screen
            Navigator.pop(context);
            // Push the add transaction screen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AddTransactionScreen(
                  customer: customer,
                  transactionType: initialType,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
