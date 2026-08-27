import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../customers/data/models/customer.dart';
import '../../../customers/presentation/pages/add_edit_customer_screen.dart';

class CustomerInfoTab extends StatelessWidget {
  final Customer customer;

  const CustomerInfoTab({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow(Icons.phone, 'Mobile Number', customer.mobileNumber ?? 'N/A'),
          const Divider(),
          _buildInfoRow(Icons.location_on, 'Address', customer.address ?? 'N/A'),
          const Divider(),
          _buildInfoRow(Icons.calendar_today, 'Added On', DateFormat('dd MMM yyyy').format(customer.createdAt)),
          const Divider(),
          _buildInfoRow(Icons.note, 'Notes', customer.notes ?? 'N/A'),
          
          const SizedBox(height: 32),
          Center(
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AddEditCustomerScreen(customer: customer)),
                );
              },
              icon: const Icon(Icons.edit),
              label: const Text('EDIT CUSTOMER'),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.grey),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.bodySmall),
                const SizedBox(height: 4),
                Text(value, style: AppTextStyles.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
