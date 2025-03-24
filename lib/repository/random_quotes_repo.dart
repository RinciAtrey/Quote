import 'package:quotes_daily/data/network/NetworkApiServices.dart';

import '../data/network/BaseApiServices.dart';
import '../model/random_quotes_model.dart';
import '../res/app_url.dart';

class RandomQuotesRepo{

  BaseApiServices _apiServices= NetworkApiServices();

  Future<List<QuotesRandomModel>> fetchRandomQuotesRepo() async{
    try{
      dynamic response= await _apiServices.getApiResponse(AppUrl.randomEndpoint);
      return (response as List<dynamic>)
        .map((json) => QuotesRandomModel.fromJson(json))
        .toList();
  }
  catch (e) {
  print("API Error: $e");
  throw e;
}
}
}
