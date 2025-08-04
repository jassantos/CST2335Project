import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'reservation_dao.dart'; //if structure changes, run flutter pub run build_runner build
import 'reservation_entity.dart';

///where the generated database code is
part 'reservation_database.g.dart';

@Database(version: 1, entities: [reservation_entity])
abstract class AppDatabase extends FloorDatabase {
  reservation_dao get dao;
}