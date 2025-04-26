import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';

import '../datasources/stock_remote_data_source.dart';
import '../../domain/entities/stock.dart';
import '../../domain/repositories/stock_repository.dart';

class StockRepositoryImpl implements StockRepository {
  final StockRemoteDataSource _dataSource;

  StockRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, List<Stock>>> getStockData({
    required DateTime from,
    required DateTime to,
    required String interval,
  }) async {
    final result = await _dataSource.getStockData(
      from: from,
      to: to,
      interval: interval,
    );

    return result.fold(
        (failure) => Left(failure),
        (data) => Right(data
            .map((e) => Stock(
                  date: e.date,
                  open: e.open,
                  high: e.high,
                  low: e.low,
                  close: e.close,
                  volume: e.volume,
                ))
            .toList()));
  }
}
