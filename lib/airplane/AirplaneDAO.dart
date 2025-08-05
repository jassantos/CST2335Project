import 'package:floor/floor.dart';
import 'Airplane.dart';

/// Data Access Object for [Airplane] entities.
/// Provides methods to interact with the airplane database table.
@dao
abstract class AirplaneDAO {
  /// Retrieves all airplanes from the database.
  ///
  /// Returns a [Future] that completes with a list of all [Airplane] objects.
  @Query('SELECT * FROM Airplane')
  Future<List<Airplane>> getAllAirplanes();

  /// Finds an airplane by its ID.
  ///
  /// [id]: The ID of the airplane to find.
  /// Returns a [Stream] that emits the [Airplane] object when found, or null if not found.
  @Query('SELECT * FROM Airplane WHERE id = :id')
  Stream<Airplane?> findAirplaneById(int id);

  /// Inserts a new airplane into the database.
  ///
  /// [airplane]: The [Airplane] object to insert.
  /// Returns a [Future] that completes when the insertion is done.
  @insert
  Future<void> insertAirplane(Airplane airplane);

  /// Updates an existing airplane in the database.
  ///
  /// [airplane]: The [Airplane] object with updated values.
  /// Returns a [Future] that completes when the update is done.
  @update
  Future<void> updateAirplane(Airplane airplane);

  /// Deletes an airplane from the database.
  ///
  /// [airplane]: The [Airplane] object to delete.
  /// Returns a [Future] that completes when the deletion is done.
  @delete
  Future<void> deleteAirplane(Airplane airplane);
}