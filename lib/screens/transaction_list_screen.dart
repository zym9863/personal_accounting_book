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
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.receipt_long,
                  size: 80,
                  color: Colors.grey.withOpacity(0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  '暂无交易记录',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '点击下方 + 按钮添加',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          );
        }
        
        return ListView.builder(
          padding: const EdgeInsets.all(8),
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
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: color.withOpacity(0.2),
                    child: Icon(icon, color: color),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      transaction.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow(
                    Icons.payments,
                    '金额',
                    '${transaction.type == TransactionType.income ? '+' : '-'}¥${transaction.amount.toStringAsFixed(2)}',
                    color,
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    Icons.calendar_today,
                    '日期',
                    formatter.format(transaction.date),
                    Colors.blue,
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    Icons.category,
                    '分类',
                    _getCategoryName(transaction.category),
                    Colors.orange,
                  ),
                  if (transaction.note != null && transaction.note!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      Icons.note,
                      '备注',
                      transaction.note!,
                      Colors.grey,
                    ),
                  ],
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
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${formatter.format(transaction.date)} · ${_getCategoryName(transaction.category)}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${transaction.type == TransactionType.income ? '+' : '-'}¥${transaction.amount.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 20),
                        color: Colors.blue,
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
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 20),
                        color: Colors.red,
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              title: const Text('确认删除'),
                              content: const Text('确定要删除这条交易记录吗？'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('取消'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    provider.deleteTransaction(transaction.id!);
                                    Navigator.pop(context);
                                  },
                                  child: const Text(
                                    '删除',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        tooltip: '删除',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
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