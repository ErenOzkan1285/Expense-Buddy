//GIDERLER
/*
id
tutar
kategori
tarih
parambirimi? 
giderismi
nakit-krediKartı-bankaKartı
kartsondörthane
 */

const String tableExpenses = 'expenses';

class ExpenseFields {
  static const String id = 'id';
  static const String userId = 'userId';
  static const String cost = 'cost';
  static const String category = 'category';
  static const String date = 'date';
  static const String name = 'name';
  static const String paymentMethod = 'paymentMethod';
  static const String cardLastdigits = 'cardLastdigits';

  static const List<String> values = [
    id,
    userId,
    cost,
    category,
    date,
    name,
    paymentMethod,
    cardLastdigits
  ];
}

class Expense {
  final int? userId;
  final int? id;
  final double? cost;
  final String? category;
  final DateTime? date;
  final String? name;
  final String? paymentMethod;
  final String? cardLastdigits;

  const Expense(
      {this.id,
      this.userId,
      this.cost,
      this.category,
      this.date,
      this.name,
      this.paymentMethod,
      this.cardLastdigits});

  Map<String, dynamic> toJson() => {
        ExpenseFields.userId: userId,
        ExpenseFields.id: id,
        ExpenseFields.cost: cost,
        ExpenseFields.category: category,
        ExpenseFields.date: date?.toIso8601String(),
        ExpenseFields.name: name,
        ExpenseFields.paymentMethod: paymentMethod,
        ExpenseFields.cardLastdigits: cardLastdigits!,
      };

  static Expense fromJson(Map<String, Object?> json) => Expense(
        id: json[ExpenseFields.id] as int,
        userId: json[ExpenseFields.userId] as int,
        cost: json[ExpenseFields.cost] as double,
        category: json[ExpenseFields.category] as String?,
        name: json[ExpenseFields.name] as String?,
        paymentMethod: json[ExpenseFields.paymentMethod] as String?,
        cardLastdigits: json[ExpenseFields.cardLastdigits] as String?,
        date: DateTime.parse(json[ExpenseFields.date] as String),
      );

  Expense copyWith({
    int? id,
    int? userId,
    double? cost,
    String? category,
    DateTime? date,
    String? name,
    String? paymentMethod,
    String? cardLastdigits,
  }) {
    return Expense(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      cost: cost ?? this.cost,
      category: category ?? this.category,
      date: date ?? this.date,
      name: name ?? this.name,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      cardLastdigits: cardLastdigits ?? this.cardLastdigits,
    );
  }
}
