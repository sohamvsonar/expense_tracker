import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mp5/friendspage.dart';
import 'homepage.dart';
import 'database.dart';

class EditFlashcardScreen extends StatefulWidget {
  final Flashcard flashcard;
  final Deck deck;
  const EditFlashcardScreen({required this.deck, required this.flashcard, super.key});

  @override
  State<EditFlashcardScreen> createState() => _EditFlashcardScreenState(flashcard, deck);
}

class _EditFlashcardScreenState extends State<EditFlashcardScreen> {
  final Flashcard flashcard;
  TextEditingController questionController = TextEditingController();
  TextEditingController answerController = TextEditingController();
  int? selectedFriendId;
  final Deck deck;
  _EditFlashcardScreenState(this.flashcard, this.deck);

  @override
  void initState() {
    super.initState();
    questionController.text = flashcard.flashcardTitle;
    answerController.text = flashcard.amount;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Expense'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: questionController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: answerController,
              decoration: const InputDecoration(labelText: 'Amount'),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}$')),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(width: 10),
                Expanded(
                  child: _buildPaidByDropdown(),
                  ), 
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        saveFlashcardContent();
                      },
                      child: const Text('Save'),
                    ), 
                  ),
                SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      deleteFlashcard();
                    },
                    child: const Text('Delete'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildPaidByDropdown() {
    final dbHelper = DBHelper();

    return FutureBuilder<List<Friend>>(
      future: dbHelper.getAllFriends(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(); 
        } else if (snapshot.hasError) {
          return Text('Error loading friends: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Text('No friends available'); 
        } else {
          return DropdownButtonFormField<int>(
            decoration: const InputDecoration(labelText: 'Paid by'),
            value: selectedFriendId,
            items: snapshot.data!.map((friend) {
              return DropdownMenuItem<int>(
                value: friend.id,
                child: Text(friend.title),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedFriendId = value;
              });
            },
          );
        }
      },
    );
  }

  void saveFlashcardContent() async {
    if (selectedFriendId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a friend for "Paid by"'),
        ),
      );
      return;
    }

    final dbHelper = DBHelper();
    final newFlashcard = Flashcard(
      deckId: deck.id!,
      flashcardTitle: questionController.text,
      amount: answerController.text,
      paidById: selectedFriendId,
      modifiedDate: DateTime.now(),
    );
    await dbHelper.insertFlashcard(newFlashcard);
    Navigator.pop(context);
  }

  void deleteFlashcard() async {
    final dbHelper = DBHelper();
    await dbHelper.deleteFlashcard(flashcard.id!);
    Navigator.pop(context); 
  }
}

