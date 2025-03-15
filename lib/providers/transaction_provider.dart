import 'package:flutter/foundation.dart' hide Category;
import '../models/transaction.dart';
import '../services/database_service.dart';

class TransactionProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  List<Transaction> _transactions = [];
  List<Transaction> _incomeTransactions = [];
  List<Transaction> _expenseTransactions = [];
  Map<Category, double> _incomeCategorySum = {};
  Map<Category, double> _expenseCategorySum = {};
  double _totalIncome = 0;
  double _totalExpense = 0;

  List<Transaction> get transactions => _transactions;
  List<Transaction> get incomeTransactions => _incomeTransactions;
  List<Transaction> get expenseTransactions => _expenseTransactions;
  Map<Category, double> get incomeCategorySum => _incomeCategorySum;
  Map<Category, double> get expenseCategorySum => _expenseCategorySum;
  double get totalIncome => _totalIncome;
  double get totalExpense => _totalExpense;
  double get balance => _totalIncome - _totalExpense;

  Future<void> loadTransactions() async {
    _transactions = await _databaseService.getTransactions();
    _incomeTransactions = await _databaseService.getTransactionsByType(TransactionType.income);
    _expenseTransactions = await _databaseService.getTransactionsByType(TransactionType.expense);
    _incomeCategorySum = await _databaseService.getCategorySum(TransactionType.income);
    _expenseCategorySum = await _databaseService.getCategorySum(TransactionType.expense);
    _calculateTotals();
    notifyListeners();
  }

  Future<void> addTransaction(Transaction transaction) async {
    final id = await _databaseService.insertTransaction(transaction);
    final newTransaction = transaction.copyWith(id: id);
    _transactions.add(newTransaction);
    
    if (transaction.type == TransactionType.income) {
      _incomeTransactions.add(newTransaction);
      _updateCategorySum(_incomeCategorySum, newTransaction);
      _totalIncome += newTransaction.amount;
    } else {
      _expenseTransactions.add(newTransaction);
      _updateCategorySum(_expenseCategorySum, newTransaction);
      _totalExpense += newTransaction.amount;
    }
    
    notifyListeners();
  }

  Future<void> updateTransaction(Transaction transaction) async {
    await _databaseService.updateTransaction(transaction);
    await loadTransactions(); // 重新加载所有数据以确保一致性
  }

  Future<void> deleteTransaction(int id) async {
    await _databaseService.deleteTransaction(id);
    await loadTransactions(); // 重新加载所有数据以确保一致性
  }

  void _calculateTotals() {
    _totalIncome = _incomeTransactions.fold(0, (sum, item) => sum + item.amount);
    _totalExpense = _expenseTransactions.fold(0, (sum, item) => sum + item.amount);
  }

  void _updateCategorySum(Map<Category, double> categorySum, Transaction transaction) {
    if (categorySum.containsKey(transaction.category)) {
      categorySum[transaction.category] = categorySum[transaction.category]! + transaction.amount;
    } else {
      categorySum[transaction.category] = transaction.amount;
    }
  }

  Future<List<Transaction>> getTransactionsByMonth(int year, int month) async {
    return await _databaseService.getTransactionsByMonth(year, month);
  }
}