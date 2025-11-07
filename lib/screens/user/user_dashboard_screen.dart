import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/customer_provider.dart';
import '../../providers/loan_provider.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/dashboard_card.dart';
import '../../routes.dart';

class UserDashboardScreen extends ConsumerWidget {
  const UserDashboardScreen({super.key});

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Dashboard'),
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
              'Welcome Back!',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Here\'s an overview of your loan management system',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            const Text(
              'Quick Stats',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                DashboardCard(
                  title: 'My Customers',
                  value: totalCustomers.toString(),
                  icon: Icons.people,
                  color: Colors.blue,
                  onTap: () =>
                      Navigator.pushNamed(context, Routes.customerList),
                ),
                DashboardCard(
                  title: 'Active Loans',
                  value: activeLoans.toString(),
                  icon: Icons.trending_up,
                  color: Colors.green,
                  onTap: () => Navigator.pushNamed(context, Routes.loanList),
                ),
                DashboardCard(
                  title: 'Total Loans',
                  value: totalLoans.toString(),
                  icon: Icons.account_balance_wallet,
                  color: Colors.orange,
                  onTap: () => Navigator.pushNamed(context, Routes.loanList),
                ),
                DashboardCard(
                  title: 'Completed',
                  value: completedLoans.toString(),
                  icon: Icons.check_circle,
                  color: Colors.purple,
                  onTap: () => Navigator.pushNamed(context, Routes.loanList),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Recent Activity',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Colors.blue,
                        child: Icon(Icons.people, color: Colors.white),
                      ),
                      title: const Text('Customer Management'),
                      subtitle: Text(
                        '$totalCustomers customers in your database',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () =>
                          Navigator.pushNamed(context, Routes.customerList),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Colors.green,
                        child: Icon(
                          Icons.account_balance_wallet,
                          color: Colors.white,
                        ),
                      ),
                      title: const Text('Loan Management'),
                      subtitle: Text('$totalLoans loans being managed'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () =>
                          Navigator.pushNamed(context, Routes.loanList),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Colors.orange,
                        child: Icon(Icons.payment, color: Colors.white),
                      ),
                      title: const Text('EMI Schedules'),
                      subtitle: const Text('View and manage EMI payments'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () =>
                          Navigator.pushNamed(context, Routes.emiSearch),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () =>
                        Navigator.pushNamed(context, Routes.addCustomer),
                    icon: const Icon(Icons.person_add),
                    label: const Text('Add Customer'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () =>
                        Navigator.pushNamed(context, Routes.createLoan),
                    icon: const Icon(Icons.add_card),
                    label: const Text('Create Loan'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
