import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/transaction.dart';
import '../providers/transaction_provider.dart';
import 'add_transaction_screen.dart';

class TransactionListScreen extends StatelessWidget {
  const TransactionListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, provider, child) {
        if (provider.transactions.isEmpty) {
          return const Center(
            child: Text('暂无交易记录，点击下方 + 按钮添加'),
          );
        }
        
        return ListView.builder(
          itemCount: provider.transactions.length,
          itemBuilder: (context, index) {
            final transaction = provider.transactions[index];
            return _buildTransactionItem(context, transaction, provider);
          },
        );
      },
    );
  }

  Widget _buildTransactionItem(BuildContext context, Transaction transaction, TransactionProvider provider) {
    final formatter = DateFormat('yyyy-MM-dd');
    final color = transaction.type == TransactionType.income ? Colors.green : Colors.red;
    final icon = _getCategoryIcon(transaction.category);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(transaction.title),
        subtitle: Text('${formatter.format(transaction.date)} · ${_getCategoryName(transaction.category)}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${transaction.type == TransactionType.income ? '+' : '-'}¥${transaction.amount.toStringAsFixed(2)}',
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddTransactionScreen(transaction: transaction),
                  ),
                ).then((_) {
                  provider.loadTransactions();
                });
              },
              tooltip: '编辑',
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                provider.deleteTransaction(transaction.id!);
              },
              tooltip: '删除',
            ),
          ],
        ),
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(transaction.title),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('金额: ${transaction.type == TransactionType.income ? '+' : '-'}¥${transaction.amount.toStringAsFixed(2)}'),
                  Text('日期: ${formatter.format(transaction.date)}'),
                  Text('类型: ${transaction.type == TransactionType.income ? '收入' : '支出'}'),
                  Text('分类: ${_getCategoryName(transaction.category)}'),
                  if (transaction.note != null && transaction.note!.isNotEmpty)
                    Text('备注: ${transaction.note}'),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('关闭'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  IconData _getCategoryIcon(Category category) {
    switch (category) {
      case Category.food:
        return Icons.restaurant;
      case Category.transportation:
        return Icons.directions_car;
      case Category.entertainment:
        return Icons.movie;
      case Category.shopping:
        return Icons.shopping_bag;
      case Category.utilities:
        return Icons.water_damage;
      case Category.health:
        return Icons.health_and_safety;
      case Category.education:
        return Icons.school;
      case Category.salary:
        return Icons.attach_money;
      case Category.gift:
        return Icons.card_giftcard;
      case Category.other:
        return Icons.more_horiz;
    }
  }

  String _getCategoryName(Category category) {
    switch (category) {
      case Category.food:
        return '餐饮';
      case Category.transportation:
        return '交通';
      case Category.entertainment:
        return '娱乐';
      case Category.shopping:
        return '购物';
      case Category.utilities:
        return '水电煤';
      case Category.health:
        return '医疗健康';
      case Category.education:
        return '教育';
      case Category.salary:
        return '工资';
      case Category.gift:
        return '礼金';
      case Category.other:
        return '其他';
    }
  }
}