class CustomQuoteModel {
  final int? id;
  final String quote;
  final String author;
  final int color;
  final bool isBold;
  final String fontFamily;
  final int fontColor;

  CustomQuoteModel({
    this.id,
    required this.quote,
    required this.author,
    required this.color,
    this.isBold = false,
    this.fontFamily = 'Albert Sans',
    this.fontColor = 0xFFFFFFFF,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'quote': quote,
    'author': author,
    'color': color,
    'isBold': isBold ? 1 : 0,
    'fontFamily': fontFamily,
    'fontColor': fontColor,
  };

  factory CustomQuoteModel.fromMap(Map<String, dynamic> m) {
    return CustomQuoteModel(
      id: m['id'] as int?,
      quote: m['quote'] as String,
      author: m['author'] as String,
      color: m['color'] as int,
      isBold: (m['isBold'] as int) == 1,
      fontFamily: m['fontFamily'] as String,
      fontColor: m['fontColor'] as int,
    );
  }
}
