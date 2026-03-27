import 'package:equatable/equatable.dart';

sealed class Failure extends Equatable {
  const Failure(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  List<Object?> get props => [message, statusCode];
}

final class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.statusCode});
}

final class NetworkFailure extends Failure {
  const NetworkFailure(super.message, {super.statusCode});
}

final class CacheFailure extends Failure {
  const CacheFailure(super.message, {super.statusCode});
}

final class AuthFailure extends Failure {
  const AuthFailure(super.message, {super.statusCode});
}

final class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message, {super.statusCode});
}
