
import 'package:floor/floor.dart';

@entity
class Airplane {
  Airplane(this.id, this.model, this.passengers, this.maxSpeed, this.range) {
    if (id >= ID) {
      ID = id + 1;
    }
  }

  static int ID = 1;

  @primaryKey
  final int id;

  final String model;
  final int passengers;
  final int maxSpeed;
  final int range;
}