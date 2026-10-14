import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants.dart';
import '../models/expense.dart';
import '../providers/expense_provider.dart';
import '../utils/format.dart';
import '../widgets/empty_state.dart';
import '../widgets/expense_tile.dart';
import '../widgets/teal_header.dart';
import 'expense_form_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  int? _selectedId; // row currently showing edit / delete buttons

  Future<void> _confirmDelete(Expense e) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete transaction?'),
        content: Text('"${e.title}" (${money(e.amount)}) will be removed permanently.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete', style: TextStyle(color: kRed))),
        ],
      ),
    );
    if (ok != true || !mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    final err = await context.read<ExpenseProvider>().delete(e.id!);
    if (!mounted) return;
    setState(() => _selectedId = null);
    messenger.showSnackBar(SnackBar(content: Text(err ?? 'Expense deleted')));
  }

  void _edit(Expense e) {
    Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ExpenseFormScreen(expense: e)));
  }

  Widget _actionBtn(IconData icon, Color bg, Color fg, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          width: 38,
          height: 38,
          color: bg,
          child: Icon(icon, size: 15, color: fg),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ExpenseProvider>();

    Widget body;
    if (p.isLoading) {
      body = const Center(child: CircularProgressIndicator(color: kTeal));
    } else if (p.error != null) {
      body = Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(p.error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: kRed, fontSize: 12)),
              TextButton(
                  onPressed: p.load, child: const Text('Retry')),
            ],
          ),
        ),
      );
    } else if (p.expenses.isEmpty) {
      body = const EmptyState();
    } else {
      body = Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: kTeal.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Balance',
                    style: TextStyle(fontSize: 12, color: kGrey)),
                Text(money(p.balance),
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: kTeal)),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 0, 90),
              itemCount: p.expenses.length,
              itemBuilder: (_, i) {
                final e = p.expenses[i];
                final selected = _selectedId == e.id;
                return InkWell(
                  onTap: () =>
                      setState(() => _selectedId = selected ? null : e.id),
                  child: Padding(
                    padding: EdgeInsets.only(right: selected ? 0 : 16),
                    child: ExpenseTile(
                      expense: e,
                      trailingExtra: selected
                          ? Row(children: [
                        const SizedBox(width: 12),
                        _actionBtn(Icons.edit, const Color(0xFFEDEDED),
                            Colors.black87, () => _edit(e)),
                        _actionBtn(Icons.delete, kRed, Colors.white,
                                () => _confirmDelete(e)),
                      ])
                          : null,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      );
    }

    return Scaffold(
      appBar: const TealHeader(title: 'Transaction History'),
      body: body,
    );
  }
}