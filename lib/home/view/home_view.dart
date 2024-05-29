import 'package:expensebuddy/bloc/cubit/expense_list_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expensebuddy/bloc/cubit/expense_creation_cubit.dart';
import 'package:expensebuddy/core/app_configuration/dependency_configuration.dart';
import 'package:expensebuddy/database/app_database.dart';
import 'package:expensebuddy/database/databaseModels/expenses_model.dart';
import 'package:intl/intl.dart';
import '../../bloc/cubit/navigation_cubit.dart';
import '../../chart/view/chart_view.dart';
import '../../core/constants/functions.dart';
import '../../core/constants/widgets/textField_container.dart';
import '../../database/databaseModels/user_model.dart';
import '../../profile/view/profile_view.dart';
import '../../wallet/view/wallet_view.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ExpenseListCubit()..fetchExpensesForUser(),
        ),
        BlocProvider(
          create: (context) => NavigationCubit(),
          child: MaterialApp(
            title: 'Expense Buddy',
            theme: ThemeData(
              primarySwatch: Colors.teal,
            ),
          ),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Center(child: Text('Expense Buddy')),
          backgroundColor: const Color(0xff368983),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: const Color(0xff368983),
          foregroundColor: Colors.white,
          splashColor: Colors.white,
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return const MyExpenseDialog();
              },
            );
          },
          child: const Icon(Icons.add),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: const BottomNavBar(),
        backgroundColor: Colors.teal[100],
        body: BlocBuilder<NavigationCubit, AppScreen>(
          builder: (context, state) {
            switch (state) {
              case AppScreen.barChart:
                return const ChartViewPage();
              case AppScreen.wallet:
                return const WalletScreen();
              case AppScreen.profile:
                return const ProfileScreen(userId: 1);
              case AppScreen.home:
              default:
                return const ExpenseList();
            }
          },
        ),
      ),
    );
  }
}

class ExpenseList extends StatelessWidget {
  const ExpenseList({super.key});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<ExpenseListCubit>().fetchExpensesForUser();
      },
      child: BlocBuilder<ExpenseListCubit, ExpenseListState>(
        builder: (context, state) {
          if (state is ExpenseListInitial) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ExpenseListLoaded) {
            final expenses = state.expenses;
            return ListView.builder(
              itemCount: expenses.length,
              itemBuilder: (context, index) {
                final expense = expenses[index];
                final formattedDate = DateFormat.yMEd().format(expense.date!);
                return Card(
                  color: const Color(0xB90F5854),
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(formattedDate),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(' ₺ -${expense.cost}'),
                        Text(getCategoryEmoji(expense.category!)),
                        Text(getPaymentMethodEmoji(
                            expense.paymentMethod!, expense.cardLastdigits!)),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return EditExpenseDialog(expense: expense);
                              },
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            context
                                .read<ExpenseListCubit>()
                                .deleteExpense(expense.id!);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          } else if (state is ExpenseListError) {
            return Center(child: Text(state.message));
          } else {
            return Container(); // Handle other cases as needed
          }
        },
      ),
    );
  }
}

class MyExpenseDialog extends StatefulWidget {
  const MyExpenseDialog({super.key});

  @override
  _MyExpenseDialogState createState() => _MyExpenseDialogState();
}

class _MyExpenseDialogState extends State<MyExpenseDialog> {
  final TextEditingController cardLastDigitsController =
      TextEditingController();

  final TextEditingController costController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  ExpenseCategory selectedExpenseCategory = ExpenseCategory.general;
  PaymentMethod selectedPaymentMethod = PaymentMethod.cash;

  @override
  void dispose() {
    costController.dispose();
    nameController.dispose();
    cardLastDigitsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ExpenseCreationCubit(),
      child: AlertDialog(
        insetPadding: EdgeInsets.zero,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
        backgroundColor: Colors.teal[800],
        title: const Center(child: Text('Add New Expense')),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextFieldContainer(
                child: TextFormField(
                  controller: costController,
                  decoration: const InputDecoration(
                    labelText: 'Cost',
                    icon: Icon(Icons.attach_money),
                    border: InputBorder.none,
                    labelStyle: TextStyle(color: Colors.white),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              BlocBuilder<ExpenseCreationCubit, ExpenseCreationState>(
                builder: (context, state) {
                  return TextFieldContainer(
                    child: DropdownButton<ExpenseCategory>(
                      underline: Container(),
                      value: selectedExpenseCategory,
                      onChanged: (value) {
                        setState(() {
                          selectedExpenseCategory = value!;
                        });
                      },
                      items: ExpenseCategory.values
                          .map<DropdownMenuItem<ExpenseCategory>>(
                        (ExpenseCategory value) {
                          return DropdownMenuItem<ExpenseCategory>(
                            value: value,
                            child: Text(expenseCategoryNames[value]!),
                          );
                        },
                      ).toList(),
                    ),
                  );
                },
              ),
              BlocBuilder<ExpenseCreationCubit, ExpenseCreationState>(
                builder: (context, state) {
                  return Column(
                    children: [
                      TextFieldContainer(
                        child: DropdownButton<PaymentMethod>(
                          underline: Container(),
                          value: selectedPaymentMethod,
                          onChanged: (value) {
                            setState(() {
                              selectedPaymentMethod = value!;
                            });
                          },
                          items: PaymentMethod.values
                              .map<DropdownMenuItem<PaymentMethod>>(
                                (PaymentMethod value) =>
                                    DropdownMenuItem<PaymentMethod>(
                                  value: value,
                                  child: Text(paymentMethodNames[value]!),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                      if (selectedPaymentMethod == PaymentMethod.creditCard ||
                          selectedPaymentMethod == PaymentMethod.debitCard)
                        TextFieldContainer(
                          child: TextFormField(
                            controller: cardLastDigitsController,
                            decoration: const InputDecoration(
                              labelText: 'Last 4 digits',
                              border: InputBorder.none,
                              icon: Icon(Icons.password),
                              labelStyle: TextStyle(color: Colors.white),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () async {
                final selectedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );
                if (selectedDate != null) {
                  User registeredUser =
                      await getIt<ExpensesDatabase>().readUser(1);
                  Expense newExpense = Expense(
                    userId: registeredUser.id,
                    cost: double.parse(costController.text),
                    category: selectedExpenseCategory.toString(),
                    name: nameController.text,
                    paymentMethod: selectedPaymentMethod.toString(),
                    cardLastdigits: cardLastDigitsController.text,
                    date: selectedDate,
                  );

                  getIt<ExpensesDatabase>().createExpense(newExpense);
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal[600],
                  fixedSize: const Size(200, 30)),
              child: const Text('Save'),
            ),
          ),
        ],
      ),
    );
  }
}

class EditExpenseDialog extends StatefulWidget {
  final Expense expense;

  const EditExpenseDialog({required this.expense, Key? key}) : super(key: key);

  @override
  _EditExpenseDialogState createState() => _EditExpenseDialogState();
}

class _EditExpenseDialogState extends State<EditExpenseDialog> {
  final TextEditingController cardLastDigitsController =
      TextEditingController();
  final TextEditingController costController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  ExpenseCategory selectedExpenseCategory = ExpenseCategory.general;
  PaymentMethod selectedPaymentMethod = PaymentMethod.cash;

  @override
  void initState() {
    super.initState();

    final Expense expense = widget.expense;

    costController.text = expense.cost.toString();
    selectedExpenseCategory =
        enumFromString(expense.category, ExpenseCategory.values)!;
    selectedPaymentMethod =
        enumFromString(expense.paymentMethod, PaymentMethod.values)!;

    if (expense.paymentMethod == PaymentMethod.creditCard.toString() ||
        expense.paymentMethod == PaymentMethod.debitCard.toString()) {
      cardLastDigitsController.text = expense.cardLastdigits!;
    }
  }

  T? enumFromString<T>(String? value, List<T> values) {
    if (value == null) {
      return null;
    }

    try {
      return values.firstWhere((type) => type.toString() == value);
    } catch (e) {
      return null;
    }
  }

  @override
  void dispose() {
    cardLastDigitsController.dispose();
    costController.dispose();
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
      backgroundColor: Colors.teal[800],
      title: const Center(child: Text('Edit Expense')),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFieldContainer(
              child: TextFormField(
                controller: costController,
                decoration: const InputDecoration(
                  labelText: 'Cost',
                  icon: Icon(Icons.attach_money),
                  border: InputBorder.none,
                  labelStyle: TextStyle(color: Colors.white),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            TextFieldContainer(
              child: DropdownButton<ExpenseCategory>(
                underline: Container(),
                value: selectedExpenseCategory,
                onChanged: (value) {
                  setState(() {
                    selectedExpenseCategory = value!;
                  });
                },
                items: ExpenseCategory.values
                    .map<DropdownMenuItem<ExpenseCategory>>(
                  (ExpenseCategory value) {
                    return DropdownMenuItem<ExpenseCategory>(
                      value: value,
                      child: Text(expenseCategoryNames[value]!),
                    );
                  },
                ).toList(),
              ),
            ),
            Column(
              children: [
                TextFieldContainer(
                  child: DropdownButton<PaymentMethod>(
                    underline: Container(),
                    value: selectedPaymentMethod,
                    onChanged: (value) {
                      setState(() {
                        selectedPaymentMethod = value!;
                      });
                    },
                    items: PaymentMethod.values
                        .map<DropdownMenuItem<PaymentMethod>>(
                          (PaymentMethod value) =>
                              DropdownMenuItem<PaymentMethod>(
                            value: value,
                            child: Text(paymentMethodNames[value]!),
                          ),
                        )
                        .toList(),
                  ),
                ),
                if (selectedPaymentMethod == PaymentMethod.creditCard ||
                    selectedPaymentMethod == PaymentMethod.debitCard)
                  TextFieldContainer(
                    child: TextFormField(
                      controller: cardLastDigitsController,
                      decoration: const InputDecoration(
                        labelText: 'Last 4 digits',
                        border: InputBorder.none,
                        icon: Icon(Icons.password),
                        labelStyle: TextStyle(color: Colors.white),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        Center(
          child: ElevatedButton(
            onPressed: () async {
              final selectedDate = await showDatePicker(
                context: context,
                initialDate: widget.expense.date!,
                firstDate: DateTime(2000),
                lastDate: DateTime(2101),
              );
              if (selectedDate != null) {
                final Expense updatedExpense = widget.expense.copyWith(
                  cost: double.parse(costController.text),
                  category: selectedExpenseCategory.toString(),
                  paymentMethod: selectedPaymentMethod.toString(),
                  cardLastdigits: cardLastDigitsController.text,
                  date: selectedDate,
                );

                getIt<ExpensesDatabase>().updateExpense(updatedExpense);

                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal[600],
                fixedSize: const Size(200, 30)),
            child: const Text('Save'),
          ),
        ),
      ],
    );
  }
}

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationCubit, AppScreen>(
      builder: (context, currentScreen) {
        return BottomAppBar(
          color: const Color(0xff368983),
          shape: const CircularNotchedRectangle(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  context.read<NavigationCubit>().navigateTo(AppScreen.home);
                },
                child: const Icon(
                  Icons.home,
                  size: 40,
                ),
              ),
              GestureDetector(
                onTap: () {
                  context
                      .read<NavigationCubit>()
                      .navigateTo(AppScreen.barChart);
                },
                child: const Icon(
                  Icons.bar_chart_outlined,
                  size: 40,
                ),
              ),
              GestureDetector(
                onTap: () {
                  context.read<NavigationCubit>().navigateTo(AppScreen.wallet);
                },
                child: const Icon(
                  Icons.wallet,
                  size: 40,
                ),
              ),
              GestureDetector(
                onTap: () {
                  context.read<NavigationCubit>().navigateTo(AppScreen.profile);
                },
                child: const Icon(
                  Icons.person_outlined,
                  size: 40,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
