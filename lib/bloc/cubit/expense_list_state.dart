part of 'expense_list_cubit.dart';

@immutable
abstract class ExpenseListState {}

class ExpenseListInitial extends ExpenseListState {}

class ExpenseListLoaded extends ExpenseListState {
  final List<Expense> expenses;

  ExpenseListLoaded(this.expenses);
}

class ExpenseListError extends ExpenseListState {
  final String message;

  ExpenseListError(this.message);
}
