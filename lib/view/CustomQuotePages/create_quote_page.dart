import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quotes_daily/Utils/colors/AppColors.dart';
import 'package:quotes_daily/data/database/databaseHelper_customQuote.dart';
import 'package:quotes_daily/model/CustomQuote/custom_quote_model.dart';

class CreateQuotePage extends StatefulWidget {
  const CreateQuotePage({Key? key}) : super(key: key);

  @override
  State<CreateQuotePage> createState() => _CreateQuotePageState();
}

class _CreateQuotePageState extends State<CreateQuotePage> {
  final _formKey = GlobalKey<FormState>();
  String _quote = '';
  String _author = '';
  Color _bgColor = AppColors.appColor;
  Color _fontColor = Colors.white;
  bool _isBold = false;
  String _fontFam = 'Albert Sans';

  final _colors = <Color>[
    AppColors.appColor,
    Colors.teal,
    Colors.lightBlue,
    Colors.amber,
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.purple,
    Colors.orange,
    Colors.brown,
    Colors.pink,
  ];

  final _fonts = <String>[
    'Albert Sans',
    'Pacifico',
    'Open Sans',
    'Lato',
    'Roboto',
    'Merriweather',
    'Playfair Display',
    'Montserrat',
    'Oswald',
    'Raleway',
    'Nunito',
    'Poppins',
    'Roboto Slab',
    'Dancing Script',
    'Lobster',
    'Quicksand',
    'Indie Flower',
    'Bebas Neue',
    'Cormorant Garamond',
  ];

  final _fontColors = <Color>[
    Colors.white,
    Colors.black,
    Colors.red,
    Colors.blue,
    AppColors.appColor,
    Colors.yellow,
    Colors.green,
    Colors.pink,
    Colors.orange,
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
    await DBCustomQuote.instance.insertQuote(model);
    Navigator.of(context).pop();
  }

  Color _contrastTextColor(Color bg) =>
      bg.computeLuminance() > 0.5 ? Colors.black : Colors.white;

  Widget _buildCircle(Color color, Color selected, VoidCallback onTap) {
    final bool isSelected = color == selected;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(right: 12),
        width: isSelected ? 46 : 38,
        height: isSelected ? 46 : 38,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: color.withOpacity(0.25),
              blurRadius: 8,
              spreadRadius: 1,
              offset: const Offset(0, 4),
            )
          ]
              : [],
          border: Border.all(
            color: isSelected ? Colors.black38 : Colors.transparent,
            width: isSelected ? 3 : 1,
          ),
        ),
        child: isSelected
            ? Center(
          child: Icon(
            Icons.check,
            size: 18,
            color: _contrastTextColor(color),
          ),
        )
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final screenHeight = media.size.height;
    final screenWidth = media.size.width;
    final previewHeight = (screenHeight * 0.46).clamp(220.0, 520.0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Quote'),
        actions: [
          TextButton(
            onPressed: _saveQuotes,
            child: const Text('Save', style: TextStyle(color: Colors.black),),
          ),
        ],
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        children: [
          // Preview Card
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: previewHeight,
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: LinearGradient(
                  colors: [
                    _bgColor.withOpacity(0.95),
                    _bgColor.withOpacity(0.86),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _bgColor.withOpacity(0.2),
                    blurRadius: 18,
                    spreadRadius: 1,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              child: Center(
                child: Form(
                  key: _formKey,
                  child: LayoutBuilder(builder: (context, constraints) {
                    final baseFontSize = (screenWidth / 24).clamp(14.0, 26.0);
                    final authorSize = (screenWidth / 30).clamp(12.0, 20.0);
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Quote field
                        TextFormField(
                          initialValue: _quote,
                          maxLines: 6,
                          style: GoogleFonts.getFont(
                            _fontFam,
                            fontSize: baseFontSize,
                            fontWeight: _isBold ? FontWeight.bold : FontWeight.normal,
                            color: _fontColor,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Enter your quote',
                            hintStyle: TextStyle(color: _fontColor.withOpacity(.65)),
                            border: InputBorder.none,
                            isDense: true,
                          ),
                          onChanged: (v) => setState(() => _quote = v),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Quote can\'t be empty';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),
                        Divider(color: _fontColor.withOpacity(.6)),
                        // Author field
                        TextFormField(
                          initialValue: _author,
                          style: GoogleFonts.getFont(
                            _fontFam,
                            fontSize: authorSize,
                            fontStyle: FontStyle.italic,
                            fontWeight: _isBold ? FontWeight.bold : FontWeight.normal,
                            color: _fontColor,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Author',
                            hintStyle: TextStyle(color: _fontColor.withOpacity(.65)),
                            border: InputBorder.none,
                            isDense: true,
                          ),
                          onChanged: (v) => setState(() => _author = v),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),
          const Divider(),

          // Background Color
          const SizedBox(height: 8),
          const Text('Background Color', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final c in _colors) _buildCircle(c, _bgColor, () => setState(() => _bgColor = c)),
                IconButton(
                  icon: const Icon(Icons.format_color_fill),
                  onPressed: () => _pickColor(_bgColor, (c) => setState(() => _bgColor = c)),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
          const Divider(),

          // Font Color
          const SizedBox(height: 8),
          const Text('Font Color', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final c in _fontColors) _buildCircle(c, _fontColor, () => setState(() => _fontColor = c)),
                IconButton(
                  icon: const Icon(Icons.color_lens),
                  onPressed: () => _pickColor(_fontColor, (c) => setState(() => _fontColor = c)),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
          const Divider(),

          // Font Family
          const SizedBox(height: 8),
          const Text('Font Style', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          SizedBox(
            height: 48,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _fonts.map((f) {
                  final sel = _fontFam == f;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(f, style: GoogleFonts.getFont(f, fontSize: 14)),
                      selected: sel,
                      onSelected: (_) => setState(() => _fontFam = f),
                      elevation: 2,
                      selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.12),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          const SizedBox(height: 16),
          const Divider(),

          SwitchListTile(
            title: const Text('Bold'),
            value: _isBold,
            onChanged: (v) => setState(() => _isBold = v),
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}
