import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../core/constants.dart';
import '../models/credit.dart';
import '../providers/credit_provider.dart';
import '../utils/format.dart';
import '../widgets/form_widgets.dart';
import '../widgets/primary_button.dart';
import '../widgets/teal_header.dart';

class CreditScreen extends StatefulWidget {
  const CreditScreen({super.key});
  @override
  State<CreditScreen> createState() => _CreditScreenState();
}

class _CreditScreenState extends State<CreditScreen> {
  static const _creditTypes = ['Subscriptions', 'Loan', 'Bills', 'Personal'];
  static const _planTypes = ['Monthly', 'One-Time', 'Yearly'];

  final _formKey = GlobalKey<FormState>();
  final _to = TextEditingController();
  final _amount = TextEditingController();
  String _creditType = _creditTypes.first;
  String _plan = _planTypes.first;
  DateTime _date = DateTime.now();
  bool _saving = false;

  @override
  void dispose() {
    _to.dispose();
    _amount.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final credit = Credit(
      creditType: _creditType,
      to: _to.text.trim(),
      date: _date,
      planType: _plan,
      amount: double.parse(_amount.text.trim()),
    );

    final messenger = ScaffoldMessenger.of(context);
    final err = await context.read<CreditProvider>().add(credit);
    if (!mounted) return;
    setState(() => _saving = false);

    if (err == null) {
      _formKey.currentState!.reset();
      _to.clear();
      _amount.clear();
      setState(() => _date = DateTime.now());
    }
    messenger.showSnackBar(SnackBar(content: Text(err ?? 'Credit saved')));
  }

  Future<void> _confirmDelete(Credit c) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete from saved list?'),
        content: Text('"${c.to}" (${money(c.amount)}) will be removed.'),
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
    final err = await context.read<CreditProvider>().delete(c.id!);
    messenger.showSnackBar(SnackBar(content: Text(err ?? 'Removed')));
  }

  bool _isDueOrOverdue(DateTime d) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return !DateTime(d.year, d.month, d.day).isAfter(today);
  }

  String _dueLabel(DateTime d) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(d.year, d.month, d.day);
    if (day == today) return 'Due Today';
    if (day.isBefore(today)) return 'Overdue ${DateFormat('dd/MM/yy').format(d)}';
    return 'Due On ${DateFormat('dd/MM/yy').format(d)}';
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<CreditProvider>();

    return Scaffold(
      appBar: const TealHeader(title: 'Credit'),
      body: ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
        children: [
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const FieldLabel('Credit type'),
                DropdownField(
                  value: _creditType,
                  items: _creditTypes,
                  onChanged: (v) => setState(() => _creditType = v),
                ),
                const FieldLabel('To'),
                TextFormField(
                  controller: _to,
                  textCapitalization: TextCapitalization.words,
                  style: const TextStyle(fontSize: 13),
                  decoration: fieldDecoration(hint: 'e.g. Netflix'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Name is required' : null,
                ),
                const FieldLabel('Amount'),
                TextFormField(
                  controller: _amount,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                  ],
                  style: const TextStyle(fontSize: 13),
                  decoration: fieldDecoration(hint: '₹ 0.00'),
                  validator: (v) {
                    final t = v?.trim() ?? '';
                    if (t.isEmpty) return 'Amount is required';
                    final n = double.tryParse(t);
                    if (n == null || n <= 0) {
                      return 'Enter a valid amount greater than 0';
                    }
                    return null;
                  },
                ),
                const FieldLabel('Date'),
                DateField(
                    value: _date, onChanged: (d) => setState(() => _date = d)),
                const FieldLabel('Plan type'),
                DropdownField(
                  value: _plan,
                  items: _planTypes,
                  onChanged: (v) => setState(() => _plan = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          PrimaryButton(label: 'Save', loading: _saving, onTap: _save),
          const SizedBox(height: 22),
          const Text('Your Saved Lists',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          if (p.isLoading)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator(color: kTeal)),
            )
          else if (p.error != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                children: [
                  Text(p.error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: kRed, fontSize: 12)),
                  TextButton(onPressed: p.load, child: const Text('Retry')),
                ],
              ),
            )
          else if (p.credits.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 28),
              child: Center(
                child: Text('Nothing saved yet.',
                    style: TextStyle(fontSize: 12, color: kGrey)),
              ),
            )
          else
            for (final c in p.credits)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: kBorder))),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(c.to,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 2),
                          Text(_dueLabel(c.date),
                              style: TextStyle(
                                  fontSize: 10,
                                  color: _isDueOrOverdue(c.date) ? kRed : kGrey)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(c.planType,
                            style: const TextStyle(fontSize: 10, color: kGrey)),
                        const SizedBox(height: 2),
                        Text(money(c.amount),
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(Icons.delete_outline,
                          size: 20, color: kGrey),
                      onPressed: () => _confirmDelete(c),
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}
