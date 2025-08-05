import 'package:floor/floor.dart';

/// Represents an airplane entity with its properties.
@entity
class Airplane {
  /// Creates an [Airplane] instance with the given properties.
  /// Automatically updates the static ID counter if the provided id is greater
  /// than or equal to the current ID value.
  Airplane(this.id, this.model, this.passengers, this.maxSpeed, this.range) {
    if (id >= ID) {
      ID = id + 1;
    }
  }

  /// Static counter to keep track of the next available ID for new airplanes.
  static int ID = 1;

  /// The unique identifier for the airplane.
  @primaryKey
  final int id;

  /// The model name of the airplane (e.g., "Boeing 747").
  final String model;

  /// The maximum number of passengers the airplane can carry.
  final int passengers;

  /// The maximum speed of the airplane in km/h.
  final int maxSpeed;

  /// The maximum range of the airplane in kilometers.
  final int range;
}