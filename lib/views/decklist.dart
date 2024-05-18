// ignore_for_file: must_be_immutable, unnecessary_brace_in_string_interps, unnecessary_null_comparison
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:mp3/models/cards.dart';
import 'package:mp3/models/decks.dart';
import 'package:mp3/utils/db_helper.dart';
import 'package:mp3/views/adddeck.dart';
import 'package:mp3/views/cardgridview.dart';
import 'package:mp3/views/editdeck.dart';


class CardList extends StatefulWidget {
  const CardList({super.key});

  @override
  _CardListState createState() => _CardListState();
}

class _CardListState extends State<CardList> {
  late Future<List<DecksModel>> data;
  Map<int, int> deckCardCounts = {};

  @override
  void initState() {
    super.initState();
    data = _loadDataFromDB();
  }

  Future<List<DecksModel>> _loadDataFromDB() async {
    final data = await DBHelper().query('deck_info');
    final decks = data.map((e) => DecksModel(
      deck_id: e['deck_id'] as int,
      title: e['title'] as String,
    )).toList();
    for (var deck in decks) {
      final cardCount = await DBHelper().count(deck.deck_id as int);
      deckCardCounts[deck.deck_id!] = cardCount as int;
      deck.cardCount = cardCount;
    }
    return decks;
  }

  void updateCardCount(int deckId, int countChange) {
    setState(() {
      final currentCount = deckCardCounts[deckId] ?? 0;
      deckCardCounts[deckId] = currentCount + countChange;
    });
  }

  Future<void> loadFlashcards() async {
    final jsonContent = await rootBundle.loadString('assets/flashcards.json');
    final parsedJson = json.decode(jsonContent);

    if (parsedJson != null && parsedJson is List) {
      for (DecksModel decksModel in List<DecksModel>.from(
          parsedJson.map((e) => DecksModel.fromJson(e)).toList())) {
        await decksModel.dbSave();
        for (Map<String, dynamic> deckData in parsedJson) {
          if (deckData['title'] == decksModel.title) {
            final flashcards = deckData['flashcards'];
            for (Map<String, dynamic> flashcardData in flashcards) {
              final card = Cards(
                deck_id: decksModel.deck_id,
                question: flashcardData['question'],
                answer: flashcardData['answer'],
              );
              await card.dbSave();
            }
           break; 
          }
        }
      }
    }
  }

  Future<void> _editDeck(List<DecksModel> data, int index) async {
    var result = await Navigator.push<Map<String, dynamic>>(
      context, 
      MaterialPageRoute(builder: (context) => EditDeck(data, index))
    );

    if (!mounted) return;

    if(result != null) {
      if(result['editedDeck'] == true && result['title'] != "") {
        final resultTitle = result['title'] as String;
        setState(() {
          data[index].title = resultTitle;
        });
        await data[index].dbUpdate();
      } else {
        await data[index].dbDelete();
        setState(() {
          data.removeAt(index);
        });
        updateCardCount(data[index].deck_id as int, -1);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<DecksModel>>(
      future: data, 
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else {
          var size = MediaQuery.sizeOf(context);

          var decks = snapshot.data as List<DecksModel>;
           
          var appBar = size.width != null
            ? AppBar(
            title: const Text('Deck List'),
            centerTitle: true,
            leading: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.home),
            ),
            actions: [
              Align(
                alignment: Alignment.center,
                child: IconButton(
                  onPressed: () async {
                    await loadFlashcards();
                    setState(() { 
                      data = _loadDataFromDB();
                    });
                }, icon: const Icon(Icons.add_card))
              ), 
            ]
          ) : null;

          return Scaffold(
            appBar: appBar,
            body: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: MediaQuery.of(context).size.width ~/ 200,
              ),
              itemCount: decks.length,
              padding: const EdgeInsets.all(4),
              itemBuilder: (context, index) {
                return Card(
                  color: Colors.blue[100],
                  child: Container(
                    alignment: Alignment.center,
                    child: Stack(
                      children: [
                        InkWell(onTap: () async {
                          Navigator.of(context).push(
                            MaterialPageRoute<String>(
                              builder: (context) {
                                return CardGridView(decks[index].deck_id, decks[index].title);
                              }
                            ),
                          ).then((value) => { data = _loadDataFromDB(), setState(() => {})});
                        }),
                        Center(child: Text("${decks[index].title} (${decks[index].cardCount} Cards)")),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: IconButton(icon: const Icon(Icons.edit), onPressed: () { _editDeck(decks, index); },),
                        ),
                      ],
                    )
                  )
                );
              }
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {},
              tooltip: 'Add New Deck',
              child: IconButton(
                onPressed: () async {
                  final newCardName = await Navigator.push<String>(
                    context,
                    MaterialPageRoute(builder: (context) => AddDeck()),
                  );
                  if (newCardName != null) {
                    final newCard = DecksModel(title: newCardName);
                    setState(() {
                      decks.add(newCard);
                      newCard.dbSave();
                    });
                  }
                },
                icon: const Icon(Icons.add),
              ),
            ),
          );
        }
      }
    );
  }
}