import 'package:flutter/material.dart';
import 'customer.dart';
import 'customer_database.dart';
import 'customer_dao.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'AppLocalizations.dart';

class LocalizedApp extends StatefulWidget {
  const LocalizedApp({super.key});

  static void setLocale(BuildContext context, Locale newLocale) async {
    _LocalizedAppState? state = context.findAncestorStateOfType<_LocalizedAppState>();
    state?.changeLanguage(newLocale);
  }

  @override
  State<StatefulWidget> createState(){
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
        GlobalCupertinoLocalizations.delegate,

      ],
      locale: _locale,

      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      builder: (context, child) {
        return child!;
      },
      home: const CustomerListPage(title: 'Customer Home Page'),
    );
  }
}

class CustomerListPage extends StatefulWidget {
  const CustomerListPage({super.key, required this.title});

  final String title;
  @override
  State<CustomerListPage> createState() => CustomerListPageState();
}

class CustomerListPageState extends State<CustomerListPage> {
  bool showInstructions = false;

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
    _saveInputs();
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

  void deleteSelectedCustomer() async {
    if (selectedCustomer != null) {
      await customerDao.deleteCustomer(selectedCustomer!);
      setState(() {
        customers.remove(selectedCustomer);
        selectedCustomer = null;
      });
    }
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(AppLocalizations.of(context)!.translate('customer_list')!),
        actions: [
          OutlinedButton(
              child: const Text("English"),
              onPressed: () {
                LocalizedApp.setLocale(context, const Locale('en'));
              }),
          OutlinedButton(
              child: const Text("Spanish"),
              onPressed: () {
                LocalizedApp.setLocale(context, const Locale('es'));
              }),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: responsiveLayout(), // just delegate to responsiveLayout
      ),

    );
  }

  Widget responsiveLayout()
  {

    var size = MediaQuery.of(context).size; // how big is the display?
    var height = size.height;  //double
    var width = size.width; //double

    if((width>height) && (width > 720.0)) //landscape
        {
      return Row(children: [
        Expanded(flex:1,  child:buildListView()  ), //Left side
        Expanded(flex:2,  child:buildDetailsPane()  )] //Right side
      );
    }
    else // portrait mode
        {
      if(selectedCustomer == null){ //nothing is selected
        return buildListView(); // let the user select something
      }
      else{  //something is selected:
        return buildDetailsPane();
      }
    }
  }


  Widget buildInstructionsContent(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
          padding: const EdgeInsets.all(16),
      child:
      Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.translate('instructions') ?? 'Instructions',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Text(
          AppLocalizations.of(context)!.translate('instructions_body') ?? 'Dialog body here.',
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              setState(() {
                showInstructions = false;
              });
            },
            child: Text(AppLocalizations.of(context)!.translate('ok') ?? 'OK'),
          ),
        ),
      ],
    )),
      );
  }


  Widget buildDetailsPane() {
    if (selectedCustomer == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      child: Container(
      color: Colors.grey.shade200,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("${AppLocalizations.of(context)!.translate('first_name')}: ${selectedCustomer!.firstName}",
            style: const TextStyle(fontSize: 20),
          ),Text("${AppLocalizations.of(context)!.translate('last_name')}: ${selectedCustomer!.lastName}",
            style: const TextStyle(fontSize: 20),
          ),Text("${AppLocalizations.of(context)!.translate('address')}: ${selectedCustomer!.address}",
            style: const TextStyle(fontSize: 20),
          ),Text("${AppLocalizations.of(context)!.translate('dob')}: ${selectedCustomer!.dob}",
            style: const TextStyle(fontSize: 20),
          ),const SizedBox(height: 20),
          Row(
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    selectedCustomer = null;
                  });
                },
                child: Text(AppLocalizations.of(context)!.translate('close')!),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                  onPressed: deleteSelectedCustomer,
                  child: Text(AppLocalizations.of(context)!.translate('delete')!)
              )
            ],
          )
        ],
      ),
    ));
  }

  Widget buildListView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _firstNameController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.translate('first_name')!,
                ),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: TextField(
                controller: _lastNameController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.translate('last_name')!,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.translate('address')!,
                ),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: TextField(
                controller: _dobController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.translate('dob')!,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: () async {
            final firstName = _firstNameController.text.trim();
            final lastName = _lastNameController.text.trim();
            final address = _addressController.text.trim();
            final dob = _dobController.text.trim();

            if (firstName.isEmpty || lastName.isEmpty || address.isEmpty || dob.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(AppLocalizations.of(context)!.translate('fill_all_fields')!),
              ));
              return;
            }

            final newCustomer = Customer(
              Customer.ID++,
              firstName,
              lastName,
              address,
              dob,
            );

            await customerDao.insertCustomer(newCustomer);
            await _refreshCustomerList();

            _firstNameController.clear();
            _lastNameController.clear();
            _addressController.clear();
            _dobController.clear();

            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(AppLocalizations.of(context)!.translate('customer_added')!),
            ));
          },
          child: Text(AppLocalizations.of(context)!.translate('add')!),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: customers.isEmpty
              ? Center(
            child: Text(AppLocalizations.of(context)!.translate('no_customers')!),
          )
              : ListView.builder(
            itemCount: customers.length,
            itemBuilder: (context, index) {
              final customer = customers[index];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedCustomer = customer;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Center(
                    child: Text(
                      "${index + 1}: ${customer.firstName} ${customer.lastName}",
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    icon: Icon(Icons.help),
                    onPressed: () {
                      setState(() {
                        showInstructions = !showInstructions;
                      });
                    },
                  ),
                  if (showInstructions) ...[
                    const SizedBox(height: 16),
                    buildInstructionsContent(context),
                  ],
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                // your logic here
              },
              icon: Icon(Icons.house),
            ),
          ],
        )
    ],
    );
  }
}

