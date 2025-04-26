import 'package:flutter/material.dart';
import 'package:flutter_task/features/stock_chart/domain/entities/stock.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../providers/stock_provider.dart';

class StockChartPage extends StatelessWidget {
  const StockChartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<StockProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock Candlestick Chart'),
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              DropdownButton<String>(
                value: provider.interval,
                items: const [
                  DropdownMenuItem(value: '1d', child: Text('Daily')),
                  DropdownMenuItem(value: '1wk', child: Text('Weekly')),
                  DropdownMenuItem(value: '1mo', child: Text('Monthly')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    provider.setInterval(value);
                  }
                },
              ),
              ElevatedButton(
                onPressed: () async {
                  final picked = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    provider.setDateRange(picked.start, picked.end);
                  }
                },
                child: const Text('Select Date Range'),
              ),
            ],
          ),
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : provider.stockData.isEmpty
                    ? const Center(child: Text('No Data Available'))
                    : SfCartesianChart(
                        primaryXAxis: const DateTimeAxis(),
                        primaryYAxis: const NumericAxis(),
                        series: <CartesianSeries<Stock, DateTime>>[
                          CandleSeries<Stock, DateTime>(
                            dataSource: provider.stockData
                                .where((stock) =>
                                    stock.open.isFinite &&
                                    stock.high.isFinite &&
                                    stock.low.isFinite &&
                                    stock.close.isFinite &&
                                    stock.volume.isFinite)
                                .map((stock) {
                              return Stock(
                                date: stock.date,
                                open: stock.open,
                                high: stock.high,
                                low: stock.low,
                                close: stock.close,
                                volume: stock.volume,
                              );
                            }).toList(),
                            xValueMapper: (Stock stock, _) => stock.date,
                            highValueMapper: (Stock stock, _) => stock.high,
                            lowValueMapper: (Stock stock, _) => stock.low,
                            openValueMapper: (Stock stock, _) => stock.open,
                            closeValueMapper: (Stock stock, _) => stock.close,
                          ),
                        ],
                      ),
          )
        ],
      ),
    );
  }
}
