//USER
/*
id*
username
email
total_harcama
*/
const String tableUsers = 'users';

class UserFields {
  static final List<String> values = [
    id,
    username,
    email,
    totalExpanses,
    income
  ];

  static const String id = '_id';
  static const String username = 'username';
  static const String email = 'email';
  static const String totalExpanses = 'totalExpanses';
  static const String income = 'income';
}

class User {
  final int? id;
  final String? username;
  final String? email;
  final double? totalExpanses;
  final double? income;

  User({this.id, this.username, this.email, this.totalExpanses, this.income});

  @override
  String toString() {
    return '\nid: $id\nemail: $email,\nusername: $username,\ntotalExpanses: $totalExpanses\n\n,';
  }

  Map<String, dynamic> toJson() => {
        UserFields.id: id,
        UserFields.email: email,
        UserFields.username: username,
        UserFields.totalExpanses: totalExpanses,
        UserFields.income: income,
      };
  static User fromJson(Map<String, Object?> json) => User(
        id: json[UserFields.id] as int?,
        username: json[UserFields.username] as String?,
        email: json[UserFields.email] as String?,
        totalExpanses: json[UserFields.totalExpanses] as double?,
        income: json[UserFields.income] as double?,
      );

  User copyWith({
    int? id,
    final String? username,
    final String? email,
    final double? totalExpanses,
    final double? income,
  }) =>
      User(
        id: id ?? this.id,
        email: email ?? this.email,
        username: username ?? this.username,
        totalExpanses: totalExpanses ?? this.totalExpanses,
        income: income ?? this.income,
      );
}
