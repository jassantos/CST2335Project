import 'package:floor/floor.dart';

@Entity(tableName: 'flights')
class Flight {
  @PrimaryKey(autoGenerate: true)
  final int? id;

  final String departure;      // city A
  final String destination;    // city B
  final String departureTime;  // HH:mm
  final String arrivalTime;    // HH:mm

  Flight({
    this.id,
    required this.departure,
    required this.destination,
    required this.departureTime,
    required this.arrivalTime,
  });
}
