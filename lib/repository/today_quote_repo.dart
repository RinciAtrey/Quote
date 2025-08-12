import 'package:quotes_daily/data/network/NetworkApiServices.dart';
import 'package:quotes_daily/model/today_quote_model.dart';
import '../data/network/BaseApiServices.dart';
import '../res/app_url.dart';

class TodayQuotesRepo{

  BaseApiServices _apiServices= NetworkApiServices();

  Future<List<TodayQuotesModel>> fetchTodayQuotesRepo() async{
    try{
      dynamic response= await _apiServices.getApiResponse(AppUrl.todayEndpoint);
      return (response as List<dynamic>)
          .map((json) => TodayQuotesModel.fromJson(json))
          .toList();
    }
    catch (e) {
      print("API Error: $e");
      throw e;
    }
  }
}
