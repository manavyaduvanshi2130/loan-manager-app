import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../models/loan_model.dart';
import '../../providers/loan_provider.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/loan_card.dart';
import '../../widgets/search_bar.dart' as custom_search;
import '../../widgets/payment_dialog.dart';
import '../../routes.dart';

class LoanListScreen extends ConsumerStatefulWidget {
  const LoanListScreen({super.key});

  @override
  ConsumerState<LoanListScreen> createState() => _LoanListScreenState();
}

class _LoanListScreenState extends ConsumerState<LoanListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _filterStatus = 'all'; // all, active, completed, defaulted

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  void _onFilterChanged(String? value) {
    setState(() {
      _filterStatus = value ?? 'all';
    });
  }

  List<Loan> _getFilteredLoans(List<Loan> loans) {
    var filtered = loans;

    // Filter by status
    if (_filterStatus != 'all') {
      filtered = filtered.where((loan) {
        switch (_filterStatus) {
          case 'active':
            return loan.status == LoanStatus.active;
          case 'completed':
            return loan.status == LoanStatus.completed;
          case 'defaulted':
            return loan.status == LoanStatus.defaulted;
          default:
            return true;
        }
      }).toList();
    }

    // Filter by search query (loan ID)
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((loan) {
        return loan.id.toString().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final loans = ref.watch(loanProvider);
    final filteredLoans = _getFilteredLoans(loans);

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Loans'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Filter by Status',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Column(
                        children: [
                          ListTile(
                            title: const Text('All Loans'),
                            leading: Radio<String>(
                              value: 'all',
                              groupValue: _filterStatus,
                              onChanged: _onFilterChanged,
                            ),
                          ),
                          ListTile(
                            title: const Text('Active'),
                            leading: Radio<String>(
                              value: 'active',
                              groupValue: _filterStatus,
                              onChanged: _onFilterChanged,
                            ),
                          ),
                          ListTile(
                            title: const Text('Completed'),
                            leading: Radio<String>(
                              value: 'completed',
                              groupValue: _filterStatus,
                              onChanged: _onFilterChanged,
                            ),
                          ),
                          ListTile(
                            title: const Text('Defaulted'),
                            leading: Radio<String>(
                              value: 'defaulted',
                              groupValue: _filterStatus,
                              onChanged: _onFilterChanged,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          custom_search.SearchBar(
                hintText: 'Search loans by ID...',
                onChanged: _onSearchChanged,
                controller: _searchController,
              )
              .animate()
              .fadeIn(duration: 300.ms)
              .slideY(begin: -0.1, end: 0, duration: 300.ms),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Showing ${filteredLoans.length} of ${loans.length} loans',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ).animate(delay: 100.ms).fadeIn(duration: 300.ms),
          Expanded(
            child: filteredLoans.isEmpty
                ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.account_balance_wallet_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isEmpty && _filterStatus == 'all'
                                  ? 'No loans yet'
                                  : 'No loans match your criteria',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                      .animate(delay: 200.ms)
                      .fadeIn(duration: 300.ms)
                      .scale(
                        begin: const Offset(0.9, 0.9),
                        end: const Offset(1, 1),
                        duration: 300.ms,
                      )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: filteredLoans.length,
                    itemBuilder: (context, index) {
                      final loan = filteredLoans[index];
                      return LoanCard(
                        loan: loan,
                        customerName:
                            'Customer ${loan.customerId}', // TODO: Get actual customer name
                        onTap: () => Navigator.pushNamed(
                          context,
                          Routes.loanHistory,
                          arguments: {'loanId': loan.id},
                        ),
                        onEdit: () => Navigator.pushNamed(
                          context,
                          Routes.editLoan,
                          arguments: {'loanId': loan.id},
                        ),
                        onMakePayment: () => PaymentDialog.show(context, loan),
                        delay: index * 100,
                      );
                    },
                  ),
          ),
        ],
      ).animate().fadeIn(duration: 300.ms),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, Routes.createLoan),
        child: const Icon(Icons.add),
      ),
    );
  }
}
