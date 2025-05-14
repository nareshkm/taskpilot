/// Represents an expense entry with amount and category.
class ExpenseItem {
  final String id;
  final DateTime date;
  final double amount;
  final String category;

  ExpenseItem({
    required this.id,
    required this.date,
    required this.amount,
    required this.category,
  });

  ExpenseItem copyWith({
    String? id,
    DateTime? date,
    double? amount,
    String? category,
  }) {
    return ExpenseItem(
      id: id ?? this.id,
      date: date ?? this.date,
      amount: amount ?? this.amount,
      category: category ?? this.category,
    );
  }
}