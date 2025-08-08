import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quotes_daily/model/CustomQuote/custom_quote_model.dart';
import 'package:quotes_daily/view/CustomQuotePages/create_quote_page.dart';

import '../../data/database/database_helper.dart';
import '../CustomQuotePages/QuoteDetailsPage.dart';

class CustomQuote extends StatefulWidget {
  const CustomQuote({super.key});

  @override
  State<CustomQuote> createState() => _CustomQuoteState();
}

class _CustomQuoteState extends State<CustomQuote> {
  List<CustomQuoteModel> _quotes= [];

  @override
  void initState(){
    super.initState();
    _loadQuotes();
}


  Future<void> _loadQuotes() async {
    final all = await DatabaseHelper.instance.getAllQuotes();
    setState(() => _quotes = all);
  }

  Future<void> _delete(int id) async {
    await DatabaseHelper.instance.deleteQuote(id);
    _loadQuotes();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Quotes"),
      ),
      body: _quotes.isEmpty
        ? const Center(
        child: Text("No quotes yet"))
          : ListView.builder(
        itemCount: _quotes.length,
        itemBuilder: (_,i){
          final q= _quotes[i];
          return Card(
            color: Color(q.color),
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text(
                q.quote,
                style: GoogleFonts.getFont(
                  q.fontFamily,
                  fontWeight: q.isBold ? FontWeight.bold : FontWeight.normal,
                  color: Color(q.fontColor),
                ),
              ),
              subtitle: q.author.trim().isNotEmpty
                  ? Text(
                '- ${q.author}',
                style: GoogleFonts.getFont(
                  q.fontFamily,
                  fontStyle: FontStyle.italic,
                  fontWeight: q.isBold ? FontWeight.bold : FontWeight.normal,
                  color: Color(q.fontColor),
                ),
              )
                  : null,
              onTap:  () async {
                final wasDeleted = await Navigator.of(context).push<bool>(
                  MaterialPageRoute(
                    builder: (_) => QuoteDetailPage(quote: q),
                  ),
                );
                if (wasDeleted == true) {
                  _loadQuotes(); // reload list if they deleted the quote
                }
              },
              trailing: IconButton(onPressed: (){
                _delete(q.id!);
              }, icon: Icon(Icons.delete)),
            ),
          );
        },
      ),
        floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
    onPressed: () async{
          await Navigator.of(context).push(MaterialPageRoute(builder:
    (_)=> const CreateQuotePage()),);
          _loadQuotes();
    },
    ),
    );
  }
}
