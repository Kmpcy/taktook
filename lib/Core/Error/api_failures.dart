import 'package:dio/dio.dart';

abstract class Failures {
  final String errorMessage;

  const Failures(this.errorMessage);
}

class ServerFailure extends Failures {
  ServerFailure(super.errorMessage);

  factory ServerFailure.fromDioException(DioException dioException) {
    switch (dioException.type) {
      case DioExceptionType.connectionTimeout:
        return ServerFailure("Connection timeout with API server.");
      case DioExceptionType.sendTimeout:
        return ServerFailure("Send timeout with API server.");
      case DioExceptionType.receiveTimeout:
        return ServerFailure("Receive timeout from API server.");
      case DioExceptionType.badResponse:
        if (dioException.response != null &&
            dioException.response!.statusCode != null) {
          return ServerFailure.fromResponse(
            dioException.response!.statusCode!,
            dioException.response!.data,
          );
        } else {
          return ServerFailure("Received an invalid response from the server.");
        }
      case DioExceptionType.cancel:
        return ServerFailure("Request to API server was cancelled.");
      case DioExceptionType.connectionError:
        return ServerFailure(
          "No Internet Connection. Please check your network.",
        );
      case DioExceptionType.unknown:
        return ServerFailure("An unexpected error occurred. Please try again.");
      default:
        return ServerFailure("Oops, something went wrong. Please try again.");
    }
  }

  factory ServerFailure.fromResponse(int statusCode, dynamic response) {
    String extractErrorMessage(dynamic resp) {
      if (resp == null || resp is! Map) {
        return 'The server returned an unexpected response.';
      }

      if (resp.containsKey('error') && resp['error'] is Map) {
        return resp['error']['message']?.toString() ?? 'An error occurred.';
      }

      if (resp.containsKey('errors') && resp['errors'] is Map) {
        try {
          final errorsMap = resp['errors'] as Map;
          final firstErrorList = errorsMap.values.first as List;
          return firstErrorList.first?.toString() ?? 'Validation error.';
        } catch (_) {
          return 'A validation error occurred.';
        }
      }

      return 'An unknown server error occurred.';
    }

    switch (statusCode) {
      case 400: // Bad Request
      case 401: // Unauthorized (e.g., wrong password)
      case 403: // Forbidden (e.g., no permission)
      case 422: // Unprocessable Entity (Validation failed)
        return ServerFailure(extractErrorMessage(response));

      case 404:
        return ServerFailure("The requested resource was not found.");

      case 500:
      case 502:
      case 503:
        return ServerFailure(
          "The server is currently unavailable. Please try again later.",
        );

      default:
        return ServerFailure(
          "An unexpected error occurred. Status code: $statusCode",
        );
    }
  }
}
