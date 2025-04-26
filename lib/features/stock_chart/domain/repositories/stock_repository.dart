import 'package:dartz/dartz.dart';
import 'package:flutter_task/core/error/failures.dart';
import 'package:flutter_task/features/stock_chart/domain/entities/stock.dart';

abstract class StockRepository {
  Future<Either<Failure, List<Stock>>> getStockData({
    required DateTime from,
    required DateTime to,
    required String interval,
  });
}
