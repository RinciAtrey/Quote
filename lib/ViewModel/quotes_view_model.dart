import 'package:flutter/cupertino.dart';
import 'package:quotes_daily/data/response/api_response.dart';

import '../model/quotes_model.dart';
import '../repository/quotes_repo.dart';

class QuotesViewViewModel with ChangeNotifier{
  final _myRepo= QuotesRepo();

  //ApiResponse<QuotesModel> quotesList= ApiResponse.loading();
  ApiResponse<List<QuotesModel>> quotesList = ApiResponse.loading();

  setQuotesList(ApiResponse<List<QuotesModel>> response){
    quotesList=response;
    print('setquotes: $quotesList');
    notifyListeners();

  }
  Future<void> fetchQuotesVM() async{
    setQuotesList(ApiResponse.loading());
    _myRepo.fetchQuotesRepo().then((value){
      print("QuotesViewViewModel: $value");
      setQuotesList(ApiResponse.completed(value));
    }).onError((error, stackTrace) {
      print("Error fetching quotes : $error");
      setQuotesList(ApiResponse.error(error.toString()));
    });
  }
}