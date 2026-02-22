// ignore_for_file: file_names

class ApiException implements Exception {
  final String message;
  final num? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => ' $message';
}
