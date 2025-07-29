import 'package:flutter/material.dart';
import 'customer.dart';
import 'customer_database.dart';
import 'customer_dao.dart';
import 'customer_detail_page.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';

class CustomerListPage extends StatefulWidget {
  const CustomerListPage({Key? key}) : super(key: key);

  @override
  State<CustomerListPage> createState() => _CustomerListPageState();
}

class _CustomerListPageState extends State<CustomerListPage> {
  late CustomerDatabase database;
  late CustomerDao customerDao;
  List<Customer> customers = [];

  final EncryptedSharedPreferences encryptedPrefs = EncryptedSharedPreferences();

  // Controllers for the Add Customer Dialog
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();

  Customer? selectedCustomer;
  @override
  void initState() {
    super.initState();
    _loadDatabase();
    _loadSavedInputs();
  }

  Future<void> _loadDatabase() async {
    database = await $FloorCustomerDatabase.databaseBuilder('customer_database.db').build();
    customerDao = database.customerDao;

    if (mounted) {
      setState(() {

      });
      await _refreshCustomerList(); // Now refresh AFTER confirming we're mounted
    }
  }

  Future<void> _refreshCustomerList() async {
    final result = await customerDao.findAllCustomers();
    if (mounted) {
      setState(() {
        customers = result;
      });
    }
  }

  Future<void> _loadSavedInputs() async {
    try {
      _firstNameController.text = await encryptedPrefs.getString('firstName') ?? '';
      _lastNameController.text = await encryptedPrefs.getString('lastName') ?? '';
      _addressController.text = await encryptedPrefs.getString('address') ?? '';
      _dobController.text = await encryptedPrefs.getString('dob') ?? '';
    } catch (e) {
      // If first time, skip
    }
  }

  Future<void> _saveInputs() async {
    await encryptedPrefs.setString('firstName', _firstNameController.text.trim());
    await encryptedPrefs.setString('lastName', _lastNameController.text.trim());
    await encryptedPrefs.setString('address', _addressController.text.trim());
    await encryptedPrefs.setString('dob', _dobController.text.trim());
  }

  void _showAddCustomerDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Customer'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _firstNameController,
                decoration: const InputDecoration(labelText: 'First Name'),
              ),
              TextField(
                controller: _lastNameController,
                decoration: const InputDecoration(labelText: 'Last Name'),
              ),
              TextField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Address'),
              ),
              TextField(
                controller: _dobController,
                decoration: const InputDecoration(labelText: 'Date of Birth'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Clear all fields and close dialog
              _firstNameController.clear();
              _lastNameController.clear();
              _addressController.clear();
              _dobController.clear();
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
          onPressed: () async {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final address = _addressController.text.trim();
    final dob = _dobController.text.trim();

    if (firstName.isEmpty || lastName.isEmpty || address.isEmpty || dob.isEmpty) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Missing Fields'),
        content: const Text('Please fill in all fields before adding the customer.'),
        actions: [
          TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('OK'),
          ),
        ],
      ),
    );
    return;
    }

    // Close the dialog immediately
    Navigator.pop(context);


    final newCustomer = Customer.create(firstName, lastName, address, dob);
    await customerDao.insertCustomer(newCustomer);
    await _saveInputs();
    await _refreshCustomerList();


    _firstNameController.clear();
    _lastNameController.clear();
    _addressController.clear();
    _dobController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Customer added.')),
    );
    },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _openDetails(Customer customer) {
    final isWide = MediaQuery.of(context).size.width >= 600;

    if (isWide) {
      setState(() {
        selectedCustomer = customer;
      });
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CustomerDetailPage(
            customer: customer,
            onDelete: () async{
              await customerDao.deleteCustomer(customer);
              await _refreshCustomerList();
              setState(() {
                customers.remove(customer);
                selectedCustomer = null;
              });
            },
            onClose: () {
              setState(() {
                selectedCustomer = null;
              });
            },
            showClose: true,
          ),
        ),
      );
    }
  }

  void _showInstructions() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Instructions'),
        content: const Text(
          'Tap the "+" button to add a new customer.\n\n'
              'Select a customer to view details or delete.\n\n'
              'All data is saved to a local database.\n\n'
              'Tap the house button to go back to the main page. ',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget buildDetailsPane() {
    if (selectedCustomer == null) return const SizedBox.shrink();

    return Container(
      color: Colors.grey.shade100,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Name: ${selectedCustomer!.firstName} ${selectedCustomer!.lastName}", style: const TextStyle(fontSize: 20)),
          Text("Address: ${selectedCustomer!.address}", style: const TextStyle(fontSize: 18)),
          Text("DOB: ${selectedCustomer!.dob}", style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              setState(() {
                selectedCustomer = null;
              });
            },
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  Widget buildListView() {
    return ListView.builder(
      itemCount: customers.length,
      itemBuilder: (context, index) {
        final customer = customers[index];
        return ListTile(
          title: Text('${index + 1}: ${customer.firstName} ${customer.lastName}'),
          onTap: () => _openDetails(customer),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isWide = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _showInstructions,
          ),
        ],
      ),
      body: customers.isEmpty
          ? const Center(child: Text('No customers available.'))
          : isWide
          ? Row(
        children: [
          Expanded(child: buildListView()),
          Expanded(child: buildDetailsPane()),
        ],
      )
          : selectedCustomer != null
          ? buildDetailsPane()
          : buildListView(),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _showAddCustomerDialog,
            tooltip: 'Add Customer',
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false),
            tooltip: 'Back to Main',
            child: const Icon(Icons.home),
          ),
        ],
      ),
    );
  }
}
