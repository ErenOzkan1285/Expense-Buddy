import 'package:flutter/material.dart';
import '../../core/app_configuration/dependency_configuration.dart';
import '../../core/constants/widgets/textField_container.dart';
import '../../database/app_database.dart';
import '../../database/databaseModels/user_model.dart';

class ProfileScreen extends StatefulWidget {
  final int userId;

  const ProfileScreen({required this.userId, Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late User user;
  bool isLoading = true; // Ekranın yükleniyor durumunu takip etmek için

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final updatedUser =
          await getIt<ExpensesDatabase>().readUser(widget.userId);
      setState(() {
        user = updatedUser;
        isLoading = false; // Verilerin yüklendiğini işaretle
      });
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  void _showChangeIncomeDialog() {
    double newIncome = user.income ?? 0;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          insetPadding: EdgeInsets.zero,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
          backgroundColor: Colors.teal[800],
          title: const Text('Change Your Income'),
          content: TextFieldContainer(
            child: TextField(
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'New Income',
                border: InputBorder.none,
              ),
              onChanged: (value) {
                newIncome = double.tryParse(value) ?? 0;
              },
            ),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.teal,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.teal,
              ),
              onPressed: () async {
                // Update the user's income in the database
                final updatedUser = user.copyWith(income: newIncome);
                await getIt<ExpensesDatabase>().updateUser(updatedUser);
                setState(() {
                  user = updatedUser; // Kullanıcının gelirini güncelle
                });
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal[100],
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator() // Yükleniyor durumunda göster
            : Card(
                color: Colors.teal[700],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: RefreshIndicator(
                    onRefresh: _fetchUserData,
                    child: ListView(
                      children: [
                        ListTile(
                          title: const Text(
                            'Welcome',
                            style: TextStyle(fontSize: 48),
                          ),
                          subtitle: Text(
                            user.username!,
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 16),
                          height: 4,
                          color: Colors.teal[300],
                        ),
                        ListTile(
                          title: const Text(
                            'Your Email:',
                            style: TextStyle(fontSize: 18),
                          ),
                          subtitle: Text(
                            user.email!,
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
                        ListTile(
                          title: const Text(
                            'Total Expenses:',
                            style: TextStyle(fontSize: 18),
                          ),
                          subtitle: Text(
                            '₺${user.totalExpanses.toString()}',
                            style: const TextStyle(
                                fontSize: 18, color: Colors.red),
                          ),
                        ),
                        ListTile(
                          title: const Text(
                            'Income:',
                            style: TextStyle(fontSize: 18),
                          ),
                          subtitle: Text(
                            '₺${user.income.toString()}',
                            style: const TextStyle(
                                fontSize: 18, color: Colors.lightGreen),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(
                              onPressed: _showChangeIncomeDialog,
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.teal,
                              ),
                              child: const Text('Change Income'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                // Perform any action you want when the user clicks a button
                              },
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.teal,
                              ),
                              child: const Text('Edit Profile'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
