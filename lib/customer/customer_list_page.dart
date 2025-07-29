import 'package:flutter/material.dart';
import 'customer.dart';
import 'customer_database.dart';
import 'customer_dao.dart';
import 'customer_detail_page.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'AppLocalizations.dart';

void main(){
  runApp(const LocalizedApp());
}
class LocalizedApp extends StatefulWidget {
  const LocalizedApp({super.key});

  static void setLocale(BuildContext context, Locale newLocale) async {
    _LocalizedAppState? state = context.findAncestorStateOfType<_LocalizedAppState>();
    state?.changeLanguage(newLocale);
  }

  @override
  State<LocalizedApp> createState(){
    return _LocalizedAppState();
  }
}

class _LocalizedAppState extends State<LocalizedApp> {
  Locale _locale = const Locale('en');

  void changeLanguage(Locale newLocale) {
    setState(() {
      _locale = newLocale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      supportedLocales: [
        Locale('en'),
        Locale('es'),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,

      ],
      locale: _locale,

      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context),
          child: child!,
        );
      },
      home: const CustomerListPage(title: 'Customer Home Page'),
    );
  }
}

class CustomerListPage extends StatefulWidget {
  const CustomerListPage({super.key, required this.title});

  final String title;
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
  }

  Future<void> _loadDatabase() async {
    database = await $FloorCustomerDatabase.databaseBuilder('customer_database.db').build();
    customerDao = database.customerDao;

    if (mounted) {
      setState(() {

      });
      await _refreshCustomerList();
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


  Future<void> _saveInputs() async {
    await encryptedPrefs.setString('firstName', _firstNameController.text.trim());
    await encryptedPrefs.setString('lastName', _lastNameController.text.trim());
    await encryptedPrefs.setString('address', _addressController.text.trim());
    await encryptedPrefs.setString('dob', _dobController.text.trim());
  }

  @override
  void dispose(){
    _firstNameController.dispose();
    _lastNameController.dispose();
    _addressController.dispose();
    _dobController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    bool isWide = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      appBar: AppBar( backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Customer List'),
        actions: [
          OutlinedButton(child:Text("English") , onPressed: (){  LocalizedApp.setLocale(context, Locale('en') );} ),
          OutlinedButton(child:Text("Spanish")  , onPressed: (){  LocalizedApp.setLocale(context, Locale('es') );} ),
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => buildInstructionsDialog(ctx),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: responsiveLayout(context),
        ),
      ),
      floatingActionButton: buildFloatingButtons(context),
    );

  }
  Widget responsiveLayout(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;

    if (customers.isEmpty) {
      return const Center(child: Text('No customers available.'));
    }

    if ((width > height) && (width > 720.0)) {
      return Row(
        children: [
          Expanded(child: buildListView()),
          Expanded(child: buildDetailsPane()),
        ],
      );
    } else {
      return selectedCustomer != null ? buildDetailsPane() : buildListView();
    }
  }

  Widget buildFloatingButtons(BuildContext context) {
    return Column(
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
    );
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

  Widget buildInstructionsDialog(BuildContext context) {
    final localizedText = AppLocalizations.of(context)?.translate("instructions_body") ?? "Instructions not available.";

    return AlertDialog(
      title: const Text("Instructions"),
      content: Text(localizedText),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("OK"),
        ),
      ],
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
}
