import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/models/customer.dart';
import '../bloc/customer_bloc.dart';
import '../bloc/customer_event.dart';
import '../bloc/customer_state.dart';
import '../../../../core/services/premium_service.dart';

class AddEditCustomerScreen extends StatefulWidget {
  final Customer? customer;

  const AddEditCustomerScreen({super.key, this.customer});

  @override
  State<AddEditCustomerScreen> createState() => _AddEditCustomerScreenState();
}

class _AddEditCustomerScreenState extends State<AddEditCustomerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _openingBalanceController = TextEditingController();
  final _notesController = TextEditingController();

  String _balanceType = 'due'; // 'due' or 'advance'

  @override
  void initState() {
    super.initState();
    if (widget.customer != null) {
      _nameController.text = widget.customer!.name;
      _phoneController.text = widget.customer!.mobileNumber ?? '';
      _addressController.text = widget.customer!.address ?? '';
      _notesController.text = widget.customer!.notes ?? '';
      
      int balance = widget.customer!.openingBalance;
      if (balance >= 0) {
        _openingBalanceController.text = balance.toString();
        _balanceType = 'due';
      } else {
        _openingBalanceController.text = (-balance).toString();
        _balanceType = 'advance';
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _openingBalanceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveCustomer() async {
    if (_formKey.currentState!.validate()) {
      // Check customer limit for free users
      if (widget.customer == null) {
        final isPremium = await PremiumService.isPremium();
        if (!isPremium) {
          final customerState = context.read<CustomerBloc>().state;
          if (customerState is CustomerLoaded) {
            if (customerState.customers.length >= 20) {
              if (mounted) {
                PremiumService.showUpgradePrompt(
                  context,
                  feature: 'Adding more than 20 customers',
                );
              }
              return; // Stop saving
            }
          }
        }
      }

      int balanceValue = int.tryParse(_openingBalanceController.text) ?? 0;
      int openingBalance = _balanceType == 'due' ? balanceValue : -balanceValue;

      final now = DateTime.now();

      final customer = Customer(
        id: widget.customer?.id ?? const Uuid().v4(),
        name: _nameController.text.trim(),
        mobileNumber: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        openingBalance: openingBalance,
        notes: _notesController.text.trim(),
        createdAt: widget.customer?.createdAt ?? now,
        updatedAt: now,
        isArchived: widget.customer?.isArchived ?? false,
        currentBalance: widget.customer == null ? openingBalance : widget.customer!.currentBalance,
      );

      if (widget.customer == null) {
        if (mounted) context.read<CustomerBloc>().add(AddCustomerEvent(customer));
      } else {
        if (mounted) context.read<CustomerBloc>().add(UpdateCustomerEvent(customer));
      }

      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.customer != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Customer' : 'Add Customer'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Customer Name *',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter customer name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Mobile Number',
                  prefixIcon: Icon(Icons.phone),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  prefixIcon: Icon(Icons.location_on),
                ),
              ),
              const SizedBox(height: 24),
              const Text('Opening Balance', style: AppTextStyles.h3),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _openingBalanceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Amount (₹)',
                        prefixIcon: Icon(Icons.currency_rupee),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 1,
                    child: DropdownButtonFormField<String>(
                      value: _balanceType,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'due', child: Text('Due')),
                        DropdownMenuItem(value: 'advance', child: Text('Advance')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _balanceType = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  prefixIcon: Icon(Icons.note),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveCustomer,
                child: Text(isEditing ? 'UPDATE CUSTOMER' : 'SAVE CUSTOMER'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
