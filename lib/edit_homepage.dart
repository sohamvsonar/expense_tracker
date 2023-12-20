import 'package:flutter/material.dart';
import 'database.dart';
import 'homepage.dart';

class EditDeckScreen extends StatefulWidget {
  final Deck deck;

  const EditDeckScreen({required this.deck});

  @override
  State<EditDeckScreen> createState() => _EditDeckScreenState(deck);
}

class _EditDeckScreenState extends State<EditDeckScreen> {
  final Deck deck;
  TextEditingController titleController = TextEditingController();

  _EditDeckScreenState(this.deck);

  @override
  void initState() {
    super.initState();
    titleController.text = deck.title;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Group'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Group Title'),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    saveDeckTitle();
                  },
                  child: const Text('Save'),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    deleteDeck();
                  },
                  child: const Text('Delete'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void saveDeckTitle() async {
    final dbHelper = DBHelper();
    await dbHelper.updateDeckTitle(deck.id!, titleController.text);
    Navigator.pop(context); 
  }

  void deleteDeck() async {
    final dbHelper = DBHelper();
    await dbHelper.deleteDeck(deck.id!);
    Navigator.pop(context); 
  }
}