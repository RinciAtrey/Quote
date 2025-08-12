import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quotes_daily/Utils/colors/AppColors.dart';
import 'package:quotes_daily/model/CustomQuote/custom_quote_model.dart';
import 'package:quotes_daily/view/CustomQuotePages/create_quote_page.dart';

import '../../data/database/databaseHelper_customQuote.dart';
import '../CustomQuotePages/QuoteDetailsPage.dart';

class CustomQuote extends StatefulWidget {
  const CustomQuote({super.key});

  @override
  State<CustomQuote> createState() => _CustomQuoteState();
}

class _CustomQuoteState extends State<CustomQuote> {
  List<CustomQuoteModel> _quotes = [];

  @override
  void initState() {
    super.initState();
    _loadQuotes();
  }

  Future<void> _loadQuotes() async {
    final all = await DBCustomQuote.instance.getAllQuotes();
    setState(() => _quotes = all);
  }

  Future<void> _delete(int id) async {
    await DBCustomQuote.instance.deleteQuote(id);
    _loadQuotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          elevation: 0,
          backgroundColor: AppColors.appColor,
          titleSpacing: 0,
          title:
          Padding(padding: EdgeInsets.all(8),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(30),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Icon(Icons.quora,
                      color: Colors.white),
                ),
                const SizedBox(width: 12),
                const Text(
                  "My Quotes",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          )
      ),
      body: _quotes.isEmpty
          ? Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.format_quote, size: 80, color: AppColors.appColor.withAlpha(150)),
              const SizedBox(height: 16),
              Text(
                "No quotes yet",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                "Tap the button below to add your first quote.",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () async {
                  await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CreateQuotePage()));
                  _loadQuotes();
                },
                icon: const Icon(Icons.add),
                label: const Text("Create Quote"),
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    foregroundColor: Colors.white, backgroundColor: AppColors.appColor),
              )
            ],
          ),
        ),
      )
          : RefreshIndicator(
        onRefresh: _loadQuotes,
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          itemCount: _quotes.length,
          itemBuilder: (_, i) {
            final q = _quotes[i];
            final bg = Color(q.color);
            final fontColor = Color(q.fontColor);
            return Card(
              elevation: 6,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () async {
                  final wasDeleted = await Navigator.of(context).push<bool>(
                    MaterialPageRoute(
                      builder: (_) => QuoteDetailPage(quote: q),
                    ),
                  );
                  if (wasDeleted == true) {
                    _loadQuotes();
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      // Leading badge
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: fontColor.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            q.quote.isNotEmpty ? q.quote[0].toUpperCase() : '?',
                            style: GoogleFonts.getFont(
                              q.fontFamily,
                              color: fontColor,
                              fontWeight: q.isBold ? FontWeight.bold : FontWeight.normal,
                              fontSize: 22,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Texts
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              q.quote,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.getFont(
                                q.fontFamily,
                                color: fontColor,
                                fontWeight: q.isBold ? FontWeight.bold : FontWeight.normal,
                                fontSize: 16,
                              ),
                            ),
                            if (q.author.trim().isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Text(
                                '- ${q.author}',
                                style: GoogleFonts.getFont(
                                  q.fontFamily,
                                  color: fontColor.withOpacity(0.9),
                                  fontStyle: FontStyle.italic,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      // Delete button
                      IconButton(
                        onPressed: () {
                          _delete(q.id!);
                        },
                        icon: Icon(Icons.delete, color: Theme.of(context).colorScheme.onBackground),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        foregroundColor: Colors.white,
        backgroundColor: AppColors.appColor,
        onPressed: () async {
          await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CreateQuotePage()));
          _loadQuotes();
        },
      ),
    );
  }
}
