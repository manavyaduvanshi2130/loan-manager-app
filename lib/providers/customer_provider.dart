import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/customer_model.dart';
import '../services/database_service.dart';

class CustomerNotifier extends Notifier<List<Customer>> {
  final DatabaseService _dbService = DatabaseService();

  @override
  List<Customer> build() {
    loadCustomers().catchError((error) {
      // Handle error silently or log it
      debugPrint('Error loading customers: $error');
    });
    return [];
  }

  Future<void> loadCustomers() async {
    final customers = await _dbService.getCustomers();
    state = customers;
  }

  Future<void> addCustomer(Customer customer) async {
    final id = await _dbService.insertCustomer(customer);
    final newCustomer = customer.copyWith(id: id);
    state = [...state, newCustomer];
  }

  Future<void> updateCustomer(Customer customer) async {
    await _dbService.updateCustomer(customer);
    state = state.map((c) => c.id == customer.id ? customer : c).toList();
  }

  Future<void> deleteCustomer(int id) async {
    await _dbService.deleteCustomer(id);
    state = state.where((c) => c.id != id).toList();
  }

  Customer? getCustomerById(int id) {
    return state.where((c) => c.id == id).firstOrNull;
  }

  List<Customer> searchCustomers(String query) {
    if (query.isEmpty) return state;
    return state
        .where(
          (customer) =>
              customer.name.toLowerCase().contains(query.toLowerCase()) ||
              customer.email.toLowerCase().contains(query.toLowerCase()) ||
              customer.phone.contains(query),
        )
        .toList();
  }
}

final customerProvider = NotifierProvider<CustomerNotifier, List<Customer>>(() {
  return CustomerNotifier();
});
