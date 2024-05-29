part of 'expense_creation_cubit.dart';

@immutable
abstract class ExpenseCreationState {
  final PaymentMethod paymentMethod;
  final ExpenseCategory expenseCategory;
  final String cardLastdigits;

  const ExpenseCreationState({
    required this.paymentMethod,
    required this.expenseCategory,
    required this.cardLastdigits,
  });

  ExpenseCreationState copyWith({
    double? cost,
    ExpenseCategory? expenseCategory,
    String? name,
    String? cardLastdigits,
    PaymentMethod? paymentMethod,
  });
}

class ExpenseCreationInitial extends ExpenseCreationState {
  const ExpenseCreationInitial({
    required PaymentMethod paymentMethod,
    required ExpenseCategory expenseCategory,
    required String cardLastdigits,
  }) : super(
          paymentMethod: paymentMethod,
          expenseCategory: expenseCategory,
          cardLastdigits: cardLastdigits,
        );

  @override
  ExpenseCreationState copyWith({
    double? cost,
    ExpenseCategory? expenseCategory,
    String? name,
    String? cardLastdigits,
    PaymentMethod? paymentMethod,
  }) {
    return ExpenseCreationInitial(
      paymentMethod: paymentMethod ?? this.paymentMethod,
      expenseCategory: expenseCategory ?? this.expenseCategory,
      cardLastdigits: cardLastdigits ?? this.cardLastdigits,
    );
  }
}
