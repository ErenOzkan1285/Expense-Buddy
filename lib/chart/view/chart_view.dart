import 'package:expensebuddy/core/app_configuration/dependency_configuration.dart';
import 'package:expensebuddy/core/extensions/categoryExtensions.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../database/app_database.dart';
import '../../database/databaseModels/expenses_model.dart';
import '../../database/databaseModels/user_model.dart';

class ChartViewPage extends StatefulWidget {
  const ChartViewPage({super.key});

  @override
  _ChartViewPageState createState() => _ChartViewPageState();
}

class _ChartViewPageState extends State<ChartViewPage> {
  List<Expense> expenses = [];
  User user =
      User(id: 0, username: "a", email: "a", totalExpanses: 0.0, income: 0.0);

  @override
  void initState() {
    super.initState();
    _fetchExpensesData();
  }

  Future<void> _fetchExpensesData() async {
    try {
      final allExpenses = await getIt<ExpensesDatabase>().readAllExpenses();
      final iuser = await getIt<ExpensesDatabase>().readUser(1);
      setState(() {
        expenses = allExpenses;
        user = iuser;
      });
    } catch (e) {
      print('Error fetching expenses data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calculate total expense cost for each category
    Map<String, double> categoryTotalExpenses =
        expenses.calculateCategoryTotalExpenses();

    // Calculate total expenses for percentage calculation
    double totalExpenses = 0;
    for (var totalExpense in categoryTotalExpenses.values) {
      totalExpenses += totalExpense;
    }

    // Create data source for doughnut chart
    List<ChartData> chartData = [];
    List<Color> colors = [];
    int colorIndex = 0;

    categoryTotalExpenses.forEach((category, totalExpense) {
      chartData.add(ChartData(category, totalExpense));
      colors.add(Colors.primaries[colorIndex]);
      colorIndex = (colorIndex + 1) % Colors.primaries.length;
    });

    return Scaffold(
      backgroundColor: Colors.teal[700],
      body: Column(
        children: [
          const SizedBox(height: 20),
          Center(
            child: expenses.isNotEmpty
                ? SfCircularChart(
                    series: <CircularSeries>[
                      DoughnutSeries<ChartData, String>(
                        dataSource: chartData,
                        xValueMapper: (ChartData data, _) => data.category,
                        yValueMapper: (ChartData data, _) => data.totalExpense,
                        dataLabelSettings:
                            const DataLabelSettings(isVisible: true),
                        pointColorMapper: (ChartData data, _) =>
                            colors[chartData.indexOf(data)],
                        dataLabelMapper: (ChartData data, _) =>
                            '${data.category} (${((data.totalExpense / totalExpenses) * 100).toStringAsFixed(2)}%)',
                      ),
                    ],
                  )
                : const Text(
                    "You don't have any expenses yet yeeey! 🎉",
                    style: TextStyle(fontSize: 18),
                  ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 0, 10),
            child: Row(
              children: [
                Text("Your income : ₺${user.income}"),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.2,
                ),
                Text("Total Expenses: ₺${user.totalExpanses}"),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: chartData.length,
              itemBuilder: (context, index) {
                return Card(
                  color: Colors.teal[400],
                  child: ListTile(
                    leading: Container(
                      width: 16,
                      height: 16,
                      color: colors[index],
                    ),
                    title: Text(chartData[index].category),
                    subtitle: Text(
                        '₺${chartData[index].totalExpense.toStringAsFixed(2)}'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ChartData {
  final String category;
  final double totalExpense;

  ChartData(this.category, this.totalExpense);
}
