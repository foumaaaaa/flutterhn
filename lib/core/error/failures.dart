// core/error/failures.dart
abstract class Failure {
  final String message;

  const Failure({required this.message});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Failure && other.message == message;
  }

  @override
  int get hashCode => message.hashCode;
}

class ServerFailure extends Failure {
  final int? statusCode;

  const ServerFailure({required super.message, this.statusCode});

  @override
  String toString() => 'ServerFailure: $message (Status: $statusCode)';
}

class CacheFailure extends Failure {
  const CacheFailure({required super.message});

  @override
  String toString() => 'CacheFailure: $message';
}

class NetworkFailure extends Failure {
  const NetworkFailure({required super.message});

  @override
  String toString() => 'NetworkFailure: $message';
}

class DatabaseFailure extends Failure {
  const DatabaseFailure({required super.message});

  @override
  String toString() => 'DatabaseFailure: $message';
}

class ValidationFailure extends Failure {
  final Map<String, String>? errors;

  const ValidationFailure({required super.message, this.errors});

  @override
  String toString() => 'ValidationFailure: $message';
}
