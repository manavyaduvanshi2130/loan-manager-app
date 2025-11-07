import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/customer_model.dart';
import '../../models/loan_model.dart';
import '../../providers/customer_provider.dart';
import '../../providers/loan_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/app_drawer.dart';
import '../../utils/helpers.dart';
import '../../services/loan_calculator.dart';

class CreateLoanScreen extends ConsumerStatefulWidget {
  const CreateLoanScreen({super.key});

  @override
  ConsumerState<CreateLoanScreen> createState() => _CreateLoanScreenState();
}

class _CreateLoanScreenState extends ConsumerState<CreateLoanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _principalController = TextEditingController();
  final _interestRateController = TextEditingController();
  final _tenureController = TextEditingController();

  Customer? _selectedCustomer;
  DateTime _startDate = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(settingsProvider);
    _interestRateController.text = settings.defaultTenureMonths.toString();
    _tenureController.text = settings.defaultTenureMonths.toString();
  }

  @override
  void dispose() {
    _principalController.dispose();
    _interestRateController.dispose();
    _tenureController.dispose();
    super.dispose();
  }

  Future<void> _selectCustomer() async {
    final customers = ref.read(customerProvider);
    if (customers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No customers available. Add a customer first.'),
        ),
      );
      return;
    }

    final selectedCustomer = await showDialog<Customer>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Customer'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: customers.length,
            itemBuilder: (context, index) {
              final customer = customers[index];
              return ListTile(
                leading: CircleAvatar(
                  child: Text(customer.name[0].toUpperCase()),
                ),
                title: Text(customer.name),
                subtitle: Text(customer.email),
                onTap: () => Navigator.of(context).pop(customer),
              );
            },
          ),
        ),
      ),
    );

    if (selectedCustomer != null) {
      setState(() {
        _selectedCustomer = selectedCustomer;
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

  Future<void> _saveLoan() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCustomer == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a customer')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final loan = Loan(
        customerId: _selectedCustomer!.id!,
        principalAmount: double.parse(_principalController.text),
        interestRate: double.parse(_interestRateController.text),
        tenureMonths: int.parse(_tenureController.text),
        startDate: _startDate,
      );

      await ref.read(loanProvider.notifier).addLoan(loan);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Loan created successfully')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error creating loan: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Loan')),
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

              // Customer Selection
              InkWell(
                onTap: _selectCustomer,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Customer *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  child: Text(
                    _selectedCustomer?.name ?? 'Select Customer',
                    style: TextStyle(
                      color: _selectedCustomer != null ? null : Colors.grey,
                    ),
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
              const SizedBox(height: 32),

              // EMI Preview
              if (_principalController.text.isNotEmpty &&
                  _interestRateController.text.isNotEmpty &&
                  _tenureController.text.isNotEmpty)
                Card(
                  color: Colors.blue[50],
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'EMI Preview',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Builder(
                          builder: (context) {
                            try {
                              final principal = double.parse(
                                _principalController.text,
                              );
                              final rate = double.parse(
                                _interestRateController.text,
                              );
                              final tenure = int.parse(_tenureController.text);
                              final emi = LoanCalculator.calculateEMI(
                                principal,
                                rate,
                                tenure,
                              );
                              return Text(
                                'Monthly EMI: ${AppHelpers.formatCurrency(emi)}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              );
                            } catch (e) {
                              return const Text(
                                'Invalid input for EMI calculation',
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveLoan,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Create Loan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
