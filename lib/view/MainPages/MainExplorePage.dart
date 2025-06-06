import 'package:flutter/material.dart';
import 'package:quotes_daily/data/response/status.dart';
import '../../ViewModel/quotes_view_model.dart';
import 'package:provider/provider.dart';
import '../../model/quotes_model.dart';

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
    super.build(context); // Ensures that the mixin works correctly

    final viewModel = Provider.of<QuotesViewViewModel>(context); // Access the ViewModel
    final status = viewModel.quotesList.status;

    if (status == Status.LOADING) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else if (status == Status.ERROR) {
      return Center(
        child: Text(
          viewModel.quotesList.message ?? 'An error occurred',
          style: const TextStyle(color: Colors.red),
        ),
      );
    } else if (status == Status.COMPLETED) {
      final quotes = viewModel.quotesList.data ?? [];
      return ListView.builder(
        itemCount: quotes.length,
        itemBuilder: (context, index) {
          final QuotesModel quote = quotes[index];
          return QuoteCard(quote: quote);
        },
      );
    } else {
      return const Center(
        child: Text("Unexpected State"),
      );
    }
  }

  @override
  bool get wantKeepAlive => true; // Enable state persistence
}

class QuoteCard extends StatelessWidget {
  final QuotesModel quote;

  const QuoteCard({required this.quote, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: ListTile(
        title: Text(
          quote.q ?? "No Quote Available",
          style: const TextStyle(fontSize: 16.0),
        ),
        subtitle: Text(
          quote.a ?? "Unknown Author",
          style: const TextStyle(
            fontStyle: FontStyle.italic,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }
}
