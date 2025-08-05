import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'AirplaneDAO.dart';
import 'Airplane.dart';

part 'AirplaneDatabase.g.dart';

/// The main database class for the airplane application.
///
/// This abstract class extends [FloorDatabase] and provides access to the [AirplaneDAO].
/// The database version is currently 1 and it manages the [Airplane] entity.
@Database(version: 1, entities: [Airplane])
abstract class AirplaneDatabase extends FloorDatabase {
  /// Provides access to the airplane Data Access Object.
  AirplaneDAO get airplaneDAO;
}