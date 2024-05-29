import '../../database/databaseModels/expenses_model.dart';

extension ExpenseListExtensions on List<Expense> {
  Map<String, double> calculateCategoryTotalExpenses() {
    final categoryTotalExpenses = <String, double>{};

    for (var expense in this) {
      String categoryName = expense.category!.split('.').last;
      categoryName = categoryName[0].toUpperCase() + categoryName.substring(1);
      categoryTotalExpenses[categoryName] =
          (categoryTotalExpenses[categoryName] ?? 0) + expense.cost!;
    }

    return categoryTotalExpenses;
  }
}