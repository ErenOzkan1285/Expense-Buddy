import 'dart:convert';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../core/app_configuration/dependency_configuration.dart';
import '../../core/constants/variables.dart';
import '../../database/app_database.dart';
import '../../database/databaseModels/expenses_model.dart';
import '../../database/databaseModels/user_model.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Center(
              child: Image(
                image: AssetImage('assets/robot.gif'),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Hello! I am your AI assistant.\nWould you like me to analyze your expenses? ",
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () async {
                User user = await getIt<ExpensesDatabase>().readUser(1);
                double totalExpenses = user.totalExpanses!;

                List<Expense> expenses =
                    await getIt<ExpensesDatabase>().readAllExpensesForUser(1);

                Map<String, double> categoryPercentages = {};
                for (var expense in expenses) {
                  if (expense.category != null) {
                    if (categoryPercentages.containsKey(expense.category!)) {
                      categoryPercentages[expense.category!] =
                          categoryPercentages[expense.category!]! +
                              (expense.cost! / totalExpenses);
                    } else {
                      categoryPercentages[expense.category!] =
                          expense.cost! / totalExpenses;
                    }
                  }
                }
                sendEmail(
                  user: user,
                  totalExpenses: totalExpenses,
                  categoryPercentages: categoryPercentages,
                );
                final snackBar = SnackBar(
                  /// need to set following properties for best effect of awesome_snackbar_content
                  elevation: 0,
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: Colors.transparent,
                  content: AwesomeSnackbarContent(
                    title: 'E-mail has been sent!',
                    message:
                        'The e-mail that contains your analysis report has been sent to ${user.email}. Dont forget to check it!',
                    contentType: ContentType.success,
                  ),
                );
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(snackBar);
              },
              child: const Text('Analyze My Data'),
            ),
          ],
        )
      ],
    );
  }
}

Future sendEmail({
  required double totalExpenses,
  required User user,
  required Map<String, double> categoryPercentages,
}) async {
  final url1 = Uri.parse(CHATGPT_BASE_URL);

  Map<String, dynamic> data = {
    "model": "gpt-3.5-turbo",
    "messages": [
      {
        "role": "user",
        "content": "You are the assistant artificial intelligence in an expense application dont also dont forget that they cant ask you specific questions since this is not AI chat app."
            "Put yourself in the place of the best consultant in the world. Every time the user sends you a request,"
            "you will create a report for him and this report will be sent to the user as an e-mail. For example: In ${user.username}'s expenses chart,"
            "the expense distribution among categories is as follows: ${_formatCategoryPercentages(categoryPercentages)}"
            "Also, ${user.username}'s monthly income is ${user.income} TL and ${user.username} spends ${user.totalExpanses} TL. You should advise ${user.username} in detail."
            " Assistant name is Expense Buddy AI Assistant. There will be no subject part in this e-mail."
            "In certain sections, you can address them by name. And also dont forget that they cant ask you specific questions since this is not AI chat app."
      }
    ],
    "temperature": 0.7
  };

  final gptResponse = await http.post(
    url1,
    headers: {
      'Authorization': 'Bearer $CHATGPT_API_KEY',
      'Content-Type': 'application/json',
    },
    body: json.encode(data),
  );

  Map jsonResponse = jsonDecode(gptResponse.body);
  final String message = jsonResponse['choices'][0]['message']['content'];
  print(jsonResponse);

  final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');
  final response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
      'origin': 'http://localhost',
    },
    body: json.encode({
      'service_id': 'service_ne29i0c',
      'template_id': 'template_mg1qsnr',
      'user_id': '4h0ssjgwMjTpQFefv',
      'template_params': {'to_mail': user.email, 'message': message},
    }),
  );
  print(response.body);
}

String _formatCategoryPercentages(Map<String, double> categoryPercentages) {
  final List<String> formattedCategories = [];
  categoryPercentages.forEach((category, percentage) {
    formattedCategories.add(
        '${category.split('.').last}: ${(percentage * 100).toStringAsFixed(2)}%');
  });
  return formattedCategories.join(', ');
}
