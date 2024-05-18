// ignore_for_file: unnecessary_null_comparison, must_be_immutable

import 'package:flutter/material.dart';

import 'package:mp3/views/addflashcard.dart';
import 'package:mp3/views/flashcardsview.dart';
import 'package:mp3/views/quiz.dart';
import '../models/cards.dart';
import '../utils/db_helper.dart';

class CardGridView extends StatefulWidget {
  int? deck_id;
  final String title;

  CardGridView(this.deck_id, this.title, {super.key});

  @override
  State<CardGridView> createState() => _CardGridViewState();
}

class _CardGridViewState extends State<CardGridView> {
  late Future<List<Cards>> data;
  bool isSorted = false;

   @override
  void initState() {
    super.initState();
    data = _loadDataFromDB();
  }

  Future<List<Cards>> _loadDataFromDB() async {
    final data = await DBHelper().query('card_info', where: 'deck_id = ${widget.deck_id}');
    return data.map((e) => Cards(
      id: e['id'] as int,
      deck_id: e['deck_id'] as int,
      question: e['question'] as String,
      answer: e['answer'] as String,
    )).toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Cards>>(
      future: data, 
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else {
          var cards = snapshot.data as List<Cards>;
          var newFlashCards = [...cards];
          var appBar = AppBar(
            title: Text('${widget.title} Deck'),
            centerTitle: true,
            actions: [
              Align(
                alignment: Alignment.center,
                child: IconButton(
                  onPressed: () {
                    setState(() {
                      if (isSorted) {
                        cards.sort((a, b) => a.id.toString().compareTo(b.id.toString())); 
                      } else {
                        cards.sort((a, b) => a.question.compareTo(b.question)); 
                      }
                      isSorted = !isSorted;
                    });
                  },
                  icon: Icon(isSorted ? Icons.sort : Icons.sort_by_alpha),
                )
              ),
              Align(
                alignment: Alignment.center,
                child: IconButton(onPressed: () { if(cards.isNotEmpty) {
                  Navigator.push<Map<String, dynamic>>(
                    context, 
                    MaterialPageRoute(builder: (context) => Quiz(newFlashCards, widget.title)),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('No Cards Present!'),
                  ));
                }
                }, icon: const Icon(Icons.play_circle))
              ), 
            ]
          );
          return Scaffold(
            appBar: appBar,
            body: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: MediaQuery.of(context).size.width ~/ 200,
              ),
              itemCount: cards.length,
              padding: const EdgeInsets.all(4),
              itemBuilder: (context, index) {
                return Card(
                  color: Colors.blue[100],
                  child: Container(
                    alignment: Alignment.center,
                    child: Stack(
                      children: [
                        InkWell(onTap: () async {
                          final result = await Navigator.push<Map<String, dynamic>>(
                            context, 
                            MaterialPageRoute(builder: (context) => FlashCardsView(index, cards)),
                          );
                          if(result != null) {
                            if(result['delete'] == false) {
                              final resultQuestion = result['question'] as String;
                              final resultAnswer = result['answer'] as String;
                              if(resultQuestion != null && resultAnswer != null) {
                                setState(() {
                                  cards[index].question = resultQuestion;
                                });
                                await cards[index].dbUpdate();
                              } 
                            } else {
                              setState(() {
                                 cards[index].dbDelete();
                                cards.removeAt(index);
                              });
                            } 
                          } 
                        }),
                        Center(child: Text(cards[index].question)),
                      ],
                    ),
                  )
                );
              }
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {},
              tooltip: 'Add New Flash Card',
              child: IconButton(
                onPressed: () async {
                  final newCardName = await Navigator.push<Map<String, String>>(
                    context,
                    MaterialPageRoute(builder: (context) => AddFlashCard()),
                  );
                  if (newCardName != null) {
                    final enteredQuestion = newCardName['enteredQuestion'] as String;
                    final enteredAnswer = newCardName['enteredAnswer'] as String;
                    final newFlashCard = Cards(deck_id: widget.deck_id, question: enteredQuestion, answer: enteredAnswer);
                    setState(() {
                      cards.add(newFlashCard);
                      newFlashCard.dbSave();
                    });
                  }
                },
                icon: const Icon(Icons.add),
              ),
            ),
          );
        }
      },
    );
  }
}