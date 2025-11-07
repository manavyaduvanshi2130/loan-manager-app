import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/loan_model.dart';
import '../../models/payment_model.dart';
import '../../providers/loan_provider.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/emi_row.dart';
import '../../utils/helpers.dart';

class LoanHistoryScreen extends ConsumerStatefulWidget {
  final int loanId;

  const LoanHistoryScreen({super.key, required this.loanId});

  @override
  ConsumerState<LoanHistoryScreen> createState() => _LoanHistoryScreenState();
}

class _LoanHistoryScreenState extends ConsumerState<LoanHistoryScreen> {
  Loan? _loan;
  List<Map<String, dynamic>> _emiSchedule = [];
  List<Payment> _payments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLoanData();
  }

  Future<void> _loadLoanData() async {
    setState(() => _isLoading = true);

    try {
      final loan = ref.read(loanProvider.notifier).getLoanById(widget.loanId);
      if (loan != null) {
        setState(() {
          _loan = loan;
        });

        final emiSchedule = await ref
            .read(loanProvider.notifier)
            .getEMISchedule(widget.loanId);
        final payments = await ref
            .read(loanProvider.notifier)
            .getPaymentsByLoan(widget.loanId);

        setState(() {
          _emiSchedule = emiSchedule;
          _payments = payments;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading loan data: $e')));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Loan History')),
        drawer: const AppDrawer(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_loan == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Loan History')),
        drawer: const AppDrawer(),
        body: const Center(child: Text('Loan not found')),
      );
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Loan History'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'EMI Schedule'),
              Tab(text: 'Payment History'),
            ],
          ),
        ),
        drawer: const AppDrawer(),
        body: TabBarView(
          children: [
            // EMI Schedule Tab
            _buildEMIScheduleTab(),

            // Payment History Tab
            _buildPaymentHistoryTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildEMIScheduleTab() {
    if (_emiSchedule.isEmpty) {
      return const Center(child: Text('No EMI schedule available'));
    }

    return Column(
      children: [
        // Loan Summary Card
        Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Loan Summary',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Principal Amount:'),
                    Text(AppHelpers.formatCurrency(_loan!.principalAmount)),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Interest Rate:'),
                    Text(
                      '${AppHelpers.formatPercentage(_loan!.interestRate)} p.a.',
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Tenure:'),
                    Text('${_loan!.tenureMonths} months'),
                  ],
                ),
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
                            ),
                          );
                        }
                        return const Text('Calculating...');
                      },
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
            'emi': 'EMI',
            'principalPayment': 'Principal',
            'interestPayment': 'Interest',
            'remainingPrincipal': 'Balance',
          },
          isHeader: true,
        ),

        // EMI Schedule List
        Expanded(
          child: ListView.builder(
            itemCount: _emiSchedule.length,
            itemBuilder: (context, index) {
              final emi = _emiSchedule[index];
              return EMIRow(emiData: emi);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentHistoryTab() {
    if (_payments.isEmpty) {
      return const Center(child: Text('No payment history available'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _payments.length,
      itemBuilder: (context, index) {
        final payment = _payments[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.green[100],
              child: const Icon(Icons.payment, color: Colors.green),
            ),
            title: Text(AppHelpers.formatCurrency(payment.amount)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppHelpers.formatDate(payment.paymentDate)),
                if (payment.notes != null && payment.notes!.isNotEmpty)
                  Text(
                    payment.notes!,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
              ],
            ),
            trailing: Text(
              'ID: ${payment.id}',
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
          ),
        );
      },
    );
  }
}
