import 'package:intl/intl.dart';

enum TransactionType {
  income,
  expense,
}

enum Category {
  food,
  transportation,
  entertainment,
  shopping,
  utilities,
  health,
  education,
  salary,
  gift,
  other,
}

class Transaction {
  final int? id;
  final String title;
  final double amount;
  final DateTime date;
  final TransactionType type;
  final Category category;
  final String? note;

  Transaction({
    this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.type,
    required this.category,
    this.note,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': DateFormat('yyyy-MM-dd').format(date),
      'type': type.toString().split('.').last,
      'category': category.toString().split('.').last,
      'note': note,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      title: map['title'],
      amount: map['amount'],
      date: DateFormat('yyyy-MM-dd').parse(map['date']),
      type: TransactionType.values.firstWhere(
          (e) => e.toString().split('.').last == map['type']),
      category: Category.values.firstWhere(
          (e) => e.toString().split('.').last == map['category']),
      note: map['note'],
    );
  }

  Transaction copyWith({
    int? id,
    String? title,
    double? amount,
    DateTime? date,
    TransactionType? type,
    Category? category,
    String? note,
  }) {
    return Transaction(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      type: type ?? this.type,
      category: category ?? this.category,
      note: note ?? this.note,
    );
  }
}