# Personal Accounting Book

[中文](README.md) | English

A personal accounting application developed with Flutter, helping users easily manage daily income and expenses while providing data statistics and analysis features.

## Key Features

- Transaction Management: Add, edit, and delete income/expense records
- Data Analytics: Visualize financial data through intuitive charts
- Transaction List: Transaction records list with swipe actions

## Tech Stack

- **Flutter**: Cross-platform UI framework
- **Provider**: State management
- **SQLite**: Local data storage
  - sqflite
  - sqflite_common_ffi
  - path_provider
- **FL Chart**: Data visualization charts
- **Flutter Slidable**: Swipe action UI component

## Project Structure

```
lib/
├── models/          # Data models
├── providers/       # State management
├── screens/         # Page UI
├── services/        # Data services
└── theme/          # Theme configuration
```

## Development Environment

- Flutter SDK: ^3.7.0
- Dart SDK: ^3.7.0

## Getting Started

1. Ensure Flutter development environment is installed
2. Clone the project locally
3. Run the following command to install dependencies:
   ```
   flutter pub get
   ```
4. Run the application:
   ```
   flutter run
   ```