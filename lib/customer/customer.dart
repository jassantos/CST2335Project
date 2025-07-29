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
    if (id >= ID) {
      ID = id + 1;
    }
  }
  factory Customer.create(String firstName, String lastName, String address, String dob) {
    final newCustomer = Customer(ID, firstName, lastName, address, dob);
    return newCustomer;
  }
}