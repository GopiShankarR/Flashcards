// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import '../models/cards.dart';

class Quiz extends StatefulWidget {
  final List<Cards> cards;
  String title;

  Quiz(this.cards, this.title, {super.key});

  @override
  State<Quiz> createState() => _QuizState();
}

class _QuizState extends State<Quiz> {
  bool isFlipped = false;
  int peekedAnswers = 0;
  int seenCards = 1;
  String currentQuestion = '';
  int currentQuestionIndex = 0;

  @override
  void initState() {
    super.initState();
    widget.cards.shuffle();
    widget.cards[0].isSeen = true;
    widget.cards[0].isPeeked = false;
  }

    void showPreviousQuestion() {
    setState(() {
      if (currentQuestionIndex > 0) {
        currentQuestionIndex--;
      } else {
        currentQuestionIndex--;
        currentQuestionIndex = widget.cards.length - (currentQuestionIndex*-1);
      }
      if (widget.cards[currentQuestionIndex].isSeen == false) {
        widget.cards[currentQuestionIndex].isSeen = true;
        seenCards++;
      }
      isFlipped = false;
    });
  }

  void showNextQuestion() {
    setState(() {
      if(currentQuestionIndex < widget.cards.length - 1) {
        currentQuestionIndex++;
      } else {
        currentQuestionIndex++;
        currentQuestionIndex = currentQuestionIndex - widget.cards.length;
      }
      if(widget.cards[currentQuestionIndex].isSeen == false) {
        widget.cards[currentQuestionIndex].isSeen = true;
        seenCards++;
      }
      isFlipped = false;
    });
  }

    void toggleCard() {
    setState(() {
      isFlipped = !isFlipped;
      if (isFlipped) {
        if (widget.cards.isNotEmpty) {
          if(widget.cards[currentQuestionIndex].isPeeked == false) {
            widget.cards[currentQuestionIndex].isPeeked = true;
            peekedAnswers++;
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double cardWidth = MediaQuery.of(context).size.width * 0.8;
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.title} Quiz'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: Center(
              child: GestureDetector(
                onTap: toggleCard,
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  color: isFlipped ? Colors.green[200] : Colors.blue[100],
                  child: SizedBox(
                    width: cardWidth,
                    height: 400,
                    child: Stack(
                      children: [
                        if(currentQuestionIndex >= 0) 
                          Center(child: Text(isFlipped ? widget.cards[currentQuestionIndex].answer : widget.cards[currentQuestionIndex].question))
                      ],
                    )
                  )
                )
              )
            )
          ),
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: showPreviousQuestion,
                ),
                IconButton(
                  icon: Icon(isFlipped ? Icons.content_copy_rounded : Icons.content_copy_outlined),
                  onPressed: toggleCard,
                  
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: showNextQuestion,
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: 
            Column(
              mainAxisAlignment: MainAxisAlignment.start, 
              children: [
                Text('Seen $seenCards of ${widget.cards.length} answers',), 
                Text(
              "Peeked $peekedAnswers out of $seenCards answers",
            )])
            ,
          ),
        ]
      )
    );
  }
}