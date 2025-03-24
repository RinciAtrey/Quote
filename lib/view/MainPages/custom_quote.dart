import 'package:flutter/material.dart';
import 'package:quotes_daily/Utils/routes/routes_name.dart';



import 'package:quotes_daily/data/database/database_helper.dart';
import '../../model/CustomQuote/custom_quote_model.dart';


//quotes will appear


class CustomQuotePage extends StatefulWidget {
  const CustomQuotePage({super.key});

  @override
  State<CustomQuotePage> createState() => _CustomQuotePageState();
}

class _CustomQuotePageState extends State<CustomQuotePage> {

  final DatabaseHelper _databaseHelper= DatabaseHelper();
  List<CustomQuoteModel> _quotes=[];
  final List<Color> _quoteColors= [
    Colors.amber,
    Colors.redAccent,
    Colors.purple
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadQuotes();
  }

  Future<void> _loadQuotes() async{
    final quotes = await _databaseHelper.getQuotes();
    setState(() {
      _quotes=quotes;
    });
  }

  String _formatDateTime(String dateTime){
    final DateTime dt =DateTime.parse(dateTime);
    final now= DateTime.now();

    if(dt.year== now.year && dt.month==now.month&& dt.day==now.day){
      return 'Today, ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(0, '0')}';
    }
    return '${dt.day}/${dt.month}/${dt.year}, ${dt.hour.toString().padLeft(2,'0')}: ${dt.minute.toString().padLeft(0,'0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Your quotes"),
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.add,
                color: Colors.white,
              ),
              onPressed: () {
                //Navigator.push(context, MaterialPageRoute(builder: (context)=> ));
                Navigator.pushNamed(context, RoutesName.createQuotePage);
              },
            )
    ,]
      ),
      body: GridView.builder(gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16),
          padding: EdgeInsets.all(16),
          itemCount: _quotes.length,
          itemBuilder: (context,index){
            final quote= _quotes[index];
            final color=Color(int.parse(quote.color));

            return GestureDetector(
              onTap: () async{
                //await Navigator.push(context, MaterialPageRoute(builder: (context)=> ViewQuoteScreen(quote:quote),));
                _loadQuotes();
              },
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(1),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    )
                  ]

                ),
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(quote.content,
                      style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,

                    ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8,),
                    Spacer(),
                    Text(_formatDateTime(quote.dateTime),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  ],
                ),
              ),
            );
          }),
        floatingActionButton: FloatingActionButton(onPressed: ()async{
         await Navigator.pushNamed(context, RoutesName.createQuotePage);
    },
    child: Icon(Icons.add),
    backgroundColor: Colors.purple,
    foregroundColor: Colors.white,

    ),
    
    );
  }
}


