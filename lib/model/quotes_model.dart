class QuotesModel {
  String? q;
  String? a;
  String? c;
  String? h;
  bool isFavorite=false;

  QuotesModel({this.q, this.a, this.c, this.h, required this.isFavorite});

  @override
  String toString() {
    return 'Quote: "$q" by $a';
  }

  QuotesModel.fromJson(Map<String, dynamic> json) {
    q = json['q'];
    a = json['a'];
    c = json['c'];
    h = json['h'];
    isFavorite  = json['isFavorite'] = true;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['q'] = this.q;
    data['a'] = this.a;
    data['c'] = this.c;
    data['h'] = this.h;
    data['isFavorite']  = isFavorite;
    return data;
  }
}
