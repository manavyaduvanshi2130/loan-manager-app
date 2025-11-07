import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../widgets/dashboard_card.dart';
import '../../utils/helpers.dart';

class DashboardTiles extends StatelessWidget {
  final double totalPrincipal;
  final double totalOutstanding;

  const DashboardTiles({
    super.key,
    required this.totalPrincipal,
    required this.totalOutstanding,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        DashboardCard(
          title: 'Total Principal',
          value: AppHelpers.formatCurrency(totalPrincipal),
          icon: Icons.attach_money,
          color: Colors.teal,
          delay: 0,
        ),
        DashboardCard(
          title: 'Total Outstanding',
          value: AppHelpers.formatCurrency(totalOutstanding),
          icon: Icons.account_balance,
          color: Colors.red,
          delay: 100,
        ),
      ],
    ).animate(delay: 400.ms).fadeIn(duration: 300.ms);
  }
}
