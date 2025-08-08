import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quotes_daily/data/database/database_helper.dart';
import 'package:quotes_daily/model/CustomQuote/custom_quote_model.dart';

class CreateQuotePage extends StatefulWidget {
  const CreateQuotePage({Key? key}) : super(key: key);

  @override
  State<CreateQuotePage> createState() => _CreateQuotePageState();
}

class _CreateQuotePageState extends State<CreateQuotePage> {
  final _formKey = GlobalKey<FormState>();
  String _quote     = '';
  String _author    = '';
  Color  _bgColor   = Colors.amber;
  Color  _fontColor = Colors.white;
  bool   _isBold    = false;
  String _fontFam   = 'Almendra Display';

  final _colors     = <Color>[
    Colors.amber, Colors.red, Colors.green, Colors.blue,
    Colors.purple, Colors.orange, Colors.brown, Colors.pink,
  ];

  final _fonts      = <String>[
    'Almendra Display', 'Albert Sans', 'Pacifico', 'Open Sans',
  ];

  final _fontColors = <Color>[
    Colors.white, Colors.black, Colors.red, Colors.blue,
    Colors.yellow, Colors.green, Colors.pink, Colors.orange,
  ];

  Future<void> _pickColor(Color current, ValueChanged<Color> onColor) async {
    Color tmp = current;
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Pick a color'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: tmp,
            onColorChanged: (c) => tmp = c,
            enableAlpha: false,
            pickerAreaHeightPercent: 0.7,
          ),
        ),
        actions: [
          TextButton(onPressed: Navigator.of(context).pop, child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              onColor(tmp);
              Navigator.of(context).pop();
            },
            child: const Text('Select'),
          ),
        ],
      ),
    );
  }

  void _saveQuotes() async {
    if (!_formKey.currentState!.validate()) return;
    final model = CustomQuoteModel(
      quote: _quote.trim(),
      author: _author.trim(),
      color: _bgColor.value,
      isBold: _isBold,
      fontFamily: _fontFam,
      fontColor: _fontColor.value,
    );
    await DatabaseHelper.instance.insertQuote(model);
    Navigator.of(context).pop();
  }

  Widget _buildCircle(Color color, Color selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          border: Border.all(
            color: color == selected ? Colors.white : Colors.transparent,
            width: 3,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Quote'),
        actions: [
          TextButton(onPressed: _saveQuotes, child: const Text('Save')),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(3.0),
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          children: [
            Container(
              height: screenHeight * 0.5,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _bgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          initialValue: _quote,
                          style: GoogleFonts.getFont(
                            _fontFam,
                            fontSize: 18,
                            fontWeight:
                            _isBold ? FontWeight.bold : FontWeight.normal,
                            color: _fontColor,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Enter your quote',
                            hintStyle: TextStyle(color: _fontColor.withOpacity(.6)),
                            border: InputBorder.none,
                            isDense: true,
                          ),
                          onChanged: (v) => setState(() => _quote = v),
                        ),
                        const Divider(color: Colors.white70),
                        TextFormField(
                          initialValue: _author,
                          style: GoogleFonts.getFont(
                            _fontFam,
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                            fontWeight:
                            _isBold ? FontWeight.bold : FontWeight.normal,
                            color: _fontColor,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Author',
                            hintStyle: TextStyle(color: _fontColor.withOpacity(.6)),
                            border: InputBorder.none,
                            isDense: true,
                          ),
                          onChanged: (v) => setState(() => _author = v),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 24),
            const Divider(),

            // — Background Color Section —
            const Text('Background Color', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final c in _colors)
                    _buildCircle(c, _bgColor, () => setState(() => _bgColor = c)),
                  IconButton(
                    icon: const Icon(Icons.color_lens),
                    onPressed: () => _pickColor(_bgColor, (c) => setState(() => _bgColor = c)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            const Divider(),

            // — Font Color Section —
            const Text('Font Color', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final c in _fontColors)
                    _buildCircle(c, _fontColor, () => setState(() => _fontColor = c)),
                  IconButton(
                    icon: const Icon(Icons.format_color_text),
                    onPressed: () => _pickColor(_fontColor, (c) => setState(() => _fontColor = c)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            const Divider(),

            // — Font Family Section —
            const Text('Font Family', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _fonts.map((f) {
                  final sel = _fontFam == f;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(f, style: GoogleFonts.getFont(f)),
                      selected: sel,
                      onSelected: (_) => setState(() => _fontFam = f),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 24),
            const Divider(),

            // — Bold Toggle —
            SwitchListTile(
              title: const Text('Bold'),
              value: _isBold,
              onChanged: (v) => setState(() => _isBold = v),
            ),
          ],
        ),
      ),
    );
  }
}
