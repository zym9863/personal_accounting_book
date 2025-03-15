import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../providers/transaction_provider.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '收入'),
            Tab(text: '支出'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildIncomeStatistics(),
              _buildExpenseStatistics(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIncomeStatistics() {
    return Consumer<TransactionProvider>(
      builder: (context, provider, child) {
        if (provider.incomeTransactions.isEmpty) {
          return const Center(
            child: Text('暂无收入记录'),
          );
        }
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSummaryCard(
                '总收入',
                provider.totalIncome,
                Colors.green,
                Icons.arrow_upward,
              ),
              const SizedBox(height: 24),
              const Text(
                '收入分类统计',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 300,
                child: _buildPieChart(provider.incomeCategorySum, Colors.green),
              ),
              const SizedBox(height: 24),
              const Text(
                '收入记录',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildTransactionList(provider.incomeTransactions),
            ],
          ),
        );
      },
    );
  }

  Widget _buildExpenseStatistics() {
    return Consumer<TransactionProvider>(
      builder: (context, provider, child) {
        if (provider.expenseTransactions.isEmpty) {
          return const Center(
            child: Text('暂无支出记录'),
          );
        }
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSummaryCard(
                '总支出',
                provider.totalExpense,
                Colors.red,
                Icons.arrow_downward,
              ),
              const SizedBox(height: 24),
              const Text(
                '支出分类统计',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 300,
                child: _buildPieChart(provider.expenseCategorySum, Colors.red),
              ),
              const SizedBox(height: 24),
              const Text(
                '支出记录',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildTransactionList(provider.expenseTransactions),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryCard(String title, double amount, Color color, IconData icon) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.2),
              radius: 24,
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(
                  '¥${amount.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChart(Map<Category, double> categorySums, Color baseColor) {
    if (categorySums.isEmpty) {
      return const Center(child: Text('暂无数据'));
    }
    
    final List<PieChartSectionData> sections = [];
    final List<Widget> indicators = [];
    final total = categorySums.values.fold(0.0, (sum, amount) => sum + amount);
    
    // 生成不同的颜色
    final List<Color> colors = [
      baseColor,
      baseColor.withOpacity(0.8),
      baseColor.withOpacity(0.6),
      baseColor.withOpacity(0.4),
      baseColor.withOpacity(0.2),
      baseColor.withRed((baseColor.red + 50) % 256),
      baseColor.withGreen((baseColor.green + 50) % 256),
      baseColor.withBlue((baseColor.blue + 50) % 256),
      baseColor.withRed((baseColor.red + 100) % 256),
      baseColor.withGreen((baseColor.green + 100) % 256),
    ];
    
    int index = 0;
    categorySums.forEach((category, amount) {
      final percentage = (amount / total * 100).toStringAsFixed(1);
      final color = colors[index % colors.length];
      
      sections.add(
        PieChartSectionData(
          value: amount,
          title: '$percentage%',
          color: color,
          radius: 100,
          titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      );
      
      indicators.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            children: [
              Container(
                width: 16,
                height: 16,
                color: color,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _getCategoryName(category),
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              Text(
                '¥${amount.toStringAsFixed(2)} ($percentage%)',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      );
      
      index++;
    });
    
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: PieChart(
            PieChartData(
              sections: sections,
              centerSpaceRadius: 40,
              sectionsSpace: 2,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: indicators,
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionList(List<Transaction> transactions) {
    final formatter = DateFormat('yyyy-MM-dd');
    
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: transactions.length > 5 ? 5 : transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        final color = transaction.type == TransactionType.income ? Colors.green : Colors.red;
        
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: color.withOpacity(0.2),
            child: Icon(_getCategoryIcon(transaction.category), color: color),
          ),
          title: Text(transaction.title),
          subtitle: Text(formatter.format(transaction.date)),
          trailing: Text(
            '¥${transaction.amount.toStringAsFixed(2)}',
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        );
      },
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