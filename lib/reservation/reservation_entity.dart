import 'package:floor/floor.dart';

@entity
///the object being sent to the database
class reservation_entity {

  @primaryKey
  ///the actual id going into the database
  final int databaseId;

  ///keeps track of the next available id
  static int setterId = 1;

  ///ensures that only unique IDs go into the database
  reservation_entity(this.databaseId) {
    if (databaseId >= setterId) {
      setterId = databaseId + 1;
    }
  }
}