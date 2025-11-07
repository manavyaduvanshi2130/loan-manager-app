import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/customer_provider.dart';
import '../../providers/loan_provider.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/dashboard_card.dart';
import '../../routes.dart';
import 'dashboard_tiles.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customers = ref.watch(customerProvider);
    final loans = ref.watch(loanProvider);

    final totalCustomers = customers.length;
    final totalLoans = loans.length;
    final activeLoans = loans
        .where((loan) => loan.status.name == 'active')
        .length;
    final completedLoans = loans
        .where((loan) => loan.status.name == 'completed')
        .length;

    final totalPrincipal = loans.fold<double>(
      0,
      (sum, loan) => sum + loan.principalAmount,
    );
    final totalOutstanding = loans.fold<double>(
      0,
      (sum, loan) => sum + (loan.outstandingAmount ?? 0),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(customerProvider);
              ref.invalidate(loanProvider);
            },
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Overview',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ).animate().fadeIn(duration: 300.ms),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                DashboardCard(
                  title: 'Total Customers',
                  value: totalCustomers.toString(),
                  icon: Icons.people,
                  color: Colors.blue,
                  onTap: () =>
                      Navigator.pushNamed(context, Routes.customerList),
                  delay: 0,
                ),
                DashboardCard(
                  title: 'Total Loans',
                  value: totalLoans.toString(),
                  icon: Icons.account_balance_wallet,
                  color: Colors.green,
                  onTap: () => Navigator.pushNamed(context, Routes.loanList),
                  delay: 100,
                ),
                DashboardCard(
                  title: 'Active Loans',
                  value: activeLoans.toString(),
                  icon: Icons.trending_up,
                  color: Colors.orange,
                  onTap: () => Navigator.pushNamed(context, Routes.loanList),
                  delay: 200,
                ),
                DashboardCard(
                  title: 'Completed Loans',
                  value: completedLoans.toString(),
                  icon: Icons.check_circle,
                  color: Colors.purple,
                  onTap: () => Navigator.pushNamed(context, Routes.loanList),
                  delay: 300,
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Financial Summary',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ).animate(delay: 400.ms).fadeIn(duration: 300.ms),
            const SizedBox(height: 16),
            DashboardTiles(
              totalPrincipal: totalPrincipal,
              totalOutstanding: totalOutstanding,
            ),
            const SizedBox(height: 24),
            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ).animate(delay: 500.ms).fadeIn(duration: 300.ms),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child:
                      ElevatedButton.icon(
                            onPressed: () => Navigator.pushNamed(
                              context,
                              Routes.addCustomer,
                            ),
                            icon: const Icon(Icons.person_add),
                            label: const Text('Add Customer'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          )
                          .animate(delay: 600.ms)
                          .fadeIn(duration: 300.ms)
                          .scale(
                            begin: const Offset(0.9, 0.9),
                            end: const Offset(1, 1),
                            duration: 300.ms,
                          ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child:
                      ElevatedButton.icon(
                            onPressed: () =>
                                Navigator.pushNamed(context, Routes.createLoan),
                            icon: const Icon(Icons.add_card),
                            label: const Text('Create Loan'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          )
                          .animate(delay: 700.ms)
                          .fadeIn(duration: 300.ms)
                          .scale(
                            begin: const Offset(0.9, 0.9),
                            end: const Offset(1, 1),
                            duration: 300.ms,
                          ),
                ),
              ],
            ),
          ],
        ),
      ).animate().fadeIn(duration: 300.ms),
    );
  }
}
