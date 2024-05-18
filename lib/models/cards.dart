import '../utils/db_helper.dart';

class Cards {
  int? id;
  final int? deck_id;
  String question;
  String answer;
  bool? isSeen = false;
  bool? isPeeked = false;

  Cards({
    this.id,
    this.deck_id,
    required this.question,
    required this.answer,
  });

  factory Cards.fromJson(Map<String, dynamic> json) {
    return Cards(
      question: json['question'],
      answer: json['answer'],
    );
  }

  Future<void> dbSave() async {
    id = await DBHelper().insert('card_info', {
      'deck_id': deck_id,
      'question': question,
      'answer': answer,
    });
  }

  Future<void> dbDelete() async {
    if(id != null) {
      await DBHelper().delete('card_info', id!);
    }
  }

  Future<void> dbUpdate() async {
    if(id != null) {
      await DBHelper().update('card_info', {
        'question': question,
        'answer': answer,
      }, id!);
    }
  }

  Future<int?> cardsCount() async {
    if(deck_id != null) {
      return await DBHelper().count(deck_id!);
    }
    return 0;
  }
}
