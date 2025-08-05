import 'package:floor/floor.dart';

@entity
class Customer {

  @primaryKey
  final int id;
  late final String firstName;
  late final String lastName;
  late final String address;
  late final String dob;

  static int ID = 1;

  Customer(this.id, this.firstName, this.lastName, this.address, this.dob) {
    if (this.id >= ID) {
      ID = this.id + 1;
    }
  }
}