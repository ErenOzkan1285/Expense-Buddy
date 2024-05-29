import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'databaseModels/expenses_model.dart';
import 'databaseModels/user_model.dart';

class ExpensesDatabase {
  static final ExpensesDatabase instance = ExpensesDatabase._init();
  static Database? _database;
  ExpensesDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('expensebuddy.db');
    return database;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    print(dbPath);
    final path = join(dbPath, filePath);
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER';
    const textType = 'TEXT NOT NULL';
    const moneyType = 'DOUBLE NOT NULL';

    await db.execute('''
    CREATE TABLE $tableUsers (
    ${UserFields.id} $idType  PRIMARY KEY AUTOINCREMENT,
    ${UserFields.email} $textType,
    ${UserFields.username} $textType,
    ${UserFields.totalExpanses} $moneyType,
    ${UserFields.income} $moneyType
    )
    ''');

    await db.execute('''
    CREATE TABLE $tableExpenses (
    ${ExpenseFields.id} $idType PRIMARY KEY AUTOINCREMENT,
    ${ExpenseFields.userId} $idType,
    ${ExpenseFields.cost} $moneyType,
    ${ExpenseFields.category} $textType,
    ${ExpenseFields.date} DATETIME,
    ${ExpenseFields.name} $textType,
    ${ExpenseFields.paymentMethod} $textType,
    ${ExpenseFields.cardLastdigits} $textType,
    FOREIGN KEY (${ExpenseFields.userId}) REFERENCES $tableUsers(${UserFields.id})
    )
    ''');
  }

  //CRUD OPERATIONS FOR USER

  Future<User> createUser(User user) async {
    final db = await instance.database;
    final id = await db.insert(tableUsers, user.toJson());

    //final id = await db.rawInsert('INSERT INTO users ($columns)');

    return user.copyWith(id: id);
  }

  Future<User> readUser(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      tableUsers,
      columns: UserFields.values,
      where: '${UserFields.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return User.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  Future<bool> checkIfUserExist(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      tableUsers,
      columns: UserFields.values,
      where: '${UserFields.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return true;
    } else {
      throw Exception('ID $id not found');
    }
  }

  Future<List<User>> readAllUsers() async {
    final db = await instance.database;

    final result = await db.query(tableUsers);

    return result.map((e) => User.fromJson(e)).toList();
  }

  Future<int> updateUser(User user) async {
    final db = await instance.database;

    return db.update(
      tableUsers,
      user.toJson(),
      where: '${user.id} = ?',
      whereArgs: [user.id],
    );
  }

  Future<int> deleteUser(int id) async {
    final db = await instance.database;

    return await db.delete(
      tableUsers,
      where: '${UserFields.id} = ?',
      whereArgs: [id],
    );
  }

  //CRUD OPERATIONS FOR EXPENSE
  Future<Expense> createExpense(Expense expense) async {
    final db = await instance.database;
    final id = await db.insert(tableExpenses, expense.toJson());

    final user = await readUser(expense.userId!);
    final updatedTotalExpenses = (user.totalExpanses ?? 0) + expense.cost!;
    final updatedUser = user.copyWith(totalExpanses: updatedTotalExpenses);
    await updateUser(updatedUser);

    return expense.copyWith(id: id);
  }

  Future<List<Expense>> readAllExpenses() async {
    final db = await instance.database;

    final result = await db.query(tableExpenses);

    return result.map((e) => Expense.fromJson(e)).toList();
  }

  Future<Expense> readExpense(int id, int userId) async {
    final db = await instance.database;
    final maps = await db.query(
      tableExpenses,
      columns: ExpenseFields.values,
      where: '${ExpenseFields.id} = ? AND ${ExpenseFields.userId} = ?',
      whereArgs: [id, userId],
    );

    if (maps.isNotEmpty) {
      return Expense.fromJson(maps.first);
    } else {
      throw Exception('Expense with ID $id and User ID $userId not found');
    }
  }

  Future<List<Expense>> readAllExpensesForUser(int userId) async {
    final db = await instance.database;

    final result = await db.query(
      tableExpenses,
      where: '${ExpenseFields.userId} = ?',
      whereArgs: [userId],
    );

    return result.map((e) => Expense.fromJson(e)).toList();
  }

  Future<int> updateExpense(Expense expense) async {
    final db = await instance.database;

    final user = await readUser(expense.userId!);
    final oldExpense = await readExpense(expense.id!, expense.userId!);

    // Calculate the difference in cost
    final costDifference = expense.cost! - oldExpense.cost!;

    // Calculate the new totalExpanses value after adjusting for the cost difference
    final newTotalExpanses = user.totalExpanses! + costDifference;

    await db.update(
      tableUsers,
      {UserFields.totalExpanses: newTotalExpanses},
      where: '${UserFields.id} = ?',
      whereArgs: [expense.userId],
    );

    return db.update(
      tableExpenses,
      expense.toJson(),
      where: '${ExpenseFields.id} = ? AND ${ExpenseFields.userId} = ?',
      whereArgs: [expense.id, expense.userId],
    );
  }

  Future<double> calculateAllExpenses(int userId) async {
    final db = await instance.database;
    final result = await db.rawQuery('''
      SELECT SUM(${ExpenseFields.cost}) AS totalExpenses
      FROM $tableExpenses
      WHERE ${ExpenseFields.userId} = $userId
    ''');

    final totalExpenses = result.first['totalExpenses'] as double?;
    return totalExpenses ?? 0;
  }

  Future<int> deleteExpense(int userId, int expenseId) async {
    final db = await instance.database;

    // Get the expense that is going to be deleted
    final deletedExpense = await readExpense(expenseId, userId);

    // Calculate the new totalExpenses value after deducting the deleted expense's cost
    final newTotalExpenses =
        await calculateAllExpenses(userId) - deletedExpense.cost!;

    // Update the user's totalExpenses value in the database
    await db.update(
      tableUsers,
      {UserFields.totalExpanses: newTotalExpenses},
      where: '${UserFields.id} = ?',
      whereArgs: [userId],
    );

    // Delete the expense
    return await db.delete(
      tableExpenses,
      where: '${ExpenseFields.id} = ? AND ${ExpenseFields.userId} = ?',
      whereArgs: [expenseId, userId],
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }

  Future<int> updateIncome(int userId, double newIncome) async {
    final db = await instance.database;

    return db.update(
      tableUsers,
      {UserFields.income: newIncome},
      where: '${UserFields.id} = ?',
      whereArgs: [userId],
    );
  }

  Future<void> dropAndRecreateTables() async {
    final db = await instance.database;

    await db.execute('DROP TABLE IF EXISTS $tableExpenses');
    await db.execute('DROP TABLE IF EXISTS $tableUsers');

    await _createDB(db, 1);
  }

  Future<void> resetDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'expensebuddy.db');

    if (_database != null && _database!.isOpen) {
      await _database!.close();
    }
    await deleteDatabase(path);
    _database = null;
  }

  Future<void> testCRUD() async {
    try {
      // Test CRUD operations for User
      final newUser = User(
        email: 'test@example.com',
        username: 'test_user',
        totalExpanses: 0.0,
      );

      final createdUser = await instance.createUser(newUser);
      print('Created User: $createdUser');

      final readUser = await instance.readUser(createdUser.id!);
      print('Read User: ${readUser.toString()}');

      final allUsers = await instance.readAllUsers();
      print('All Users: $allUsers');

      final updatedUser = readUser.copyWith(username: 'updated_user');
      final updatedCount = await instance.updateUser(updatedUser);
      print('Updated User Count: $updatedCount');

      final deletedCount = await instance.deleteUser(updatedUser.id!);
      print('Deleted User Count: $deletedCount');

      await resetDatabase();
    } catch (e) {
      print('Error: $e');
    } finally {
      instance.close();
    }
  }
}
