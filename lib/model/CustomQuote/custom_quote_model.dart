class CustomQuoteModel {
  final int? id;
  final String quote;
  final String author;
  final int color;     // store as ARGB int
  final bool isBold;

  CustomQuoteModel({
    this.id,
    required this.quote,
    required this.author,
    required this.color,
    this.isBold = false,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'quote': quote,
    'author': author,
    'color': color,
    'isBold': isBold ? 1 : 0,
  };

  factory CustomQuoteModel.fromMap(Map<String, dynamic> m) {
    return CustomQuoteModel(
      id: m['id'] as int?,
      quote: m['quote'] as String,
      author: m['author'] as String,
      color: m['color'] as int,
      isBold: (m['isBold'] as int) == 1,
    );
  }
}
