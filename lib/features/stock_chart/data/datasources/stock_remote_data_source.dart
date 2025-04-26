import 'package:dartz/dartz.dart';
import 'package:flutter_task/core/utils/api_constants.dart';
import 'package:flutter_task/features/stock_chart/data/models/quote_model.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/utils/date_converter.dart';
import '../models/stock_model.dart';

class StockRemoteDataSource {
  final DioClient dioClient;

  StockRemoteDataSource({required this.dioClient});

  Future<Either<Failure, List<StockModel>>> getStockData({
    required DateTime from,
    required DateTime to,
    required String interval,
  }) async {
    try {
      final fromTimestamp = DateConverter.toTimestamp(from);
      final toTimestamp = DateConverter.toTimestamp(to);

      final response = await dioClient.get(
        ApiConstants.stockChartEndpoint,
        queryParameters: {
          "period1": fromTimestamp,
          "period2": toTimestamp,
          "interval": interval,
          "events": "history",
        },
      );

      final chart = response.data['chart'];
      if (chart == null) {
        return Left(Failure('Chart data not found.'));
      }

      final result = (chart['result'] as List?)?.first;
      if (result == null) {
        return Left(Failure('Result data is missing.'));
      }

      final timestamps = _parseTimestamps(result['timestamp']);
      final quotes = _parseQuotes(result['indicators']?['quote']);

      if (timestamps.isEmpty || quotes == null) {
        return Left(Failure('Incomplete stock data.'));
      }

      final stocks = _mapToStockModels(timestamps, quotes);

      return Right(stocks);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  List<int> _parseTimestamps(dynamic timestampsJson) {
    if (timestampsJson is List) {
      return timestampsJson.map((e) => int.tryParse(e.toString()) ?? 0).toList();
    }
    return [];
  }

  Quotes? _parseQuotes(dynamic quotesJson) {
    if (quotesJson is List && quotesJson.isNotEmpty) {
      final quote = quotesJson.first;
      return Quotes(
        opens: List<num>.from(quote['open'] ?? []),
        highs: List<num>.from(quote['high'] ?? []),
        lows: List<num>.from(quote['low'] ?? []),
        closes: List<num>.from(quote['close'] ?? []),
        volumes: List<num>.from(quote['volume'] ?? []),
      );
    }
    return null;
  }

  List<StockModel> _mapToStockModels(List<int> timestamps, Quotes quotes) {
    final List<StockModel> stocks = [];

    for (int i = 0; i < timestamps.length; i++) {
      if (i < quotes.opens.length &&
          i < quotes.highs.length &&
          i < quotes.lows.length &&
          i < quotes.closes.length &&
          i < quotes.volumes.length) {
        stocks.add(
          StockModel(
            date: DateTime.fromMillisecondsSinceEpoch(timestamps[i] * 1000),
            open: quotes.opens[i].toDouble(),
            high: quotes.highs[i].toDouble(),
            low: quotes.lows[i].toDouble(),
            close: quotes.closes[i].toDouble(),
            volume: quotes.volumes[i].toInt(),
          ),
        );
      }
    }

    return stocks;
  }
}
