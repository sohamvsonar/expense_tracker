import 'dart:convert';
import 'package:path/path.dart';
import 'package:provider/provider.dart';

import 'database.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter/material.dart';
import 'homepage.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  
  
  final dbHelper = DBHelper();

  await dbHelper.initDatabase();

  runApp(
    ChangeNotifierProvider(
      create: (context) => DBHelper(),
      child: MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DeckList(),
      ),
    ),
  );
}