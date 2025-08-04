import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import 'customer.dart';
import 'customer_dao.dart';

part 'customer_database.g.dart';

@Database(version: 1, entities: <Type>[Customer])
abstract class CustomerDatabase extends FloorDatabase{
  CustomerDao get customerDao;
}