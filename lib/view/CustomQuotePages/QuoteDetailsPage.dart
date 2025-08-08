import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/database/database_helper.dart';
import '../../model/CustomQuote/custom_quote_model.dart';

class QuoteDetailPage extends StatelessWidget {
  final CustomQuoteModel quote;
  const QuoteDetailPage({Key? key, required this.quote}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quote Details'),
        leading: BackButton(onPressed: () => Navigator.of(context).pop(false)),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              color: Color(quote.color),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.format_quote, size: 48, color: Colors.white70),
                  const SizedBox(height: 24),
                  Text(
                    quote.quote,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.getFont(
                      quote.fontFamily,
                      fontSize: 20,
                      fontWeight: quote.isBold ? FontWeight.bold : FontWeight.normal,
                      color: Color(quote.fontColor),
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (quote.author.trim().isNotEmpty)
                    Text(
                      '- ${quote.author}',
                      style: GoogleFonts.getFont(
                        quote.fontFamily,
                        fontSize: 16,
                        fontWeight: quote.isBold
                            ? FontWeight.bold
                            : FontWeight.normal,
                          color: Color(quote.fontColor),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(Icons.favorite_border),
                  onPressed: () {
                    // TODO: toggle favorite
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: () {
                    // TODO: share quote
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () async {
                    await DatabaseHelper.instance.deleteQuote(quote.id!);
                    // pop and tell list-screen to refresh:
                    Navigator.of(context).pop(true);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
