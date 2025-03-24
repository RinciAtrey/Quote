class QuotesRandomModel {
  String? q;
  String? a;
  String? h;

  QuotesRandomModel({this.q, this.a, this.h});

  QuotesRandomModel.fromJson(Map<String, dynamic> json) {
    q = json['q'];
    a = json['a'];
    h = json['h'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['q'] = this.q;
    data['a'] = this.a;
    data['h'] = this.h;
    return data;
  }
}
