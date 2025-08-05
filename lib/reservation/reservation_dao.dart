import 'package:floor/floor.dart';
import 'reservation_entity.dart';

@dao
///handles CRUD operations for reservation_entity object
abstract class reservation_dao {

  @Query('SELECT * FROM reservation_entity')
  Future<List<reservation_entity>> findAllReservation_Entities();

  @Query('SELECT * FROM reservation_entity WHERE id = :id')
  Stream<reservation_entity?> findReservation_EntitiesById(int id);

  @insert
  Future<void> insertReservation(reservation_entity reservation);
}
