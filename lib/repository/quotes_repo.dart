import 'package:quotes_daily/data/network/BaseApiServices.dart';
import 'package:quotes_daily/data/network/NetworkApiServices.dart';
import 'package:quotes_daily/model/quotes_model.dart';
import 'package:quotes_daily/res/app_url.dart';

class QuotesRepo {
  BaseApiServices _apiServices = NetworkApiServices();

  Future<List<QuotesModel>> fetchQuotesRepo() async {
    try {
      dynamic response = await _apiServices.getApiResponse(AppUrl.quoteEndpoint);
      return (response as List<dynamic>)
          .map((json) => QuotesModel.fromJson(json))
          .toList();
    } catch (e) {
      print("API Error: $e");
      throw e;
    }
  }
}
