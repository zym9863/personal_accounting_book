# Personal Accounting Book

中文 | [English](README_EN.md)

一个使用Flutter开发的个人记账应用，帮助用户轻松管理日常收支，并提供数据统计分析功能。

## 主要功能

- 交易记录管理：添加、编辑和删除收支记录
- 数据统计分析：通过图表直观展示收支情况
- 交易列表展示：支持滑动操作的交易记录列表

## 技术栈

- **Flutter**：跨平台UI框架
- **Provider**：状态管理
- **SQLite**：本地数据存储
  - sqflite
  - sqflite_common_ffi
  - path_provider
- **FL Chart**：数据可视化图表
- **Flutter Slidable**：滑动操作UI组件

## 项目结构

```
lib/
├── models/          # 数据模型
├── providers/       # 状态管理
├── screens/         # 页面UI
├── services/        # 数据服务
└── theme/          # 主题配置
```

## 开发环境

- Flutter SDK: ^3.7.0
- Dart SDK: ^3.7.0

## 开始使用

1. 确保已安装Flutter开发环境
2. 克隆项目到本地
3. 运行以下命令安装依赖：
   ```
   flutter pub get
   ```
4. 运行应用：
   ```
   flutter run
   ```
