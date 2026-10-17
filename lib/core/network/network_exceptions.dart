import 'package:dio/dio.dart';

class NetworkException implements Exception {
  final String message;
  final int? statusCode;

  const NetworkException({required this.message, this.statusCode});

  factory NetworkException.fromDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkException(
          message: 'Connection timed out. Please check your internet connection.',
        );
      case DioExceptionType.badResponse:
        final code = error.response?.statusCode;
        if (code == 400) {
          return const NetworkException(
            message: 'Invalid request or invalid API key. Please verify your Pixabay key in settings.',
            statusCode: 400,
          );
        } else if (code == 429) {
          return const NetworkException(
            message: 'Pixabay rate limit reached (100 req/min). Please try again shortly.',
            statusCode: 429,
          );
        } else if (code != null && code >= 500) {
          return const NetworkException(
            message: 'Pixabay server error. Please try again later.',
            statusCode: 500,
          );
        }
        return NetworkException(
          message: 'Server returned error ($code). Please try again.',
          statusCode: code,
        );
      case DioExceptionType.connectionError:
        return const NetworkException(
          message: 'No internet connection detected. Please verify your network.',
        );
      case DioExceptionType.cancel:
        return const NetworkException(message: 'Request was cancelled.');
      default:
        return const NetworkException(
          message: 'An unexpected network error occurred.',
        );
    }
  }

  @override
  String toString() => message;
}
