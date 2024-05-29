import 'package:bloc/bloc.dart';
import 'package:expensebuddy/database/app_database.dart';
import 'package:meta/meta.dart';
import '../../core/app_configuration/dependency_configuration.dart';
import '../../database/databaseModels/expenses_model.dart';
part 'expense_list_state.dart';

class ExpenseListCubit extends Cubit<ExpenseListState> {
  ExpenseListCubit() : super(ExpenseListInitial());

  void fetchExpensesForUser() async {
    try {
      final dbHelper = getIt<ExpensesDatabase>();
      final expenses = await dbHelper.readAllExpensesForUser(1);
      emit(ExpenseListLoaded(expenses));
    } catch (e) {
      emit(ExpenseListError('Failed to fetch expenses'));
    }
  }

  Future<void> deleteExpense(int id) async {
    try {
      final dbHelper = getIt<ExpensesDatabase>();
      await dbHelper.deleteExpense(1, id);
      fetchExpensesForUser(); // Fetch the updated list of expenses
    } catch (e) {
      emit(ExpenseListError('Failed to delete expense'));
    }
  }
}
