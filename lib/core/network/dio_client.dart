import 'package:dio/dio.dart';

class DioClient {
  final Dio _dio = Dio();

  DioClient() {
    _dio.options = BaseOptions(
      baseUrl: 'https://query2.finance.yahoo.com',
      responseType: ResponseType.json,
    );
  }

  Future<Response> get(String url, {Map<String, dynamic>? queryParameters}) async {
    return await _dio.get(
      url,
      queryParameters: queryParameters,
      options: Options(responseType: ResponseType.json),
    );
  }
}
