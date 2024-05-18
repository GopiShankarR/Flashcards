// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import '../models/cards.dart';

class FlashCardsView extends StatefulWidget {
  int index;
  List<Cards> data;

  FlashCardsView(this.index, this.data, {super.key});

  @override
  State<FlashCardsView > createState() => _FlashCardsViewState();
}

class _FlashCardsViewState extends State<FlashCardsView > {
  TextEditingController questionNameController = TextEditingController();
  TextEditingController answerNameController = TextEditingController();
  
  @override
  void initState() {
    questionNameController.text = widget.data[widget.index].question;
    answerNameController.text = widget.data[widget.index].answer;
    super.initState();
  }  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit FlashCard'), centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: TextFormField(
                controller: questionNameController,
                decoration: const InputDecoration(labelText: 'Question'),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: TextFormField(
                controller: answerNameController,
                decoration: const InputDecoration(labelText: 'Answer'),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  child: const Text('Save'),
                  onPressed: () {
                    setState(() {
                      widget.data[widget.index].question = questionNameController.text;
                      widget.data[widget.index].answer = answerNameController.text;
                    });
                    Navigator.pop(context, {'question': questionNameController.text, 'answer': answerNameController.text, 'delete': false});
                  },
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, {'question': '', 'answer': '', 'delete': true});
                  },
                  child: const Text('Delete'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}