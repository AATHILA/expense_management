import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../core/constants.dart';
import '../models/expense.dart';
import '../providers/expense_provider.dart';
import '../widgets/form_widgets.dart';
import '../widgets/primary_button.dart';
import '../widgets/teal_header.dart';

/// Add a new expense, or edit one when [expense] is provided.
class ExpenseFormScreen extends StatefulWidget {
  final Expense? expense;
  const ExpenseFormScreen({super.key, this.expense});

  @override
  State<ExpenseFormScreen> createState() => _ExpenseFormScreenState();
}

class _ExpenseFormScreenState extends State<ExpenseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _amount;
  late final TextEditingController _description;
  String? _category;
  DateTime? _date;
  bool _saving = false;

  bool get _editing => widget.expense != null;

  @override
  void initState() {
    super.initState();
    final e = widget.expense;
    _title = TextEditingController(text: e?.title);
    _amount = TextEditingController(text: e?.amount.toStringAsFixed(2));
    _description = TextEditingController(text: e?.description);
    // Old rows saved with another category are shown as 'Expense'.
    _category = kTransactionTypes.contains(e?.category) ? e!.category : 'Expense';
    _date = e?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _title.dispose();
    _amount.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final desc = _description.text.trim();
    final expense = Expense(
      id: widget.expense?.id,
      title: _title.text.trim(),
      amount: double.parse(_amount.text.trim()),
      category: _category!,
      date: _date!,
      description: desc.isEmpty ? null : desc,
    );

    final provider = context.read<ExpenseProvider>();
    final err =
    _editing ? await provider.update(expense) : await provider.add(expense);

    if (!mounted) return;
    setState(() => _saving = false);
    final messenger = ScaffoldMessenger.of(context);

    if (err != null) {
      messenger.showSnackBar(SnackBar(content: Text(err)));
      return;
    }
    Navigator.pop(context);
    messenger.showSnackBar(
        SnackBar(content: Text('$_category ${_editing ? 'updated' : 'added'}')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TealHeader(
          title: _editing ? 'Edit Transaction' : 'Transaction', showBack: true),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.all(16),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withValues(alpha: 0.07),
                          blurRadius: 14,
                          offset: const Offset(0, 4))
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const FieldLabel('Transaction type'),
                        DropdownField(
                          value: _category,
                          items: kTransactionTypes,
                          hint: 'Select type',
                          onChanged: (v) => setState(() => _category = v),
                          validator: (v) =>
                          v == null ? 'Please select a transaction type' : null,
                        ),
                        const FieldLabel('Name'),
                        TextFormField(
                          controller: _title,
                          textCapitalization: TextCapitalization.sentences,
                          maxLength: 50,
                          style: const TextStyle(fontSize: 13),
                          decoration: fieldDecoration(hint: 'e.g. Netflix')
                              .copyWith(counterText: ''),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Expense title is required'
                              : null,
                        ),
                        const FieldLabel('Amount'),
                        TextFormField(
                          controller: _amount,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*\.?\d{0,2}')),
                          ],
                          style: const TextStyle(fontSize: 13),
                          decoration: fieldDecoration(
                            focused: true,
                            hint: '₹ 0.00',
                            suffix: TextButton(
                              onPressed: _amount.clear,
                              child: const Text('Clear',
                                  style: TextStyle(fontSize: 10, color: kTeal)),
                            ),
                          ),
                          validator: (v) {
                            final text = v?.trim() ?? '';
                            if (text.isEmpty) return 'Amount is required';
                            final n = double.tryParse(text);
                            if (n == null || n <= 0) {
                              return 'Enter a valid amount greater than 0';
                            }
                            return null;
                          },
                        ),
                        const FieldLabel('Date'),
                        DateField(
                          value: _date,
                          onChanged: (d) => setState(() => _date = d),
                          validator: (v) =>
                          (v == null || v.isEmpty) ? 'Select a date' : null,
                        ),
                        const FieldLabel('Description (optional)'),
                        TextFormField(
                          controller: _description,
                          maxLines: 3,
                          maxLength: 200,
                          textCapitalization: TextCapitalization.sentences,
                          style: const TextStyle(fontSize: 13),
                          decoration: fieldDecoration(hint: 'Add a note'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: PrimaryButton(
                  label: 'Save', loading: _saving, onTap: _save),
            ),
          ],
        ),
      ),
    );
  }
}