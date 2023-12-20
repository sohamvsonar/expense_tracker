import 'package:flutter/material.dart';
import 'database.dart';
import 'friendspage.dart';

class AddFriendScreen extends StatefulWidget {
  @override
  State<AddFriendScreen> createState() => _AddFriendScreenState();
}

class _AddFriendScreenState extends State<AddFriendScreen> {
  TextEditingController titleController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Friend'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: 'Friend Name'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                saveFriendTitle();
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void saveFriendTitle() async {
    final dbHelper = DBHelper();
    final newFriend = Friend(title: titleController.text);
    await dbHelper.insertFriend(newFriend);
    Navigator.pop(context);
  }
}


class EditFriendScreen extends StatefulWidget {
  final Friend friend;

  const EditFriendScreen({required this.friend});

  @override
  State<EditFriendScreen> createState() => _EditFriendScreenState(friend);
}

class _EditFriendScreenState extends State<EditFriendScreen> {
  final Friend friend;
  TextEditingController titleController = TextEditingController();

  _EditFriendScreenState(this.friend);

  @override
  void initState() {
    super.initState();
    titleController.text = friend.title;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Friend'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Friend Title'),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    saveFriendTitle();
                  },
                  child: const Text('Save'),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    deleteFriend();
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

  void saveFriendTitle() async {
    final dbHelper = DBHelper();
    await dbHelper.updateFriendTitle(friend.id!, titleController.text);
    Navigator.pop(context);
  }

  void deleteFriend() async {
    final dbHelper = DBHelper();
    await dbHelper.deleteFriend(friend.id!);
    Navigator.pop(context);
  }
}
