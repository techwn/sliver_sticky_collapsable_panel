import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'infinite_grouped_list/infinite_grouped_list.dart';

enum TransactionType { transport, food, shopping, entertainment, health, other }

class Transaction {
  final String name;
  final DateTime dateTime;
  final double amount;
  final TransactionType type;

  Transaction({required this.name, required this.dateTime, required this.amount, required this.type});

  @override
  String toString() {
    return '{name: $name, dateTime: $dateTime}';
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MyHomePage(title: 'Sliver Sticky collapsable Panel'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool dontThrowError = false;

  DateTime baseDate = DateTime.now();

  var index = 0;

  Future<List<Transaction>> onLoadMore(int offset) async {
    await Future.delayed(const Duration(milliseconds: 1000));

    if (index++ == 2) {
      throw 'error in load more';
    }
    return List<Transaction>.generate(29, (index) {
      final tempDate = baseDate;
      baseDate = baseDate.subtract(const Duration(hours: 28));
      return Transaction(
        name: 'Transaction num #$index',
        dateTime: tempDate,
        amount: Random().nextDouble() * 1000,
        type: TransactionType.values[Random().nextInt(6)],
      );
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(title: Text(widget.title)),
      body: InfiniteGroupedList<Transaction, DateTime, String>(
        groupBy: (item) => item.dateTime,
        sortGroupBy: (item) => item.dateTime,
        groupTitleBuilder: (index, title, groupBy, isPinned, isExpanded, scrollPercentage) {
          return Container(
            width: double.infinity,
            height: 50,
            color: Colors.blueGrey,
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(start: 16),
                    child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                if (index % 2 == 0)
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsetsDirectional.only(end: 16),
                      child: AnimatedRotation(
                        duration: const Duration(milliseconds: 0),
                        turns: isExpanded ? 0 : 0.5,
                        child: const Icon(Icons.expand_more),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
        itemBuilder: (groups, title, index) {
          final item = groups[title]![index];
          return SizedBox(
            height: 100,
            child: ListTile(
              onTap: () {
                if (kDebugMode) {
                  print('tap on item: name = ${item.name} date = ${item.dateTime}');
                }
              },
              title: Text(item.name),
              leading: item.type == TransactionType.transport
                  ? const Icon(Icons.directions_bus)
                  : item.type == TransactionType.food
                  ? const Icon(Icons.fastfood)
                  : item.type == TransactionType.shopping
                  ? const Icon(Icons.shopping_bag)
                  : item.type == TransactionType.entertainment
                  ? const Icon(Icons.movie)
                  : item.type == TransactionType.health
                  ? const Icon(Icons.medical_services)
                  : const Icon(Icons.money),
              trailing: Text(
                '${item.amount.toStringAsFixed(2)}€',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(item.dateTime.toIso8601String()),
            ),
          );
        },
        onLoadMore: (info) => onLoadMore(info.offset),
        groupCreator: (dateTime) {
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);
          final yesterday = today.subtract(const Duration(days: 1));
          final lastWeek = today.subtract(const Duration(days: 7));
          final lastMonth = DateTime(today.year, today.month - 1, today.day);

          if (today.day == dateTime.day && today.month == dateTime.month && today.year == dateTime.year) {
            return 'Today';
          } else if (yesterday.day == dateTime.day &&
              yesterday.month == dateTime.month &&
              yesterday.year == dateTime.year) {
            return 'Yesterday';
          } else if (lastWeek.isBefore(dateTime) && dateTime.isBefore(yesterday)) {
            return 'Last Week';
          } else if (lastMonth.isBefore(dateTime) && dateTime.isBefore(lastWeek)) {
            return 'Last Month';
          } else {
            // Convert the DateTime to a string for grouping
            return '${dateTime.year}-${dateTime.month}-${dateTime.day}';
          }
        },
      ),
    );
  }
}
