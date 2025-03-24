import 'package:quotes_daily/data/response/status.dart';

class ApiResponse<T>{

  Status? status;
  T? data;
  String? message;

  ApiResponse(this.status, this.data, this.message);

  ApiResponse.loading(): status= Status.LOADING;  //named constructor
  ApiResponse.completed(this.data): status= Status.COMPLETED;
  ApiResponse.error(this.message): status= Status.ERROR;

  @override
  String toString() {
    return "Status: $status, Message: $message, Data: $data";
  }

}