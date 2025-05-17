import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../../models/expense_item.dart';
import '../../providers/box_providers.dart';
import '../../providers/auth_provider.dart';

/// StateNotifier for managing expenses with Hive persistence.
class ExpenseListNotifier extends StateNotifier<List<ExpenseItem>> {
  final Box<ExpenseItem> _box;
  final String _ownerId;
  ExpenseListNotifier(this._box, this._ownerId)
      : super(_box.values.toList());

  /// Add a new expense for [date] with [amount] and [category].
  void add(double amount, String category, {required DateTime date}) {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final item = ExpenseItem(
      id: id,
      date: date,
      amount: amount,
      category: category,
    );
    _box.put(id, item);
    state = [...state, item];
  }

  /// Remove an expense by [id].
  void remove(String id) {
    _box.delete(id);
    state = state.where((e) => e.id != id).toList();
  }
}

/// Provider exposing the list of expenses.
final expenseListProvider =
    StateNotifierProvider<ExpenseListNotifier, List<ExpenseItem>>(
  (ref) {
    final box =   ref.watch(expensesBoxProvider);
    final ownerId = ref.watch(currentUserProvider).id;
    return ExpenseListNotifier(box, ownerId);
  }
);