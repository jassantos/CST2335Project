import 'package:floor/floor.dart';
import 'dart:async';
import 'flight.dart';
import 'flight_dao.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

part 'flight_database.g.dart';   // generated file

@Database(version: 1, entities: [Flight])
abstract class FlightDatabase extends FloorDatabase {
  FlightDao get flightDao;
}
