import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import 'homepage.dart';
import 'database.dart';
import 'edit_activitypage.dart';
import 'package:intl/intl.dart';
import 'friendspage.dart';

class FlashcardScreen extends StatefulWidget {
  final Deck deck;

  const FlashcardScreen({required this.deck, super.key});

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState(deck);
}

class _FlashcardScreenState extends State<FlashcardScreen> {
  final Deck deck;
  List<Flashcard> flashcards = []; 
  bool ascendingOrder = false;
  bool showAnswer = false;
  int x =1;

  _FlashcardScreenState(this.deck);

  @override
  void initState() {
    super.initState();
    loadFlashcards();
  }

  void loadFlashcards() async {
    final dbHelper = DBHelper();
    final loadedFlashcards = await dbHelper.getFlashcardsByDeckId(deck.id!);

    setState(() {
      flashcards = loadedFlashcards;
    });

    dbHelper.updateTotalAmount();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    int crossAxisCount = screenWidth ~/ 200;
    crossAxisCount = crossAxisCount > 0 ? crossAxisCount : 1;

    double aspectRatio = 2.5;
    return ChangeNotifierProvider.value(
      value: context.read<DBHelper>(),
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Activity', style: TextStyle(fontWeight: FontWeight.bold),),
            actions: <Widget>[],
          ),
          body: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: aspectRatio,
            ),
            itemCount: flashcards.length,
            itemBuilder: (context, index) {
              final flashcard = flashcards[index];
              return Card(
                color: const Color.fromARGB(255, 119, 193, 228),
                child: InkWell(
                  onTap: () {
                    navigateToEditFlashcard(flashcard);
                  },
                  child: Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment:Alignment.topRight,
                          child:
                            Text(
                              ' ${DateFormat.MMMd().format(flashcard.modifiedDate)}',
                              style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              ),
                            ),
                        ),                        
                        Text(
                          ' ${flashcard.flashcardTitle}',
                          style: const TextStyle(
                            color: Color.fromARGB(255, 81, 34, 18),
                            fontWeight: FontWeight.bold,
                            fontSize:20,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Amount Spent: \$${flashcard.amount}',
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        FutureBuilder<int?>(
                          future: DBHelper().getPaidById(flashcard.id!), 
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return Text('Error loading paidById: ${snapshot.error}');
                            } else {
                              final paidById = snapshot.data;
                              return FutureBuilder<String>(
                                future: getFriendTitle(paidById),
                                builder: (context, friendSnapshot) {
                                  if (friendSnapshot.connectionState == ConnectionState.waiting) {
                                    return CircularProgressIndicator();
                                  } else if (friendSnapshot.hasError) {
                                    return Text('Error loading friend title: ${friendSnapshot.error}');
                                  } else {
                                    final friendTitle = friendSnapshot.data ?? 'Unknown Friend';
                                    return Text(
                                      'Paid by: $friendTitle',
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    );
                                  }
                                },
                              );
                            }
                          },
                        ),                                              
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              navigateToAddFlashcard();
            },
            child: const Icon(Icons.add),
          ),
        ),
    );
  }

  Future<int?> _fetchPaidById(int? flashcardId) async {
    final dbHelper = DBHelper();
    final paidById = await dbHelper.getPaidById(flashcardId!);
    
    print('Paid by friend ID: $paidById');
    return paidById;
  }
  
  void navigateToAddFlashcard() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddFlashcardScreen(deck: deck), 
      ),
    ).then((value) {
      loadFlashcards();
    });
  }

  void shuffleFlashcards() {
    final random = Random();
    flashcards.shuffle(random);
  }

  void toggleShowAnswer() {
    setState(() {
      showAnswer = !showAnswer;
    });
  }


  void navigateToEditFlashcard(Flashcard flashcard) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditFlashcardScreen(flashcard: flashcard,deck: deck),
      ),
    ).then((value) {
      loadFlashcards();
    });
  }
  
  Future<String> getFriendTitle(int? friendId) async {
    if (friendId != null) {
      final dbHelper = DBHelper();
      final friend = await dbHelper.getFriendById(friendId);
      return friend?.title ?? 'Unknown Friend';
    } else {
      return 'Unknown Friend';
    }
  }  
}


class AddFlashcardScreen extends StatefulWidget {
  final Deck deck;

  const AddFlashcardScreen({required this.deck, super.key});

  @override
  State<AddFlashcardScreen> createState() => _AddFlashcardScreenState(deck);
}

class _AddFlashcardScreenState extends State<AddFlashcardScreen> {
  final Deck deck;
  TextEditingController questionController = TextEditingController();
  TextEditingController answerController = TextEditingController(); 
  int? selectedFriendId;

  _AddFlashcardScreenState(this.deck);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Expense'),
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
            const SizedBox(height: 20),
            TextField(
              controller: answerController,
              decoration: const InputDecoration(labelText: 'Amount'),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}$')),
              ],
            ),
            const SizedBox(height: 20),
            _buildPaidByDropdown(),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                saveFlashcard();
              },
              child: const Text('Save'),
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


  void saveFlashcard() async {
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
    await dbHelper.updateTotalAmountByFriend(selectedFriendId);
    Navigator.pop(context);
  }
}
