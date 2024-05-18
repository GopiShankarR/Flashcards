import 'package:flutter/material.dart';

class AddFlashCard extends StatelessWidget {
  final TextEditingController questionNameController = TextEditingController();
  final TextEditingController answerNameController = TextEditingController();

  AddFlashCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Flash Card'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextFormField(
              controller: questionNameController,
              decoration: const InputDecoration(labelText: 'Question'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: answerNameController,
              decoration: const InputDecoration(labelText: 'Answer'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final enteredQuestion = questionNameController.text;
                final enteredAnswer = answerNameController.text;
                if (enteredQuestion.isNotEmpty && enteredAnswer.isNotEmpty) {
                  Navigator.pop(context, {'enteredQuestion': enteredQuestion, 'enteredAnswer': enteredAnswer});
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}