import 'package:flutter/material.dart';
import '../main.dart';
import 'customer.dart';
import 'customer_database.dart';
import 'customer_dao.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'AppLocalizations.dart';

/// Main localized app entry point with support for switching languages
class LocalizedApp extends StatefulWidget {
  const LocalizedApp({super.key});

  /// Allows language to be changed from anywhere in the app
  static void setLocale(BuildContext context, Locale newLocale) async {
    _LocalizedAppState? state =
        context.findAncestorStateOfType<_LocalizedAppState>();
    state?.changeLanguage(newLocale);
  }

  @override
  State<StatefulWidget> createState() {
    return _LocalizedAppState();
  }
}

/// Manages locale state and wraps MaterialApp with localization support
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
      supportedLocales: [Locale('en'), Locale('es')],
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

/// Main customer management screen
class CustomerListPage extends StatefulWidget {
  const CustomerListPage({super.key, required this.title});

  final String title;

  @override
  State<CustomerListPage> createState() => CustomerListPageState();
}

/// Handles customer list UI, input, and logic
class CustomerListPageState extends State<CustomerListPage> {
  bool showInstructions = false;

  late CustomerDatabase database;
  late CustomerDao customerDao;
  List<Customer> customers = [];

  final EncryptedSharedPreferences encryptedPrefs =
      EncryptedSharedPreferences();

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
    _loadInputs();
  }

  /// Initializes Floor database and fetches customers
  Future<void> _loadDatabase() async {
    database =
        await $FloorCustomerDatabase
            .databaseBuilder('customer_database.db')
            .build();
    customerDao = database.customerDao;

    if (mounted) {
      setState(() {});
      await _refreshCustomerList();
    }
  }

  /// Refreshes the list of customers from the database
  Future<void> _refreshCustomerList() async {
    final result = await customerDao.findAllCustomers();
    if (mounted) {
      setState(() {
        customers = result;
      });
    }
  }

  /// Saves current input field values securely
  Future<void> _saveInputs() async {
    await encryptedPrefs.setString(
      'firstName',
      _firstNameController.text.trim(),
    );
    await encryptedPrefs.setString('lastName', _lastNameController.text.trim());
    await encryptedPrefs.setString('address', _addressController.text.trim());
    await encryptedPrefs.setString('dob', _dobController.text.trim());
  }

  /// Loads saved input field values on app start
  Future<void> _loadInputs() async {
    String? firstName = await encryptedPrefs.getString('firstName');
    String? lastName = await encryptedPrefs.getString('lastName');
    String? address = await encryptedPrefs.getString('address');
    String? dob = await encryptedPrefs.getString('dob');

    setState(() {
      _firstNameController.text = firstName ?? '';
      _lastNameController.text = lastName ?? '';
      _addressController.text = address ?? '';
      _dobController.text = dob ?? '';
    });
  }

  /// Confirms and deletes the selected customer
  void deleteSelectedCustomer() async {
    if (selectedCustomer == null) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: Text(
            'Are you sure you want to delete ${selectedCustomer!.firstName} ${selectedCustomer!.lastName}?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await customerDao.deleteCustomer(selectedCustomer!);
                await _saveInputs();
                setState(() {
                  customers.remove(selectedCustomer);
                  selectedCustomer = null;
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Customer deleted')),
                );
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  ///updates the selected customers
  void showUpdateDialog(Customer customer) {
    final TextEditingController firstNameController = TextEditingController(
      text: customer.firstName,
    );
    final TextEditingController lastNameController = TextEditingController(
      text: customer.lastName,
    );
    final TextEditingController addressController = TextEditingController(
      text: customer.address,
    );
    final TextEditingController dobController = TextEditingController(
      text: customer.dob,
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Update Customer'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: firstNameController,
                  decoration: const InputDecoration(labelText: 'First Name'),
                ),
                TextField(
                  controller: lastNameController,
                  decoration: const InputDecoration(labelText: 'Last Name'),
                ),
                TextField(
                  controller: addressController,
                  decoration: const InputDecoration(labelText: 'Address'),
                ),
                TextField(
                  controller: dobController,
                  decoration: const InputDecoration(labelText: 'Date of Birth'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cancel
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final updatedCustomer = Customer(
                  customer.id, // preserve the original ID
                  firstNameController.text.trim(),
                  lastNameController.text.trim(),
                  addressController.text.trim(),
                  dobController.text.trim(),
                );

                await customerDao.updateCustomer(updatedCustomer);
                await _refreshCustomerList();

                setState(() {
                  selectedCustomer = null;
                });

                Navigator.of(context).pop(); // close the dialog first

                // then show snackbar after dialog closes
                Future.microtask(() {
                  ScaffoldMessenger.of(this.context).showSnackBar(
                    const SnackBar(content: Text('Customer updated')),
                  );
                });
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  void updateSelectedCustomer() {
    if (selectedCustomer == null) return;
    showUpdateDialog(selectedCustomer!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(AppLocalizations.of(context)!.translate('customer_list')!),
        actions: [
          OutlinedButton(
            child: Text(AppLocalizations.of(context)!.translate('english')!),
            onPressed: () {
              LocalizedApp.setLocale(context, const Locale('en'));
            },
          ),
          OutlinedButton(
            child: Text(AppLocalizations.of(context)!.translate('spanish')!),
            onPressed: () {
              LocalizedApp.setLocale(context, const Locale('es'));
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: responsiveLayout(),
      ),
    );
  }

  /// Adjusts UI layout based on orientation screen size
  Widget responsiveLayout() {
    var size = MediaQuery.of(context).size;
    var height = size.height;
    var width = size.width;

    if ((width > height) && (width > 720.0)) {
      /// Landscape layout with list and detail panes
      return Row(
        children: [
          Expanded(flex: 1, child: buildListView()),
          Expanded(flex: 1, child: buildDetailsPane()),
        ],
      );
    } else {
      if (selectedCustomer == null) {
        return buildListView();
      } else {
        return buildDetailsPane();
      }
    }
  }

  /// Instructions panel content
  Widget buildInstructionsContent(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.translate('instructions') ??
                  'Instructions',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              AppLocalizations.of(context)!.translate('instructions_body') ??
                  'Dialog body here.',
              textAlign: TextAlign.justify,
              style: const TextStyle(fontSize: 16, ),
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
                child: Text(
                  AppLocalizations.of(context)!.translate('ok') ?? 'OK',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Displays customer detail pane
  Widget buildDetailsPane() {
    if (selectedCustomer == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${AppLocalizations.of(context)!.translate('first_name')}: ${selectedCustomer!.firstName}",
              style: const TextStyle(fontSize: 20),
            ),
            Text(
              "${AppLocalizations.of(context)!.translate('last_name')}: ${selectedCustomer!.lastName}",
              style: const TextStyle(fontSize: 20),
            ),
            Text(
              "${AppLocalizations.of(context)!.translate('address')}: ${selectedCustomer!.address}",
              style: const TextStyle(fontSize: 20),
            ),
            Text(
              "${AppLocalizations.of(context)!.translate('dob')}: ${selectedCustomer!.dob}",
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      selectedCustomer = null;
                    });
                  },
                  child: Text(
                    AppLocalizations.of(context)!.translate('close')!,
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: deleteSelectedCustomer,
                  child: Text(
                    AppLocalizations.of(context)!.translate('delete')!,
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: updateSelectedCustomer,
                  child: Text(
                    AppLocalizations.of(context)!.translate('update')!,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Main UI for listing customers and adding new ones
  Widget buildListView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Input fields for customer info
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _firstNameController,
                decoration: InputDecoration(
                  labelText:
                      AppLocalizations.of(context)!.translate('first_name')!,
                ),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: TextField(
                controller: _lastNameController,
                decoration: InputDecoration(
                  labelText:
                      AppLocalizations.of(context)!.translate('last_name')!,
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
                  labelText:
                      AppLocalizations.of(context)!.translate('address')!,
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

        /// Add customer button
        ElevatedButton(
          onPressed: () async {
            final firstName = _firstNameController.text.trim();
            final lastName = _lastNameController.text.trim();
            final address = _addressController.text.trim();
            final dob = _dobController.text.trim();

            if (firstName.isEmpty ||
                lastName.isEmpty ||
                address.isEmpty ||
                dob.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    AppLocalizations.of(context)!.translate('fill_all_fields')!,
                  ),
                ),
              );
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
            await _saveInputs();
            await _refreshCustomerList();

            _firstNameController.clear();
            _lastNameController.clear();
            _addressController.clear();
            _dobController.clear();

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  AppLocalizations.of(context)!.translate('customer_added')!,
                ),
              ),
            );
          },
          child: Text(AppLocalizations.of(context)!.translate('add')!),
        ),
        const SizedBox(height: 16),

        /// Customer list
        Expanded(
          child:
              customers.isEmpty
                  ? Center(
                    child: Text(
                      AppLocalizations.of(context)!.translate('no_customers')!,
                    ),
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

        /// Instructions toggle + navigation home
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
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder:
                        (_) => MaterialApp(
                          debugShowCheckedModeBanner: false,
                          title: 'Back to Main',
                          theme: ThemeData(
                            colorScheme: ColorScheme.fromSeed(
                              seedColor: Colors.deepPurple,
                            ),
                          ),
                          home: const MyHomePage(
                            title: 'CST2335 Final Group Project',
                          ),
                          routes: {
                            '/home':
                                (context) => const MyHomePage(
                                  title: 'CST2335 Final Group Project',
                                ),
                            '/customer_list_page':
                                (context) => const LocalizedApp(),
                          },
                        ),
                  ),
                );
              },
              icon: Icon(Icons.house),
            ),
          ],
        ),
      ],
    );
  }
}
