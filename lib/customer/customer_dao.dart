import 'package:floor/floor.dart';
import 'customer.dart';

@dao
abstract class CustomerDao{
  @Query('SELECT * FROM Customer')
  Future<List<Customer>> findAllCustomers();

  @Query('SELECT * FROM Item WHERE id = :id')
  Stream<Customer?> findCustomerById(int id);

  @insert
  Future<void> insertCustomer(Customer customer);

  @update
  Future<void> updateCustomer(Customer customer);

  @delete
  Future<void> deleteCustomer(Customer customer);
}