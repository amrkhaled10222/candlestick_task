import 'package:flutter/material.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_task/features/stock_chart/domain/repositories/stock_repository.dart';
import 'package:flutter_task/features/stock_chart/domain/entities/stock.dart';
import 'package:flutter_task/core/error/failures.dart';

class StockProvider extends ChangeNotifier {
  final StockRepository _repository;

  String interval = '1d';
  bool isLoading = false;
  List<Stock> stockData = [];

  DateTime fromDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime toDate = DateTime.now();

  StockProvider(this._repository) {
    _fetchStockData();
  }

  void setInterval(String newInterval) {
    interval = newInterval;
    _fetchStockData();
  }

  void setDateRange(DateTime from, DateTime to) {
    fromDate = from;
    toDate = to;
    _fetchStockData();
  }

  Future<void> _fetchStockData() async {
    isLoading = true;
    notifyListeners();

    final Either<Failure, List<Stock>> result = await _repository.getStockData(
      from: fromDate,
      to: toDate,
      interval: interval,
    );

    result.fold(
      (failure) {
        stockData = [];
      },
      (data) {
        stockData = data;
      },
    );

    isLoading = false;
    notifyListeners();
  }
}
