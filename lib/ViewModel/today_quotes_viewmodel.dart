import 'package:flutter/cupertino.dart';
import 'package:quotes_daily/data/response/api_response.dart';
import 'package:quotes_daily/model/today_quote_model.dart';
import 'package:quotes_daily/repository/today_quote_repo.dart';


class TodayQuotesViewViewModel with ChangeNotifier{
  final _myRepo= TodayQuotesRepo();

  ApiResponse<List<TodayQuotesModel>> quotesList = ApiResponse.loading();

  setQuotesList(ApiResponse<List<TodayQuotesModel>> response){
    quotesList=response;
    notifyListeners();

  }
  Future<void> fetchRandomQuotesVM() async{
    setQuotesList(ApiResponse.loading());
    _myRepo.fetchTodayQuotesRepo().then((value){
      setQuotesList(ApiResponse.completed(value));
    }).onError((error, stackTrace) {
      print("Error fetching quotes : $error");
      setQuotesList(ApiResponse.error(error.toString()));
    });
  }
}