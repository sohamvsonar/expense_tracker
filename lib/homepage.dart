import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'activity.dart';
import 'database.dart';
import 'edit_homepage.dart';
import 'currencypage.dart';
import 'friendspage.dart';

class DeckList extends StatefulWidget {
  const DeckList({super.key});

  @override
  State<DeckList> createState() => _DeckListState();
}

class _DeckListState extends State<DeckList> {
  List<Deck> decks = []; 
  Map<int, double> deckTotalAmounts = {};

  @override
  void initState() {
    super.initState();
    loadDecks();
    updateTotalAmounts(); 
  }

  void updateTotalAmounts() async {
    final dbHelper = DBHelper();
    final totalAmounts = await dbHelper.getTotalAmountByDeck();
    await dbHelper.updateTotalAmount();

    setState(() {
      deckTotalAmounts = totalAmounts;
    });
  }
  void loadDecks() async {
    final dbHelper = DBHelper();
    final loadedDecks = await dbHelper.getAllDecks(); 

    setState(() {
      decks = loadedDecks;
    });
  }

@override
Widget build(BuildContext context) {
  final dbHelper = context.watch<DBHelper>();
  final deckTotalAmounts = dbHelper.totalAmount;
  final screenWidth = MediaQuery.of(context).size.width;

  int crossAxisCount = (screenWidth / 200).floor();
  crossAxisCount = crossAxisCount > 0 ? crossAxisCount : 1;

  double aspectRatio = 3;

  return Scaffold(
    appBar: AppBar(
      backgroundColor: Colors.black,
      title: Text(
        'Groups',
        style: TextStyle(
          color: Colors.white,
        ),
      ),
      actions: [],
    ),
    body: Stack(
      children: [
        GridView.count(
          crossAxisCount: crossAxisCount,
          padding: const EdgeInsets.all(8),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: aspectRatio,
          children: List.generate(decks.length, (index) => Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            color: Colors.lightGreen,
            child: Container(
              alignment: Alignment.center,
              child: Stack(
                children: [
                  InkWell(onTap: () {
                    navigateToFlashcardsScreen(decks[index]);
                  }),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(decks[index].title, style: TextStyle(fontSize: 20)),
                        Text(
                          '${deckTotalAmounts[decks[index].id] != null && deckTotalAmounts[decks[index].id]! > 0
                              ? 'Total Expense: ${deckTotalAmounts[decks[index].id]!}'
                              : 'No Expense'}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        navigateToEditDeck(decks[index]);
                      },
                    ),
                  ),
                ],
              ),
            ),
          )),
        ),
        if (decks.isEmpty)
          Positioned(
            bottom: 90,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.all(8),
              child: Text(
                "'Click here to add a new group'",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ),
          ),
      ],
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: () {
        navigateToAddDeck();
      },
      child: const Icon(Icons.add),
    ),
    bottomNavigationBar: BottomNavigationBar(
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.currency_exchange),
          label: 'Currencies',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people),
          label: 'Friends',
        ),
      ],
      currentIndex: 1,
      onTap: (index) {
        if (index == 0) {
          navigateToNewPage();
        } else if (index == 2) {
          navigateToFriends();
        }
      },
    ),
  );
}


  void navigateToFriends() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FriendsPage(), 
      ),
    );
  }

    void navigateToNewPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CurrencyPage(), 
      ),
    );
  }

  void navigateToAddDeck() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddDeckScreen(), 
      ),
    ).then((value) {
      loadDecks();
    });
  }

  void navigateToFlashcardsScreen(Deck deck) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FlashcardScreen(deck: deck),
      ),
    );
  }

  void navigateToEditDeck(Deck deck) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditDeckScreen(deck: deck),
      ),
    ).then((value) {
      loadDecks();
    });
  }
}

class Deck {
  int? id;
  String title;

  Deck({this.id, required this.title});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
    };
  }
}

class Flashcard {
  int? id;
  int deckId;
  String flashcardTitle;
  String amount;
  DateTime modifiedDate;
  int? paidById;

  Flashcard({this.id, required this.deckId, required this.flashcardTitle, required this.amount, modifiedDate, this.paidById}): modifiedDate = modifiedDate ?? DateTime.now();

  int? get selectedFriendId => null;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'deck_id': deckId,
      'title': flashcardTitle,
      'amount': amount,
      'paidById' : paidById,
    };
  }
}


class AddDeckScreen extends StatefulWidget {
  const AddDeckScreen({super.key});

  @override
  State<AddDeckScreen> createState() => _AddDeckScreenState();
}

class _AddDeckScreenState extends State<AddDeckScreen> {
  TextEditingController titleController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Group'),
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
            ElevatedButton(
              onPressed: () {
                saveDeckTitle();
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void saveDeckTitle() async {
    final dbHelper = DBHelper();
    final newDeck = Deck(title: titleController.text);
    await dbHelper.insertDeck(newDeck);
    Navigator.pop(context); 
  }
}