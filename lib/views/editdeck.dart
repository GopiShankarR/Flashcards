// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';

import '../models/decks.dart';

class EditDeck extends StatefulWidget {
  final List<DecksModel> data;
  final int index;

  const EditDeck(this.data, this.index, {super.key});

  @override
  _EditDeckState createState() => _EditDeckState();
}

class _EditDeckState extends State<EditDeck> {
  TextEditingController nameController = TextEditingController();

  @override
  void initState() {
    nameController.text = widget.data[widget.index].title;
    super.initState();
  }  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Deck'), centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                onChanged: (value) {
                  widget.data[widget.index].title = value;
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  child: const Text('Save'),
                  onPressed: () {
                    Navigator.pop(context, {'title': widget.data[widget.index].title, 'editedDeck': true});
                  },
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, {'title': '', 'editedDeck': false});
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