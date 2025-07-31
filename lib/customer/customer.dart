import 'package:floor/floor.dart';

@entity
class Customer {

  @primaryKey
  final int id;
  final String firstName;
  final String lastName;
  final String address;
  final String dob;

  static int ID = 1;

  Customer(this.id, this.firstName, this.lastName, this.address, this.dob) {
    if (this.id >= ID) {
      ID = this.id + 1;
    }
  }
}