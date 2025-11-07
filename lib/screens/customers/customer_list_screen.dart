import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../models/customer_model.dart';
import '../../providers/customer_provider.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/customer_card.dart';
import '../../widgets/search_bar.dart' as custom_search;
import '../../widgets/confirm_dialog.dart';
import '../../routes.dart';

class CustomerListScreen extends ConsumerStatefulWidget {
  const CustomerListScreen({super.key});

  @override
  ConsumerState<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends ConsumerState<CustomerListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

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

  Future<void> _deleteCustomer(Customer customer) async {
    final confirmed = await ConfirmDialog.show(
      context: context,
      title: 'Delete Customer',
      content:
          'Are you sure you want to delete ${customer.name}? This action cannot be undone.',
      confirmText: 'Delete',
      confirmColor: Colors.red,
    );

    if (confirmed == true) {
      try {
        await ref.read(customerProvider.notifier).deleteCustomer(customer.id!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Customer deleted successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting customer: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final customers = ref.watch(customerProvider);
    final filteredCustomers = _searchQuery.isEmpty
        ? customers
        : ref.read(customerProvider.notifier).searchCustomers(_searchQuery);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customers'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.pushNamed(context, Routes.addCustomer),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          custom_search.SearchBar(
                hintText: 'Search customers...',
                onChanged: _onSearchChanged,
                controller: _searchController,
              )
              .animate()
              .fadeIn(duration: 300.ms)
              .slideY(begin: -0.1, end: 0, duration: 300.ms),
          Expanded(
            child: filteredCustomers.isEmpty
                ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.people_outline,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isEmpty
                                  ? 'No customers yet'
                                  : 'No customers found',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 16),
                            if (_searchQuery.isEmpty)
                              ElevatedButton.icon(
                                onPressed: () => Navigator.pushNamed(
                                  context,
                                  Routes.addCustomer,
                                ),
                                icon: const Icon(Icons.person_add),
                                label: const Text('Add First Customer'),
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
                    itemCount: filteredCustomers.length,
                    itemBuilder: (context, index) {
                      final customer = filteredCustomers[index];
                      return CustomerCard(
                        customer: customer,
                        onTap: () => Navigator.pushNamed(
                          context,
                          Routes.customerDetail,
                          arguments: customer.id,
                        ),
                        onEdit: () {
                          // TODO: Implement edit customer
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Edit customer coming soon'),
                            ),
                          );
                        },
                        onDelete: () => _deleteCustomer(customer),
                        delay: index * 100,
                      );
                    },
                  ),
          ),
        ],
      ).animate().fadeIn(duration: 300.ms),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, Routes.addCustomer),
        child: const Icon(Icons.person_add),
      ),
    );
  }
}
