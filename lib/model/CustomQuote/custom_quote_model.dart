class CustomQuoteModel{
  final int? id;
  final String content;
  final String color;
  final String dateTime;

  CustomQuoteModel({this.id,
    required this.content,
    required this.color,
    required this.dateTime});


  Map<String,dynamic> toMap(){
    return{
     'id': id,
      'content' : content,
      'color': color,
      'dateTime': dateTime
    };
  }

  factory CustomQuoteModel.fromMap(Map<String, dynamic> map){
    return CustomQuoteModel(
      id: map['id'],
      content: map['content'],
      color: map['color'],
      dateTime: map['dateTime'],

    );
  }
}

