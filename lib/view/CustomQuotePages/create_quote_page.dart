import 'package:flutter/material.dart';
import 'package:quotes_daily/data/database/database_helper.dart';
import 'package:quotes_daily/model/CustomQuote/custom_quote_model.dart';

class CreateQuotePage extends StatefulWidget {
  const CreateQuotePage({super.key});

  @override
  State<CreateQuotePage> createState() => _CreateQuotePageState();
}

class _CreateQuotePageState extends State<CreateQuotePage> {
  final _formKey = GlobalKey<FormState>();
  String _quote = '';
  String _author = '';
  Color _bgColor = Colors.amber;
  bool _isBold = false;

  final List<Color> _colors = [
    Colors.amber,
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.purple,
    Colors.orange,
    Colors.brown,
    Colors.pink,
  ];

  void _saveQuotes() async{
    if(!_formKey.currentState!.validate()) return;
    final model= CustomQuoteModel(quote: _quote.trim(),
        author: _author.trim(),
        color: _bgColor.value,
      isBold: _isBold
    );
    await DatabaseHelper.instance.insertQuote(model);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text("Create Quote"),
        actions: [
          TextButton(onPressed:_saveQuotes , child: Text("Save"))
        ],
      ),
      body: Column(
        children: [
          Form(
            key: _formKey,
            child: Container(
              margin: EdgeInsets.all(16),
              width: double.infinity,
              //40% of screen height
              height: screenHeight * 0.4,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _bgColor,
                borderRadius: BorderRadius.circular(12)
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    initialValue: _quote,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: _isBold ? FontWeight.bold : FontWeight.normal,
                      color: Colors.white,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Enter your quote',
                      hintStyle: TextStyle(color: Colors.white70),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                    onChanged: (v) => setState(() => _quote = v),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Divider(color: Colors.white70, thickness: 1),
                  ),
                  const SizedBox(height: 8,),
                  TextFormField(
                    initialValue: _author,
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      fontWeight: _isBold ? FontWeight.bold : FontWeight.normal,
                      color: Colors.white,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Author',
                      hintStyle: TextStyle(color: Colors.white70),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                    onChanged: (v)=> setState(()=>
                      _author=v),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10,),
          Container(
            padding: EdgeInsets.all(16),
            child: Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: 8,
                  children: _colors.map((c) {
                    return GestureDetector(
                      onTap: () => setState(() => _bgColor = c),
                      child: CircleAvatar(
                        backgroundColor: c,
                        child: _bgColor == c
                            ? const Icon(Icons.check, color: Colors.white)
                            : null,
                      ),
                    );
                  }).toList(),
                )
            ),
          ),
          SwitchListTile(
            title: const Text('Bold'),
            value: _isBold,
            onChanged: (v) => setState(() => _isBold = v),
          ),
        ],

      ),
    );
  }
}
