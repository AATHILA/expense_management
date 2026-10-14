class Credit {
  final int? id;
  final String creditType;
  final String to;
  final DateTime date;
  final String planType;
  final double amount;

  const Credit({
    this.id,
    required this.creditType,
    required this.to,
    required this.date,
    required this.planType,
    required this.amount,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'credit_type': creditType,
        'to_name': to,
        'date': date.toIso8601String(),
        'plan_type': planType,
        'amount': amount,
      };

  factory Credit.fromMap(Map<String, dynamic> m) => Credit(
        id: m['id'] as int?,
        creditType: m['credit_type'] as String,
        to: m['to_name'] as String,
        date: DateTime.parse(m['date'] as String),
        planType: m['plan_type'] as String,
        amount: (m['amount'] as num).toDouble(),
      );
}
