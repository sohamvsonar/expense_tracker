import 'dart:async';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'homepage.dart';
import 'friendspage.dart';
import 'edit_friendspage.dart';

class DBHelper extends ChangeNotifier{
  static const String _databaseName = 'Expenses.db';
  static const int _databaseVersion = 2;
  final _totalAmountController = StreamController<Map<int, double>>.broadcast();

  DBHelper._();
  static final DBHelper _singleton = DBHelper._();
  factory DBHelper() => _singleton;

  Database? _database;

  Future<List<Deck>> getAllDecks() async {
    final db = await this.db;
    final List<Map<String, dynamic>> maps = await db!.query('deck');
    
    return List.generate(maps.length, (index) {
      return Deck(
        id: maps[index]['id'],
        title: maps[index]['title'],
      );
    });
  }

  Map<int, double> _totalAmount = {};

  Map<int, double> get totalAmount => _totalAmount;

  Future<void> updateTotalAmount() async {
    _totalAmount = await getTotalAmountByDeck();
    notifyListeners();
  }
  
  Future<Map<int, double>> getTotalAmountByDeck() async {

    final db = await this.db;

    if(db==null){
      return {};
    }

    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT d.id, SUM(CAST(f.amount AS REAL)) AS totalAmount
      FROM deck d
      LEFT JOIN flashcard f ON d.id = f.deck_id
      GROUP BY d.id
    ''');

    return Map<int, double>.fromIterable(
      result,
      key: (item) => item['id'] as int,
      value: (item) => item['totalAmount'] as double? ?? 0.0,
    );
  }

  Future<List<Flashcard>> getFlashcardsByDeckId(int deckId) async {
    final db = await this.db;
    final List<Map<String, dynamic>> maps = await db!.query(
      'flashcard',
      where: 'deck_id = ?',
      whereArgs: [deckId],
    );

    return List.generate(maps.length, (index) {
      return Flashcard(
        id: maps[index]['id'],
        deckId: maps[index]['deck_id'],
        flashcardTitle: maps[index]['title'],
        amount: maps[index]['amount'],
      );
    });
  }

  Future<Database?> get db async {
    _database ??= await initDatabase();
    return _database;
  }

  Future<Database> initDatabase() async {
    var dbDir = await getApplicationDocumentsDirectory();
    var dbPath = path.join(dbDir.path, _databaseName);

    print(dbPath);

    var db = await openDatabase(
      dbPath,
      version: _databaseVersion,
      onCreate: _onCreate,
    );

    return db;
  }
  Future<List<Friend>> getAllFriends() async {
    final db = await this.db;
    final List<Map<String, dynamic>> maps = await db!.query('friend');

    return List.generate(maps.length, (index) {
      return Friend(
        id: maps[index]['id'],
        title: maps[index]['title'],
      );
    });
  }


  Future<Friend?> getFriendById(int friendId) async {
    final db = await this.db;
    final List<Map<String, dynamic>> maps = await db!.query(
      'friend',
      where: 'id = ?',
      whereArgs: [friendId],
    );

    if (maps.isNotEmpty) {
      return Friend(
        id: maps[0]['id'],
        title: maps[0]['title'],
      );
    } 
    return null;
  }

  Future<int?> getPaidById(int flashcardId) async {
    final db = await this.db;
    final List<Map<String, dynamic>> maps = await db!.query(
      'flashcard',
      columns: ['paidById'],
      where: 'id = ?',
      whereArgs: [flashcardId],
    );

    if (maps.isNotEmpty) {
      return maps[0]['paidById'] as int;
    }
    return null;
  }

  Future<int> insertFriend(Friend friend) async {
    final db = await this.db;
    int id = await db!.insert(
      'friend',
      friend.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return id;
  }
  void _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE deck(
        id INTEGER PRIMARY KEY,
        title TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE friend(
        id INTEGER PRIMARY KEY,
        title TEXT,
        totalAmount REAL DEFAULT 0.0
      )
    ''');

    await db.execute('''
    INSERT INTO friend (title) VALUES ('me')
    ''');
    
    await db.execute('''
      CREATE TABLE flashcard(
        id INTEGER PRIMARY KEY,
        deck_id INTEGER,
        title TEXT,
        amount TEXT,
        paidById INTEGER, 
        FOREIGN KEY (deck_id) REFERENCES deck(id),
        FOREIGN KEY (paidById) REFERENCES friend(id)  
      )
    ''');
  }


  Future<int> insertDeck(Deck deck) async {
    final db = await this.db;
    int id = await db!.insert(
      'deck',
      deck.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return id;
  }

  Future<int> insertFlashcard(Flashcard flashcard) async {
    final db = await this.db;
    int id = await db!.insert(
      'flashcard',
      flashcard.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return id;
  }

  Future<void> updateDeckTitle(int deckId, String newTitle) async {
    final db = await this.db;
    await db!.update(
      'deck',
      {'title': newTitle},
      where: 'id = ?',
      whereArgs: [deckId],
    );
  }

  Future<void> deleteDeck(int deckId) async {
    final db = await this.db;
    await db!.delete(
      'deck',
      where: 'id = ?',
      whereArgs: [deckId],
    );
  
    await db.delete(
      'flashcard',
      where: 'deck_id = ?',
      whereArgs: [deckId],
    );
  }

  Future<void> updateFlashcardContent(int flashcardId, String newflashcardTitle, String newAmount) async {
    final db = await this.db;
    await db!.update(
      'flashcard',
      {
        'title': newflashcardTitle,
        'amount': newAmount,
      },
      where: 'id = ?',
      whereArgs: [flashcardId],
    );
  }

  Future<void> deleteFlashcard(int flashcardId) async {
    final db = await this.db;
    await db!.delete(
      'flashcard',
      where: 'id = ?',
      whereArgs: [flashcardId],
    );
  }
  Future<void> updateFriendTitle(int friendId, String newTitle) async {
    final db = await this.db;
    await db!.update(
      'friend',
      {'title': newTitle},
      where: 'id = ?',
      whereArgs: [friendId],
    );
  }

  Future<void> deleteFriend(int friendId) async {
    final db = await this.db;
    await db!.delete(
      'friend',
      where: 'id = ?',
      whereArgs: [friendId],
    );
  }

 Future<void> updateTotalAmountByFriend(int? friendId) async {
  final db = await this.db;
  if (friendId != null) {
    final result = await db!.rawQuery('''
    UPDATE friend
    SET totalAmount = (
      SELECT SUM(CAST(f.amount AS REAL))
      FROM flashcard f
      WHERE f.paidById = ?
    )
    WHERE id = ?
    ''', [friendId, friendId]);
    notifyListeners();
  }
}

Future<double> getTotalAmountByFriend(int? friendId) async {
  final db = await this.db;
  if (friendId != null && friendId != 1) {
    final result = await db!.rawQuery('''
    SELECT SUM(CAST(f.amount AS REAL)) AS totalAmount
    FROM flashcard f
    WHERE f.paidById = ?
    ''', [friendId]);

    return (result.first['totalAmount'] as double?) ?? 0.0;
  }
  return 0.0;
}

}