import 'dart:convert';
import 'dart:io';

import 'package:quotes_daily/data/app_exceptions.dart';
import 'package:quotes_daily/data/network/BaseApiServices.dart';
import 'package:http/http.dart' as http;

class NetworkApiServices extends BaseApiServices{
  @override
  Future getApiResponse(String url) async {

    dynamic responseJson;
   try{
     final response= await http.get(Uri.parse(url)).timeout(Duration(seconds: 10));
     responseJson = returnResponse(response);

   }on SocketException{
     FetchDataException("No internet connection");
   }

return responseJson;
  }

  dynamic returnResponse(http.Response response){
    switch(response.statusCode){
      case 200:
        dynamic responseJson= jsonDecode(response.body);
        return responseJson;
      case 400:
        BadRequestException(response.body.toString());
      case 404:
        UnauthorisedException(response.body.toString());
      default:
        throw FetchDataException("Error occurred while communicating to server with status code${response.statusCode}");

    }

  }

}