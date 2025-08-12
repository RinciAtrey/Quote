import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../Utils/colors/AppColors.dart';
import 'package:quotes_daily/data/response/status.dart';
import '../../ViewModel/today_quotes_viewmodel.dart';
import '../../data/database/databaseHelper_favorite.dart';
import '../HomepagePages/FavoriteSearch.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  final TodayQuotesViewViewModel _todayVM = TodayQuotesViewViewModel();
  List<DBFavorite> savedQuotes = [];
  bool loadingFavorites = true;
  StreamSubscription<void>? _favSub;

  @override
  void initState() {
    super.initState();
    _todayVM.fetchRandomQuotesVM();
    _loadSavedFavorites();

    try {
      _favSub = DBHelper.instance.favoritesStream.listen((_) {
        if (mounted) _loadSavedFavorites();
      });
    } catch (e) {
    }
  }

  Future<void> _loadSavedFavorites() async {
    setState(() => loadingFavorites = true);
    final favs = await DBHelper.instance.getFavorites();
    if (!mounted) return;
    setState(() {
      savedQuotes = favs;
      loadingFavorites = false;
    });
  }

  @override
  void dispose() {
    _favSub?.cancel();
    _todayVM.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  void _showSnack(String text) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text), duration: const Duration(milliseconds: 800)));
  }

  Future<void> _deleteFavorite(int id) async {
    await DBHelper.instance.deleteFavoriteById(id);
    _showSnack("Deleted");
  }

  Future<void> _shareFavorite(DBFavorite q) async {
    await Share.share('"${q.text}" — ${q.author}', subject: 'Quote to share');
    _showSnack("Shared");
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.appColor,
        foregroundColor: Colors.white,
        title: Padding(
          padding: const EdgeInsets.all(8.0),
          child: const Text('Quotes', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch<DBFavorite?>(
                context: context,
                delegate: FavoriteSearch(),
              ).then((picked) {
                if (picked != null) {
                  _shareFavorite(picked);
                }
              });
            },
            tooltip: "Search favorite quotes",
          ),
        ],
      ),
      backgroundColor: const Color(0xFFF6F7FB),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
          child: Column(
            children: [
              ChangeNotifierProvider<TodayQuotesViewViewModel>.value(
                value: _todayVM,
                child: Consumer<TodayQuotesViewViewModel>(
                  builder: (context, vm, _) {
                    String displayText = "The only limit to our realization of tomorrow is our doubts of today.";
                    String displayAuthor = "Franklin D. Roosevelt";

                    final status = vm.quotesList.status;
                    if (status == Status.COMPLETED) {
                      final List? data = vm.quotesList.data;
                      if (data != null && data.isNotEmpty) {
                        final today = data.first;
                        if (today.q != null && today.q!.isNotEmpty) displayText = today.q!;
                        if (today.a != null && today.a!.isNotEmpty) displayAuthor = today.a!;
                      }
                    }

                    return Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF8EC5FF), Color(0xFFE0C3FC)]),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 6))],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(18),
                          child: Padding(
                            padding: const EdgeInsets.all(18.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(right: 12.0, top: 6),
                                  child: Icon(Icons.format_quote, size: 42, color: Colors.white70),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("Quote of the Day", style: theme.textTheme.labelLarge?.copyWith(color: Colors.white70, fontWeight: FontWeight.w600)),
                                      const SizedBox(height: 6),
                                      if (vm.quotesList.status == Status.LOADING)
                                        Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                                          child: Row(
                                            children: const [
                                              SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2.0, valueColor: AlwaysStoppedAnimation<Color>(Colors.white))),
                                              SizedBox(width: 12),
                                              Text("Loading today's quote...", style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)),
                                            ],
                                          ),
                                        )
                                      else
                                        Text(displayText, style: theme.textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
                                      const SizedBox(height: 12),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text("- $displayAuthor", style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70, fontStyle: FontStyle.italic)),
                                          Row(
                                            children: [
                                              IconButton(onPressed: ()   async {
                                                await Share.share('"${displayText}" — ${displayAuthor}', subject: 'Quote to share');
                                              }, icon: const Icon(Icons.ios_share), color: Colors.white, tooltip: "Share"),
                                            ],
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 18),

              // Saved header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Your Favorite Quotes', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                  Text('${savedQuotes.length} items', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[700])),
                ],
              ),

              const SizedBox(height: 10),

              // saved list
              Expanded(
                child: loadingFavorites
                    ? const Center(child: CircularProgressIndicator())
                    : (savedQuotes.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.bookmark_outline, size: 56, color: Colors.grey[400]),
                      const SizedBox(height: 12),
                      Text("No fav quotes", style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey[600])),
                      const SizedBox(height: 8),
                    ],
                  ),
                )
                    : ListView.builder(
                  itemCount: savedQuotes.length,
                  itemBuilder: (context, index) {
                    final q = savedQuotes[index];
                    return Dismissible(
                      key: ValueKey(q.id ?? '${q.text}-$index'),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.delete_outline, color: Colors.white),
                      ),
                      onDismissed: (_) async {
                        if (q.id != null) {
                          await _deleteFavorite(q.id!);
                        } else {
                          await DBHelper.instance.deleteFavoriteByTextAuthor(q.text, q.author);
                        }
                      },
                      child: Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          leading: CircleAvatar(
                            radius: 26,
                            backgroundColor: Colors.primaries[index % Colors.primaries.length][200],
                            child: Text(q.author.isNotEmpty ? q.author[0].toUpperCase() : '?', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                          ),
                          title: Text(q.text, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text(q.author, style: const TextStyle(fontStyle: FontStyle.italic)),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(icon: const Icon(Icons.share_outlined), onPressed: () => _shareFavorite(q)),
                              IconButton(icon: const Icon(Icons.delete_outline), onPressed: () async {
                                if (q.id != null) await _deleteFavorite(q.id!);
                              }),
                            ],
                          ),
                          onTap: () => _showQuoteDetail(q),
                        ),
                      ),
                    );
                  },
                )),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showQuoteDetail(DBFavorite q) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).dialogBackgroundColor,
          elevation: 12,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),

          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.primary.withOpacity(0.85),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.format_quote, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Favorite Quote',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),

          // Content: quote + author
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                q.text,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  height: 1.35,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '- ${q.author ?? "Unknown"}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
                ),
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Close'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _shareFavorite(q);
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 4,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.share_outlined, size: 18),
                  SizedBox(width: 8),
                  Text('Share'),
                ],
              ),
            ),
          ],
        );

      },
    );
  }
}

