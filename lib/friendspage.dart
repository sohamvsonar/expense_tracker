import 'package:flutter/material.dart';
import 'database.dart';
import 'edit_friendspage.dart';

class FriendsPage extends StatefulWidget {
  @override
  _FriendsPageState createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  List<Friend> friends = [];

  @override
  void initState() {
    super.initState();
    loadFriends();
  }

  void loadFriends() async {
    final dbHelper = DBHelper();
    final loadedFriends = await dbHelper.getAllFriends();
    final filteredFriends = loadedFriends.where((friend) => friend.title.toLowerCase() != 'me').toList(); 
    
    for (var friend in filteredFriends) {
      friend.totalAmount = await dbHelper.getTotalAmountByFriend(friend.id);
    }
    setState(() {
      friends = filteredFriends;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = screenWidth ~/ 200;
    crossAxisCount = crossAxisCount > 0 ? crossAxisCount : 1;

    return Scaffold(
      appBar: AppBar(
        title: Text('Friends', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Color.fromARGB(255, 43, 28, 19),
        iconTheme: IconThemeData(color: Colors.white), 
      ),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: 4,
        ),
        itemCount: friends.length,
        itemBuilder: (context, index) {
          final friend = friends[index];
          if (friend.title.toLowerCase() == 'me') {
            return Container();
          }

          return GestureDetector(
              onTap: () {
              if (friend.title.toLowerCase() != 'me') {
                navigateToEditFriend(friend);
              }
              },
            child: Card(
              elevation: 4,
              color: Color.fromARGB(192, 135, 62, 214),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ), 
              child: Container(
                alignment: Alignment.bottomLeft,
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      friend.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    SizedBox(height: 8),
                    if (friend.title.toLowerCase() != 'me')
                      friend.totalAmount != 0.0
                        ? Text(
                            'You owe ${friend.title} : \$${friend.totalAmount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          )
                        : Text(
                            'No Expense',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
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
          navigateToAddFriend();
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.teal, 
      ),
    );
  }

  void navigateToAddFriend() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddFriendScreen(),
      ),
    ).then((value) {
      loadFriends();
    });
  }

  void navigateToEditFriend(Friend friend) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditFriendScreen(friend: friend),
      ),
    ).then((value) {
      loadFriends();
    });
  }
}


class Friend {
  int? id;
  String title;
  double totalAmount;
  Friend({this.id, required this.title, this.totalAmount = 0.0});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'totalAmount': totalAmount,      
    };
  }
}
