import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:quotes_daily/Utils/colors/AppColors.dart';
import 'package:quotes_daily/Utils/customSnackBar.dart';
import 'package:share_plus/share_plus.dart';
import '../../data/database/databaseHelper_favorite.dart';
class FavoriteSearch extends SearchDelegate<DBFavorite?> {
  FavoriteSearch();

  @override
  String? get searchFieldLabel => 'Search saved quotes';

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [if (query.isNotEmpty) IconButton(icon: const Icon(Icons.clear), onPressed: () => query = '')];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => close(context, null));
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildResultsOrSuggestions(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildResultsOrSuggestions(context);
  }

  Widget _buildResultsOrSuggestions(BuildContext context) {
    return FutureBuilder<List<DBFavorite>>(
      future: DBHelper.instance.getFavorites(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return Center(child: Lottie.asset("assets/animations/loadingTeddy.json",
              height: 200),);
        }
        final all = snap.data ?? [];
        final qLower = query.trim().toLowerCase();
        final results = qLower.isEmpty
            ? all
            : all.where((f) => f.text.toLowerCase().contains(qLower) || f.author.toLowerCase().contains(qLower)).toList();

        if (results.isEmpty) {
          return Center(child: Text('No results', style: Theme.of(context).textTheme.bodyLarge));
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
          itemCount: results.length,
          itemBuilder: (context, index) {
            final f = results[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                leading: CircleAvatar(
                  radius: 26,
                  backgroundColor: AppColors.appColor.withAlpha(180),
                  child: Text(f.author.isNotEmpty ? f.author[0].toUpperCase() : '?', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                ),
                title: Text(f.text, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(f.author, style: const TextStyle(fontStyle: FontStyle.italic)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(icon: const Icon(Icons.share_outlined), onPressed: () async {
                      await Share.share('"${f.text}" — ${f.author}', subject: 'Quote to share');
                    }),
                    IconButton(icon: const Icon(Icons.delete_outline), onPressed: () async {
                      if (f.id != null) {
                        await DBHelper.instance.deleteFavoriteById(f.id!);
                        await Future.delayed(const Duration(milliseconds: 80));
                        query = query;
                        showSuggestions(context);
                        CustomSnackBar.show(context, "Deleted", Icons.check, Colors.deepPurple);
                      }
                    }),
                  ],
                ),
                onTap: () {
                  close(context, f);
                },
              ),
            );
          },
        );
      },
    );
  }
}
