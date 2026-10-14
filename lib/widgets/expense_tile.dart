import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../models/expense.dart';
import '../utils/format.dart';

class ExpenseTile extends StatelessWidget {
  final Expense expense;
  final Widget? trailingExtra;
  const ExpenseTile({super.key, required this.expense, this.trailingExtra});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(expense.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(relativeDate(expense.date),
                    style: const TextStyle(fontSize: 10, color: kGrey)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text('${expense.isCredit ? '+' : '-'} ${money(expense.amount)}',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: expense.isCredit ? kGreen : kRed)),
          if (trailingExtra != null) trailingExtra!,
        ],
      ),
    );
  }
}