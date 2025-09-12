import 'package:dio/dio.dart';

class ApiService {
  final String _baseUrl = "https://api.pexels.com/videos";
  final String authKey = "WYwKAyze4260oRXKRTZXzF7mbLftN1JkVidiBjn999TOfSMbRF44Vduc";

  final Dio dio;

  ApiService(this.dio);

  /// POST Request

  Future<Map<String, dynamic>> post({
    required String endPoint,
    dynamic data,
    Map<String, dynamic>? headers,
  }) async {
    final response = await dio.post(
      "$_baseUrl$endPoint",
      data: data,
      options: Options(headers: headers),
    );
    return response.data;
  }

  /// GET Request
  Future<Map<String, dynamic>> get({
    required String endPoint,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    final response = await dio.get(
      "$_baseUrl$endPoint",
      queryParameters: queryParameters,
      options: Options(headers: headers),
    );
    return response.data;
  }

  /// PUT Request
  Future<Map<String, dynamic>> put({
    required String endPoint,
    dynamic data,
    Map<String, dynamic>? headers,
  }) async {
    final response = await dio.put(
      "$_baseUrl$endPoint",
      data: data,
      options: Options(headers: headers),
    );
    return response.data;
  }

  /// DELETE Request
  Future<Map<String, dynamic>> delete({
    required String endPoint,
    dynamic data,
    Map<String, dynamic>? headers,
  }) async {
    final response = await dio.delete(
      "$_baseUrl$endPoint",
      data: data,
      options: Options(headers: headers),
    );
    return response.data;
  }
}
