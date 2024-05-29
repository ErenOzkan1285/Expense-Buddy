import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'expense_creation_state.dart';

enum PaymentMethod { cash, creditCard, debitCard }

const Map<PaymentMethod, String> paymentMethodNames = {
  PaymentMethod.cash: 'Cash',
  PaymentMethod.creditCard: 'Credit Card',
  PaymentMethod.debitCard: 'Debit Card',
};

const Map<ExpenseCategory, String> expenseCategoryNames = {
  ExpenseCategory.general: 'General',
  ExpenseCategory.school: 'School',
  ExpenseCategory.health: 'Health',
  ExpenseCategory.grocery: 'Grocery',
  ExpenseCategory.clothing: 'Clothing',
  ExpenseCategory.entertainment: 'Entertainment',
  ExpenseCategory.other: 'Other',
};

enum ExpenseCategory {
  general,
  school,
  health,
  grocery,
  clothing,
  entertainment,
  other,
}

class ExpenseCreationCubit extends Cubit<ExpenseCreationState> {
  ExpenseCreationCubit()
      : super(const ExpenseCreationInitial(
            paymentMethod: PaymentMethod.cash,
            expenseCategory: ExpenseCategory.general,
            cardLastdigits: "0000"));

  void updateCost(double cost) {
    emit(state.copyWith(cost: cost));
  }

  void updateCategory(ExpenseCategory expenseCategory) {
    emit(state.copyWith(expenseCategory: expenseCategory));
  }

  void updateName(String name) {
    emit(state.copyWith(name: name));
  }

  void updatePaymentMethod(PaymentMethod method) {
    emit(state.copyWith(paymentMethod: method));
  }

  void updateCardLastDigits(String lastDigits) {
    emit(state.copyWith(cardLastdigits: lastDigits));
  }
}
