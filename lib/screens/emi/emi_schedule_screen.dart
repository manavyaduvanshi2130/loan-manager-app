import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/loan_model.dart';
import '../../models/customer_model.dart';
import '../../providers/loan_provider.dart';
import '../../providers/customer_provider.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/emi_row.dart';
import '../../utils/helpers.dart';

class EMIScheduleScreen extends ConsumerStatefulWidget {
  final int loanId;

  const EMIScheduleScreen({super.key, required this.loanId});

  @override
  ConsumerState<EMIScheduleScreen> createState() => _EMIScheduleScreenState();
}

class _EMIScheduleScreenState extends ConsumerState<EMIScheduleScreen> {
  Loan? _loan;
  Customer? _customer;
  List<Map<String, dynamic>> _emiSchedule = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEMISchedule();
  }

  Future<void> _loadEMISchedule() async {
    setState(() => _isLoading = true);

    try {
      final loan = ref.read(loanProvider.notifier).getLoanById(widget.loanId);
      if (loan != null) {
        setState(() {
          _loan = loan;
        });

        final customer = ref
            .read(customerProvider.notifier)
            .getCustomerById(loan.customerId);
        setState(() {
          _customer = customer;
        });

        final emiSchedule = await ref
            .read(loanProvider.notifier)
            .getEMISchedule(widget.loanId);
        setState(() {
          _emiSchedule = emiSchedule;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading EMI schedule: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('EMI Schedule')),
        drawer: const AppDrawer(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_loan == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('EMI Schedule')),
        drawer: const AppDrawer(),
        body: const Center(child: Text('Loan not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('EMI Schedule'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadEMISchedule,
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          // Loan Summary Card
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.blue[100],
                        child: Text(
                          _customer?.name[0].toUpperCase() ?? '?',
                          style: const TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _customer?.name ?? 'Unknown Customer',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Loan ID: ${_loan!.id}',
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
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Principal Amount:'),
                      Text(
                        AppHelpers.formatCurrency(_loan!.principalAmount),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Interest Rate:'),
                      Text(
                        '${AppHelpers.formatPercentage(_loan!.interestRate)} p.a.',
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Tenure:'),
                      Text('${_loan!.tenureMonths} months'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Start Date:'),
                      Text(AppHelpers.formatDate(_loan!.startDate)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Monthly EMI:'),
                      FutureBuilder<double>(
                        future: ref
                            .read(loanProvider.notifier)
                            .calculateEMI(_loan!.id!),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return Text(
                              AppHelpers.formatCurrency(snapshot.data!),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                                fontSize: 16,
                              ),
                            );
                          }
                          return const Text('Calculating...');
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Outstanding Amount:'),
                      Text(
                        AppHelpers.formatCurrency(
                          _loan!.outstandingAmount ?? 0,
                        ),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: (_loan!.outstandingAmount ?? 0) > 0
                              ? Colors.orange
                              : Colors.green,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // EMI Schedule Header
          const EMIRow(
            emiData: {
              'month': 'Month',
              'paymentDate': 'Payment Date',
              'emi': 'EMI Amount',
              'principalPayment': 'Principal',
              'interestPayment': 'Interest',
              'remainingPrincipal': 'Balance',
            },
            isHeader: true,
          ),

          // EMI Schedule List
          Expanded(
            child: _emiSchedule.isEmpty
                ? const Center(child: Text('No EMI schedule available'))
                : ListView.builder(
                    itemCount: _emiSchedule.length,
                    itemBuilder: (context, index) {
                      final emi = _emiSchedule[index];
                      final isPaid =
                          (emi['remainingPrincipal'] as double?) == 0;

                      return Container(
                        color: isPaid ? Colors.green[50] : null,
                        child: EMIRow(emiData: emi),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
