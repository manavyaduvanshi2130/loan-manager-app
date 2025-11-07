import 'package:flutter/material.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/customers/add_customer_screen.dart';
import 'screens/customers/customer_list_screen.dart';
import 'screens/customers/customer_detail_screen.dart';
import 'screens/loans/create_loan_screen.dart';
import 'screens/loans/edit_loan_screen.dart';
import 'screens/loans/loan_history_screen.dart';
import 'screens/loans/loan_list_screen.dart';
import 'screens/emi/emi_search_screen.dart';
import 'screens/emi/emi_schedule_screen.dart';
import 'screens/user/user_dashboard_screen.dart';
import 'screens/user/user_settings_screen.dart';
import 'screens/settings/app_settings_screen.dart';
import 'screens/analytics/analytics_screen.dart';

class Routes {
  static const String splash = '/';
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String customerList = '/customers';
  static const String addCustomer = '/customers/add';
  static const String customerDetail = '/customers/detail';
  static const String loanList = '/loans';
  static const String createLoan = '/loans/create';
  static const String editLoan = '/loans/edit';
  static const String loanHistory = '/loans/history';
  static const String emiSearch = '/emi/search';
  static const String emiSchedule = '/emi/schedule';
  static const String analytics = '/analytics';
  static const String settings = '/settings';
  static const String userDashboard = '/user/dashboard';
  static const String userSettings = '/user/settings';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      splash: (context) => const SplashScreen(),
      login: (context) => const LoginScreen(),
      dashboard: (context) => const DashboardScreen(),
      customerList: (context) => const CustomerListScreen(),
      addCustomer: (context) => const AddCustomerScreen(),
      customerDetail: (context) {
        final args =
            ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
        return CustomerDetailScreen(customerId: args?['customerId'] ?? 0);
      },
      loanList: (context) => const LoanListScreen(),
      createLoan: (context) => const CreateLoanScreen(),
      editLoan: (context) {
        final args =
            ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
        return EditLoanScreen(loanId: args?['loanId'] ?? 0);
      },
      loanHistory: (context) {
        final args =
            ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
        return LoanHistoryScreen(loanId: args?['loanId'] ?? 0);
      },
      emiSearch: (context) => const EMISearchScreen(),
      emiSchedule: (context) {
        final args =
            ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
        return EMIScheduleScreen(loanId: args?['loanId'] ?? 0);
      },
      analytics: (context) => const AnalyticsScreen(),
      userDashboard: (context) => const UserDashboardScreen(),
      userSettings: (context) => const UserSettingsScreen(),
      settings: (context) => const AppSettingsScreen(),
    };
  }
}
