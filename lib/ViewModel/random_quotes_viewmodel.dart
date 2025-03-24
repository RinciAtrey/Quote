import 'package:flutter/cupertino.dart';
import 'package:quotes_daily/data/response/api_response.dart';
import 'package:quotes_daily/model/random_quotes_model.dart';
import 'package:quotes_daily/repository/random_quotes_repo.dart';


class RandomQuotesViewViewModel with ChangeNotifier{
  final _myRepo= RandomQuotesRepo();

  //ApiResponse<QuotesModel> quotesList= ApiResponse.loading();
  ApiResponse<List<QuotesRandomModel>> quotesList = ApiResponse.loading();

  setQuotesList(ApiResponse<List<QuotesRandomModel>> response){
    quotesList=response;
    print('setquotes: $quotesList');
    notifyListeners();

  }
  Future<void> fetchRandomQuotesVM() async{
    setQuotesList(ApiResponse.loading());
    _myRepo.fetchRandomQuotesRepo().then((value){
      print("RandomQuotesViewViewModel: $value");
      setQuotesList(ApiResponse.completed(value));
    }).onError((error, stackTrace) {
      print("Error fetching quotes : $error");
      setQuotesList(ApiResponse.error(error.toString()));
    });
  }
}