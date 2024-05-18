// import 'package:mp3/models/question_answer.dart';
import '../utils/db_helper.dart';

class DecksModel {
  int? deck_id;
  String title;
  int cardCount;

  DecksModel({
    this.deck_id,
    required this.title,
    this.cardCount = 0,
  });

  factory DecksModel.fromJson(Map<String, dynamic> json) {
    return DecksModel(
      title: json['title'] as String);
  }

  Future<void> dbSave() async {
    deck_id = await DBHelper().insertDeck('deck_info', {
      'title': title,
    });
  }

  Future<void> dbDelete() async {
    if(deck_id != null) {
      await DBHelper().deleteDeck('deck_info', deck_id!);
    }
  }

  Future<void> dbUpdate() async {
    await DBHelper().updateDeck('deck_info', {
      'title': title,
    }, deck_id!);
  }

}
