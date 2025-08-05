
import 'package:floor/floor.dart';
import 'Airplane.dart';

@dao
abstract class AirplaneDAO {
  @Query('SELECT * FROM Airplane')
  Future<List<Airplane>> getAllAirplanes();
  @Query('SELECT * FROM Item WHERE id = :id')
  Stream<Airplane?> findAirplaneById(int id);
  @insert
  Future<void> insertAirplane(Airplane airplane);

  @update
  Future<void> updateAirplane(Airplane airplane);

  @delete
  Future<void> deleteAirplane(Airplane airplane);
}