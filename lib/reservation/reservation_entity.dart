import 'package:floor/floor.dart';

@entity
///the object being sent to the database
class reservation_entity {

  @PrimaryKey(autoGenerate: true)

  String customerId = "null";

  String flightId = "null";

  String flightDate = "null";

  String reservationName = "null";

  ///constructor
  reservation_entity(this.customerId, this.flightId,
      this.flightDate, this.reservationName) {

  }
}