import 'package:flutter/material.dart';
import 'package:flutter_task/core/network/dio_client.dart';
import 'package:flutter_task/features/stock_chart/data/datasources/stock_remote_data_source.dart';
import 'package:flutter_task/features/stock_chart/data/repositories/stock_repository_impl.dart';
import 'package:flutter_task/features/stock_chart/domain/repositories/stock_repository.dart';
import 'package:provider/provider.dart';
import 'features/auth/presentation/pages/auth_page.dart';
import 'features/stock_chart/presentation/providers/stock_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<DioClient>(create: (_) => DioClient()),
        Provider<StockRemoteDataSource>(
          create: (context) => StockRemoteDataSource(
            dioClient: context.read<DioClient>(),
          ),
        ),
        Provider<StockRepository>(
          create: (context) => StockRepositoryImpl(
            context.read<StockRemoteDataSource>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => StockProvider(
            context.read<StockRepository>(),
          ),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Stock App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const AuthPage(),
      ),
    );
  }
}
