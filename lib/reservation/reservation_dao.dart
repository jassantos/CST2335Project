import 'package:floor/floor.dart';
import 'reservation_entity.dart';

@dao
///handles CRUD operations for reservation_entity object
abstract class reservation_dao {

  @Query('SELECT * FROM reservation_entity')
  Future<List<reservation_entity>> findAllreservation_entities();

  @Query('SELECT * FROM reservation_entity WHERE id = :id')
  Stream<reservation_entity?> findreservation_entitiesById(int id);

  @insert
  Future<void> insertreservation(reservation_entity reservation);
}
