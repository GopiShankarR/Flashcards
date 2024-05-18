import 'package:flutter/material.dart';

class AddDeck extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();

  AddDeck({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Deck'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Deck Name'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final enteredName = nameController.text;
                if (enteredName.isNotEmpty) {
                  Navigator.pop(context, enteredName);
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