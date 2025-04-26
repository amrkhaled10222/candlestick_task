import '../../domain/entities/stock.dart';

class StockModel extends Stock {
  StockModel({
    required super.date,
    required super.open,
    required super.high,
    required super.low,
    required super.close,
    required super.volume,
  });
}
