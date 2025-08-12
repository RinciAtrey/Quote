import 'package:flutter/material.dart';
import 'package:quotes_daily/Utils/colors/AppColors.dart';
import 'package:quotes_daily/data/response/status.dart';
import 'package:quotes_daily/view/ExplorePages/card_design.dart';
import '../../ViewModel/quotes_view_model.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../data/database/databaseHelper_favorite.dart';

class MainExplorePage extends StatelessWidget {
  const MainExplorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<QuotesViewViewModel>(
      create: (_) {
        final viewModel = QuotesViewViewModel();
        viewModel.fetchQuotesVM();
        return viewModel;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Quotes Explorer'),
        ),
        body: const QuotesListView(),
      ),
    );
  }
}

class QuotesListView extends StatefulWidget {
  const QuotesListView({super.key});

  @override
  State<QuotesListView> createState() => _QuotesListViewState();
}

class _QuotesListViewState extends State<QuotesListView>
    with AutomaticKeepAliveClientMixin<QuotesListView> {
  @override
  Widget build(BuildContext context) {
    super.build(context);

    final viewModel = Provider.of<QuotesViewViewModel>(context);
    final status = viewModel.quotesList.status;

    if (status == Status.LOADING) {
      return const Center(child: CircularProgressIndicator());
    } else if (status == Status.ERROR) {
      return const Center(child: CircularProgressIndicator());
    } else if (status == Status.COMPLETED) {
      final quotes = viewModel.quotesList.data!;
      final cards = quotes.asMap().entries.map((entry) {
        final quote = entry.value;
        return Container(
          alignment: Alignment.center,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.appColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                quote.q ?? 'No quote',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                '- ${quote.a ?? "Unknown"}',
                style: const TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 46),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.share, color: Colors.white),
                    onPressed: () {
                      Share.share(
                        '"${quote.q}" — ${quote.a}',
                        subject: 'Quote to share',
                      );
                    },
                  ),
                  const SizedBox(width: 55),
                  IconButton(
                    icon: Icon(
                      quote.isFavorite
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: Colors.white,
                    ),
                      onPressed: () async {
                        setState(() {
                          quote.isFavorite = !quote.isFavorite;
                        });
                        if (quote.isFavorite) {
                          await DBHelper.instance.insertFavorite(DBFavorite(text: quote.q ?? '', author: quote.a ?? 'Unknown'));
                        } else {
                          await DBHelper.instance.deleteFavoriteByTextAuthor(quote.q ?? '', quote.a ?? 'Unknown');
                        }
                      }
                    ),
                ],
              ),
            ],
          ),
        );
      }).toList();

      return CardDesign(cards: cards, quoteList: quotes);
    } else {
      return const Center(child: CircularProgressIndicator());
    }
  }

  @override
  bool get wantKeepAlive => true;
}
