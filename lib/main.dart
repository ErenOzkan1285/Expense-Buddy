import 'package:expensebuddy/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:expensebuddy/register/view/register_view.dart';
import 'package:expensebuddy/home/view/home_view.dart';
import 'package:expensebuddy/database/app_database.dart';
import 'package:sqflite/sqflite.dart';
import 'core/app_configuration/dependency_configuration.dart';
//TODO: SDK -> C:\Users\ereno\AppData\Local\Android\Sdk
//TODO: DB PATH -> /data/user/0/com.example.expensebuddy/databases

void main() async {
  configureInjection();
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseMessaging.instance.subscribeToTopic('app');
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );
  final fcmToken = await FirebaseMessaging.instance.getToken();
  print(fcmToken);
  bool hasRegisteredUser = await checkRegisteredUser();
  final dbPath = await getDatabasesPath();
  // ignore: avoid_print
  print(dbPath);
  runApp(ExpenseBuddy(hasRegisteredUser: hasRegisteredUser));
}

class ExpenseBuddy extends StatelessWidget {
  final bool hasRegisteredUser;

  const ExpenseBuddy({required this.hasRegisteredUser, super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Material App',
      theme: ThemeData.dark(),
      home: hasRegisteredUser ? const HomeView() : const LoginView(),
    );
  }
}

Future<bool> checkRegisteredUser() async {
  try {
    final db = getIt<ExpensesDatabase>();
    return await db.checkIfUserExist(1);
  } catch (e) {
    print('Error in checkRegisteredUser: $e');
    return false;
  }
}
