import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/transaction.dart';
import '../providers/transaction_provider.dart';

class AddTransactionScreen extends StatefulWidget {
  final Transaction? transaction;
  
  const AddTransactionScreen({super.key, this.transaction});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();
  TransactionType _selectedType = TransactionType.expense;
  Category _selectedCategory = Category.food;
  
  bool get _isEditing => widget.transaction != null;
  
  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      // 填充现有交易数据
      _titleController.text = widget.transaction!.title;
      _amountController.text = widget.transaction!.amount.toString();
      _noteController.text = widget.transaction!.note ?? '';
      _selectedDate = widget.transaction!.date;
      _selectedType = widget.transaction!.type;
      _selectedCategory = widget.transaction!.category;
    }
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<TransactionProvider>(context, listen: false);
      
      final transaction = Transaction(
        id: _isEditing ? widget.transaction!.id : null,
        title: _titleController.text,
        amount: double.parse(_amountController.text),
        date: _selectedDate,
        type: _selectedType,
        category: _selectedCategory,
        note: _noteController.text.isEmpty ? null : _noteController.text,
      );
      
      if (_isEditing) {
        provider.updateTransaction(transaction);
      } else {
        provider.addTransaction(transaction);
      }
      
      Navigator.pop(context);
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? '编辑交易' : '添加交易',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [colorScheme.primary, colorScheme.primaryContainer],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 交易类型选择
              Text(
                '交易类型',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 12),
              SegmentedButton<TransactionType>(
                segments: const [
                  ButtonSegment(
                    value: TransactionType.expense,
                    label: Text('支出'),
                    icon: Icon(Icons.arrow_downward_rounded),
                  ),
                  ButtonSegment(
                    value: TransactionType.income,
                    label: Text('收入'),
                    icon: Icon(Icons.arrow_upward_rounded),
                  ),
                ],
                selected: {_selectedType},
                onSelectionChanged: (Set<TransactionType> selected) {
                  setState(() {
                    _selectedType = selected.first;
                    // 根据类型自动切换到合适的分类
                    if (_selectedType == TransactionType.income) {
                      _selectedCategory = Category.salary;
                    } else {
                      _selectedCategory = Category.food;
                    }
                  });
                },
                style: ButtonStyle(
                  side: MaterialStateProperty.resolveWith((states) {
                    if (states.contains(MaterialState.selected)) {
                      return BorderSide(
                        color: colorScheme.primary,
                        width: 2,
                      );
                    }
                    return BorderSide(color: Colors.grey[300]!);
                  }),
                ),
              ),
              const SizedBox(height: 20),
              
              // 标题
              Text(
                '标题',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: '输入交易标题',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入标题';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              
              // 金额
              Text(
                '金额',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(
                  hintText: '0.00',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                  prefixIcon: const Icon(Icons.attach_money),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入金额';
                  }
                  if (double.tryParse(value) == null) {
                    return '请输入有效的金额';
                  }
                  if (double.parse(value) <= 0) {
                    return '金额必须大于0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              
              // 日期选择
              Text(
                '日期',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: _selectDate,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey[50],
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, color: colorScheme.primary),
                      const SizedBox(width: 12),
                      Text(
                        DateFormat('yyyy-MM-dd').format(_selectedDate),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // 分类选择
              Text(
                '分类',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<Category>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                items: _getCategoryItems(),
                onChanged: (Category? value) {
                  if (value != null) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 20),
              
              // 备注
              Text(
                '备注 (可选)',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _noteController,
                decoration: InputDecoration(
                  hintText: '输入备注信息',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 32),
              
              // 提交按钮
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [colorScheme.primary, colorScheme.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _isEditing ? '保存修改' : '添加交易',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<DropdownMenuItem<Category>> _getCategoryItems() {
    final List<Category> categories = _selectedType == TransactionType.income
        ? [
            Category.salary,
            Category.gift,
            Category.other,
          ]
        : [
            Category.food,
            Category.transportation,
            Category.entertainment,
            Category.shopping,
            Category.utilities,
            Category.health,
            Category.education,
            Category.other,
          ];

    return categories.map((category) {
      return DropdownMenuItem<Category>(
        value: category,
        child: Row(
          children: [
            Icon(_getCategoryIcon(category)),
            const SizedBox(width: 8),
            Text(_getCategoryName(category)),
          ],
        ),
      );
    }).toList();
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