import 'app_exception.dart';

sealed class Result<T> {
  const Result._();

  factory Result.success(T data) = Success<T>;
  factory Result.failure(AppException exception) = Failure<T>;

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;

  T? get data => switch (this) {
    Success<T>(:final data) => data,
    Failure<T>() => null,
  };

  AppException? get exception => switch (this) {
    Success<T>() => null,
    Failure<T>(:final exception) => exception,
  };

  R when<R>({
    required R Function(T data) success,
    required R Function(AppException exception) failure,
  }) {
    return switch (this) {
      Success<T>(:final data) => success(data),
      Failure<T>(:final exception) => failure(exception),
    };
  }

  Result<R> map<R>(R Function(T data) transform) {
    return switch (this) {
      Success<T>(:final data) => Result.success(transform(data)),
      Failure<T>(:final exception) => Result.failure(exception),
    };
  }
}

class Success<T> extends Result<T> {
  const Success(this.data) : super._();
  @override
  final T data;
}

class Failure<T> extends Result<T> {
  const Failure(this.exception) : super._();
  @override
  final AppException exception;
}
