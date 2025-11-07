import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/analytics_service.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  final AnalyticsService _analyticsService = AnalyticsService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: FutureBuilder(
        future: _loadAnalyticsData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final data = snapshot.data as Map<String, dynamic>;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildAnalyticsCard(
                    'Total Customers',
                    data['totalCustomers'].toString(),
                    Icons.people,
                    Colors.blue,
                  ),
                  _buildAnalyticsCard(
                    'Active Loans',
                    data['totalActiveLoans'].toString(),
                    Icons.account_balance_wallet,
                    Colors.green,
                  ),
                  _buildAnalyticsCard(
                    'Total Loan Amount',
                    '\$${data['totalLoanAmount'].toStringAsFixed(2)}',
                    Icons.attach_money,
                    Colors.orange,
                  ),
                  _buildAnalyticsCard(
                    'Outstanding Amount',
                    '\$${data['totalOutstandingAmount'].toStringAsFixed(2)}',
                    Icons.money_off,
                    Colors.red,
                  ),
                  _buildAnalyticsCard(
                    'Payments Received',
                    '\$${data['totalPaymentsReceived'].toStringAsFixed(2)}',
                    Icons.payment,
                    Colors.purple,
                  ),
                  _buildAnalyticsCard(
                    'Default Rate',
                    '${data['defaultRate'].toStringAsFixed(2)}%',
                    Icons.warning,
                    Colors.redAccent,
                  ),
                ],
              ),
            );
          } else {
            return const Center(child: Text('No data available'));
          }
        },
      ),
    );
  }

  Future<Map<String, dynamic>> _loadAnalyticsData() async {
    final totalCustomers = await _analyticsService.getTotalCustomers();
    final totalActiveLoans = await _analyticsService.getTotalActiveLoans();
    final totalLoanAmount = await _analyticsService.getTotalLoanAmount();
    final totalOutstandingAmount = await _analyticsService
        .getTotalOutstandingAmount();
    final totalPaymentsReceived = await _analyticsService
        .getTotalPaymentsReceived();
    final defaultRisk = await _analyticsService.getDefaultRiskAnalysis();

    return {
      'totalCustomers': totalCustomers,
      'totalActiveLoans': totalActiveLoans,
      'totalLoanAmount': totalLoanAmount,
      'totalOutstandingAmount': totalOutstandingAmount,
      'totalPaymentsReceived': totalPaymentsReceived,
      'defaultRate': defaultRisk['defaultRate'],
    };
  }

  Widget _buildAnalyticsCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
