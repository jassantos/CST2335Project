
import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'AirplaneDAO.dart';
import 'Airplane.dart';

part 'AirplaneDatabase.g.dart';

@Database(version: 1, entities: [Airplane])
abstract class AirplaneDatabase extends FloorDatabase {
  AirplaneDAO get airplaneDAO;
}