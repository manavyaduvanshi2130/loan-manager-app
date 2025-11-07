import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/loan_model.dart';
import '../../providers/loan_provider.dart';
import '../../providers/customer_provider.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/search_bar.dart' as custom_search;
import '../../routes.dart';

class EMISearchScreen extends ConsumerStatefulWidget {
  const EMISearchScreen({super.key});

  @override
  ConsumerState<EMISearchScreen> createState() => _EMISearchScreenState();
}

class _EMISearchScreenState extends ConsumerState<EMISearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<Loan> _filteredLoans = [];

  @override
  void initState() {
    super.initState();
    _loadLoans();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadLoans() {
    final loans = ref.read(loanProvider);
    setState(() {
      _filteredLoans = loans
          .where((loan) => loan.status == LoanStatus.active)
          .toList();
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  List<Loan> get _searchResults {
    if (_searchQuery.isEmpty) return _filteredLoans;

    return _filteredLoans.where((loan) {
      final customer = ref
          .read(customerProvider.notifier)
          .getCustomerById(loan.customerId);
      final customerName = customer?.name.toLowerCase() ?? '';
      final customerEmail = customer?.email.toLowerCase() ?? '';
      final loanId = loan.id.toString();

      return customerName.contains(_searchQuery.toLowerCase()) ||
          customerEmail.contains(_searchQuery.toLowerCase()) ||
          loanId.contains(_searchQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('EMI Search')),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          custom_search.SearchBar(
            hintText: 'Search by customer name, email, or loan ID...',
            onChanged: _onSearchChanged,
            controller: _searchController,
          ),
          Expanded(
            child: _searchResults.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty
                              ? 'Search for active loans to view EMI schedules'
                              : 'No loans found matching your search',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final loan = _searchResults[index];
                      final customer = ref
                          .read(customerProvider.notifier)
                          .getCustomerById(loan.customerId);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue[100],
                            child: Text(
                              customer?.name[0].toUpperCase() ?? '?',
                              style: const TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(customer?.name ?? 'Unknown Customer'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Loan ID: ${loan.id}'),
                              Text(
                                'Principal: ₹${loan.principalAmount.toStringAsFixed(2)}',
                              ),
                              Text(
                                '${loan.interestRate}% p.a. for ${loan.tenureMonths} months',
                              ),
                            ],
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => Navigator.pushNamed(
                            context,
                            Routes.emiSchedule,
                            arguments: loan.id,
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
