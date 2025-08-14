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
        titleSpacing: 0,
        backgroundColor: Colors.transparent,
        elevation: 6,
        foregroundColor: Colors.white,
        //increases height
        toolbarHeight: 70,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(18),
            bottomRight: Radius.circular(18),
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            color: AppColors.appColor,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(18),
              bottomRight: Radius.circular(18),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 16,
                offset: Offset(0, 8),
              ),
            ],
          ),
        ),
        title:  Text(
            'My Quotes',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white),
          ),
        leading: Icon(Icons.create_outlined),
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
                        icon: Icon(Icons.delete, color: Colors.white),
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
