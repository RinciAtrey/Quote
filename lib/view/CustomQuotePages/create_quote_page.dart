import 'package:flutter/material.dart';
import 'package:quotes_daily/data/database/database_helper.dart';
import 'package:quotes_daily/model/CustomQuote/TextInfoModel.dart';
import '../../model/CustomQuote/custom_quote_model.dart';

// actual editing page
class CreateQuotePage extends StatefulWidget {
  final CustomQuoteModel? quote;

  const CreateQuotePage({this.quote});

  @override
  State<CreateQuotePage> createState() => _CreateQuotePageState();
}

class _CreateQuotePageState extends State<CreateQuotePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  late TextEditingController textEditingController = TextEditingController();
  List<TextInfoModel> texts = [];

  Color _selectedColor = Colors.amber;
  final List<Color> _colors = [
    Colors.amber,
    Colors.redAccent,
    Colors.purple,
  ];

  @override
  void initState() {
    super.initState();
    if (widget.quote != null) {
      _titleController.text = widget.quote!.content;
      _selectedColor = Color(int.parse(widget.quote!.color));
    }
  }

  String _formatDateTime(String dateTime) {
    final DateTime dt = DateTime.parse(dateTime);
    final now = DateTime.now();

    if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
      return 'Today, ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }
    return '${dt.day}/${dt.month}/${dt.year}, ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.quote == null ? 'Create Quote' : 'Edit Quote'),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Display the selected color in a circular container.
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _selectedColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black, width: 2),
              ),
            ),
            const SizedBox(height: 16),
            // Row of color options.
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _colors.map((color) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedColor = color;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: _selectedColor == color
                          ? Border.all(color: Colors.black, width: 2)
                          : null,
                    ),
                  ),
                );
              }).toList(),
            ),
            // Additional widgets (such as TextFormField for quote text) go here.
          ],
        ),
      ),

      //Tapping on this will open the alert box
      floatingActionButton: _addnewTextFab,
    );
  }

  Widget get _addnewTextFab => FloatingActionButton(
        onPressed: () => addNewDialog(context),
        backgroundColor: Colors.white,
        tooltip: 'Add New Text',
        child: const Icon(
          Icons.add,
          color: Colors.black,
        ),
      );

  addNewDialog(context) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text(
          'Add New Text',
        ),
        content: TextField(
          controller: textEditingController,
          maxLines: 5,
          decoration: const InputDecoration(
            suffixIcon: Icon(
              Icons.edit,
            ),
            filled: true,
            hintText: 'Your text here...',
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              addNewText(context);
            },
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all<Color>(Colors.red),
              //add text colour
            ),
            child: Text('Back'),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all<Color>(Colors.red),
              //add text colour
            ),
            child: Text('Back'),
          )
        ],
      ),
    );
  }

  addNewText(BuildContext context) {
    setState(() {
      texts.add(TextInfoModel(
          text: textEditingController.text,
          left: 0,
          top: 0,
          color: Colors.black,
          fontWeight: FontWeight.normal,
          fontStyle: FontStyle.normal,
          fontSize: 20,
          textAlign: TextAlign.left));
      Navigator.of(context).pop();
    });
  }
}
