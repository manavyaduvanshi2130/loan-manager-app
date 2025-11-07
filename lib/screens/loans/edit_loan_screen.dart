import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/loan_model.dart';
import '../../models/customer_model.dart';
import '../../providers/loan_provider.dart';
import '../../providers/customer_provider.dart';
import '../../widgets/app_drawer.dart';
import '../../utils/helpers.dart';

class EditLoanScreen extends ConsumerStatefulWidget {
  final int loanId;

  const EditLoanScreen({super.key, required this.loanId});

  @override
  ConsumerState<EditLoanScreen> createState() => _EditLoanScreenState();
}

class _EditLoanScreenState extends ConsumerState<EditLoanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _principalController = TextEditingController();
  final _interestRateController = TextEditingController();
  final _tenureController = TextEditingController();

  Loan? _loan;
  Customer? _customer;
  DateTime _startDate = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadLoanData();
  }

  @override
  void dispose() {
    _principalController.dispose();
    _interestRateController.dispose();
    _tenureController.dispose();
    super.dispose();
  }

  void _loadLoanData() {
    final loan = ref.read(loanProvider.notifier).getLoanById(widget.loanId);
    if (loan != null) {
      setState(() {
        _loan = loan;
        _principalController.text = loan.principalAmount.toString();
        _interestRateController.text = loan.interestRate.toString();
        _tenureController.text = loan.tenureMonths.toString();
        _startDate = loan.startDate;
      });

      final customer = ref
          .read(customerProvider.notifier)
          .getCustomerById(loan.customerId);
      setState(() {
        _customer = customer;
      });
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  Future<void> _updateLoan() async {
    if (!_formKey.currentState!.validate()) return;
    if (_loan == null) return;

    setState(() => _isLoading = true);

    try {
      final updatedLoan = _loan!.copyWith(
        principalAmount: double.parse(_principalController.text),
        interestRate: double.parse(_interestRateController.text),
        tenureMonths: int.parse(_tenureController.text),
        startDate: _startDate,
      );

      await ref.read(loanProvider.notifier).updateLoan(updatedLoan);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Loan updated successfully')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error updating loan: $e')));
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loan == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit Loan')),
        drawer: const AppDrawer(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Loan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Loan'),
                  content: const Text(
                    'Are you sure you want to delete this loan? This action cannot be undone.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );

              if (confirmed == true) {
                try {
                  await ref.read(loanProvider.notifier).deleteLoan(_loan!.id!);
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Loan deleted successfully')),
                  );
                  Navigator.of(context).pop();
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error deleting loan: $e')),
                  );
                }
              }
            },
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Loan Information',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Customer Info (Read-only)
              Card(
                color: Colors.grey[100],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        child: Text(_customer?.name[0].toUpperCase() ?? '?'),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _customer?.name ?? 'Unknown Customer',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              _customer?.email ?? '',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Principal Amount
              TextFormField(
                controller: _principalController,
                decoration: const InputDecoration(
                  labelText: 'Principal Amount *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                  suffixText: 'INR',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter principal amount';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Please enter a valid amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Interest Rate
              TextFormField(
                controller: _interestRateController,
                decoration: const InputDecoration(
                  labelText: 'Annual Interest Rate (%) *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.percent),
                  suffixText: '%',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter interest rate';
                  }
                  final rate = double.tryParse(value);
                  if (rate == null || rate < 0 || rate > 100) {
                    return 'Please enter a valid interest rate (0-100%)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Tenure
              TextFormField(
                controller: _tenureController,
                decoration: const InputDecoration(
                  labelText: 'Tenure (Months) *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                  suffixText: 'months',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter tenure';
                  }
                  final tenure = int.tryParse(value);
                  if (tenure == null || tenure <= 0) {
                    return 'Please enter a valid tenure';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Start Date
              InkWell(
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Start Date *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.date_range),
                  ),
                  child: Text(AppHelpers.formatDate(_startDate)),
                ),
              ),
              const SizedBox(height: 16),

              // Status
              InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.info),
                ),
                child: Text(
                  _loan!.status.name.toUpperCase(),
                  style: TextStyle(
                    color: _loan!.status == LoanStatus.active
                        ? Colors.green
                        : _loan!.status == LoanStatus.completed
                        ? Colors.blue
                        : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _updateLoan,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Update Loan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
