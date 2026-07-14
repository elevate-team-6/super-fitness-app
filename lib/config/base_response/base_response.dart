sealed class BaseResponse<T> {
  const BaseResponse();
}

class SuccessBaseResponse<T> extends BaseResponse<T> {
  final T? data;
  const SuccessBaseResponse(this.data);
}

class ErrorBaseResponse<T> extends BaseResponse<T> {
  final String errorMessage;
  const ErrorBaseResponse(this.errorMessage);
}
