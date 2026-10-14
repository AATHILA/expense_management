import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants.dart';
import '../providers/expense_provider.dart';
import '../providers/profile_provider.dart';
import '../utils/format.dart';
import '../widgets/expense_tile.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback onSeeAll;
  const HomeScreen({super.key, required this.onSeeAll});

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning,';
    if (h < 17) return 'Good afternoon,';
    return 'Good evening,';
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ExpenseProvider>();
    final recent = p.expenses.take(3).toList();
    final name = context.watch<ProfileProvider>().profile.name;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ListView(
          padding: const EdgeInsets.only(bottom: 90),
          children: [
            const SizedBox(height: 12),
            Text(_greeting,
                style: const TextStyle(fontSize: 11, color: Colors.black87)),
            Text(name,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 14),
            _TotalCard(
                balance: p.balance,
                income: p.totalIncome,
                expense: p.totalExpense),
            const SizedBox(height: 22),
            Row(
              children: [
                _StatBox(label: 'SPENT TODAY', value: money(p.todayTotal)),
                const SizedBox(width: 12),
                _StatBox(label: 'SPENT THIS WEEK', value: money(p.weekTotal)),
              ],
            ),
            const SizedBox(height: 22),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Transactions History',
                    style:
                    TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                GestureDetector(
                  onTap: onSeeAll,
                  child: const Text('See all',
                      style: TextStyle(fontSize: 11, color: kGrey)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (p.isLoading)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator(color: kTeal)),
              )
            else if (p.error != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(p.error!,
                    style: const TextStyle(color: kRed, fontSize: 12)),
              )
            else if (recent.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 28),
                  child: Center(
                    child: Text('No expenses yet. Tap + to add one.',
                        style: TextStyle(fontSize: 12, color: kGrey)),
                  ),
                )
              else
                for (final e in recent) ExpenseTile(expense: e),
          ],
        ),
      ),
    );
  }
}

class _TotalCard extends StatelessWidget {
  final double balance, income, expense;
  const _TotalCard(
      {required this.balance, required this.income, required this.expense});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kTeal,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: kTeal.withValues(alpha: 0.35),
              blurRadius: 12,
              offset: const Offset(0, 6))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Total Balance',
              style: TextStyle(color: Colors.white, fontSize: 12)),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(money(balance),
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w700)),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _flow(Icons.arrow_downward, 'Income', money(income)),
              _flow(Icons.arrow_upward, 'Expenses', money(expense)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _flow(IconData icon, String label, String value) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(children: [
        CircleAvatar(
            radius: 8,
            backgroundColor: Colors.white24,
            child: Icon(icon, size: 10, color: Colors.white)),
        const SizedBox(width: 6),
        Text(label,
            style: const TextStyle(color: Colors.white, fontSize: 12)),
      ]),
      const SizedBox(height: 4),
      Text(value,
          style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600)),
    ],
  );
}

class _StatBox extends StatelessWidget {
  final String label, value;
  const _StatBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: kGrey)),
          const SizedBox(height: 8),
          Container(
            height: 58,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: kBorder),
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(value,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}