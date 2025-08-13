abstract class ApiState<T> {
  const ApiState();
}

class ApiLoading<T> extends ApiState<T> {
  const ApiLoading();
}

class ApiData<T> extends ApiState<T> {
  const ApiData(this.value);
  final T value;
}

class ApiError<T> extends ApiState<T> {
  const ApiError(this.message);
  final String message;
}