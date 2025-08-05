import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'AirplaneDAO.dart';
import 'AirplaneDatabase.dart';
import 'Airplane.dart';

/// A StatefulWidget that displays a list of airplanes and allows CRUD operations.
///
/// This widget manages the airplane list state and provides interfaces for:
/// - Viewing airplane details
/// - Adding new airplanes
/// - Editing existing airplanes
/// - Deleting airplanes
///
/// The layout adapts to screen size, showing a master-detail view on wide screens.
class AirplaneList extends StatefulWidget {
  const AirplaneList({super.key});

  @override
  State<AirplaneList> createState() => _AirplaneListState();
}

/// The state class for [AirplaneList] that manages the airplane data and UI state.
class _AirplaneListState extends State<AirplaneList> {
  final List<Airplane> _airplanes = [];
  Airplane? _selectedAirplane;
  int? _selectedIndex;
  late AirplaneDAO airplaneDAO;
  final EncryptedSharedPreferences _encryptedPrefs = EncryptedSharedPreferences();
  String _lastModel = '';
  bool _showAddPage = false;
  bool _showEditPage = false;

  @override
  void initState() {
    super.initState();
    _loadLastModel();
    _initializeDatabase();
  }

  /// Loads the last airplane model used from encrypted shared preferences.
  Future<void> _loadLastModel() async {
    _lastModel = await _encryptedPrefs.getString('last_airplane_model') ?? '';
  }

  /// Initializes the database and loads existing airplanes.
  Future<void> _initializeDatabase() async {
    final database = await $FloorAirplaneDatabase
        .databaseBuilder('airplane_database.db')
        .build();
    airplaneDAO = database.airplaneDAO;
    final airplanes = await airplaneDAO.getAllAirplanes();

    setState(() {
      _airplanes.addAll(airplanes);
      if (_airplanes.isNotEmpty) {
        Airplane.ID = _airplanes.last.id + 1;
      }
    });
  }

  /// Builds the add airplane page widget.
  ///
  /// Returns a [Scaffold] with form fields for entering new airplane details.
  Widget _buildAddPage() {
    final modelController = TextEditingController(); // No pre-population
    final passengersController = TextEditingController();
    final speedController = TextEditingController();
    final rangeController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Airplane'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            setState(() {
              _showAddPage = false;
            });
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: modelController,
                decoration: const InputDecoration(
                  labelText: 'Model',
                  hintText: 'e.g., Boeing 747',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passengersController,
                decoration: const InputDecoration(
                  labelText: 'Passengers',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: speedController,
                decoration: const InputDecoration(
                  labelText: 'Max Speed (km/h)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: rangeController,
                decoration: const InputDecoration(
                  labelText: 'Range (km)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  if (modelController.text.isEmpty ||
                      passengersController.text.isEmpty ||
                      speedController.text.isEmpty ||
                      rangeController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please fill all fields')));
                    return;
                  }

                  final newAirplane = Airplane(
                    Airplane.ID++,
                    modelController.text,
                    int.parse(passengersController.text),
                    int.parse(speedController.text),
                    int.parse(rangeController.text),
                  );

                  await airplaneDAO.insertAirplane(newAirplane);
                  await _encryptedPrefs.setString(
                      'last_airplane_model', modelController.text);

                  setState(() {
                    _airplanes.add(newAirplane);
                    _showAddPage = false;
                    if (MediaQuery.of(context).size.width > 600) {
                      _selectedAirplane = newAirplane;
                      _selectedIndex = _airplanes.length - 1;
                    }
                  });

                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('${modelController.text} added successfully')));
                },
                child: const Text('Add Airplane'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the edit airplane page widget.
  ///
  /// Returns a [Scaffold] with form fields pre-populated with the selected airplane's data.
  Widget _buildEditPage() {
    final modelController = TextEditingController(text: _selectedAirplane?.model);
    final passengersController =
    TextEditingController(text: _selectedAirplane?.passengers.toString());
    final speedController =
    TextEditingController(text: _selectedAirplane?.maxSpeed.toString());
    final rangeController =
    TextEditingController(text: _selectedAirplane?.range.toString());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Airplane'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            setState(() {
              _showEditPage = false;
            });
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: modelController,
                decoration: const InputDecoration(
                  labelText: 'Model',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passengersController,
                decoration: const InputDecoration(
                  labelText: 'Passengers',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: speedController,
                decoration: const InputDecoration(
                  labelText: 'Max Speed (km/h)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: rangeController,
                decoration: const InputDecoration(
                  labelText: 'Range (km)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      final updatedAirplane = Airplane(
                        _selectedAirplane!.id,
                        modelController.text,
                        int.parse(passengersController.text),
                        int.parse(speedController.text),
                        int.parse(rangeController.text),
                      );

                      await airplaneDAO.updateAirplane(updatedAirplane);
                      setState(() {
                        _airplanes[_selectedIndex!] = updatedAirplane;
                        _selectedAirplane = updatedAirplane;
                        _showEditPage = false;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('${updatedAirplane.model} updated successfully')));
                    },
                    child: const Text('Save Changes'),
                  ),
                  ElevatedButton(
                    onPressed: () => _confirmDelete(_selectedAirplane!),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text('Delete', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the details panel widget for the selected airplane.
  ///
  /// Returns a [Column] widget displaying the airplane's details and action buttons.
  Widget _buildDetailsPanel() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _selectedAirplane!.model,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Text('Passengers: ${_selectedAirplane!.passengers}'),
          Text('Max Speed: ${_selectedAirplane!.maxSpeed} km/h'),
          Text('Range: ${_selectedAirplane!.range} km'),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _showEditPage = true;
                  });
                },
                child: const Text('Edit'),
              ),
              ElevatedButton(
                onPressed: () => _confirmDelete(_selectedAirplane!),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: const Text('Delete', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Shows a confirmation dialog for airplane deletion.
  ///
  /// [airplane] The airplane to be deleted
  Future<void> _confirmDelete(Airplane airplane) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete ${airplane.model}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      await airplaneDAO.deleteAirplane(airplane);
      setState(() {
        _airplanes.removeAt(_selectedIndex!);
        _selectedAirplane = null;
        _selectedIndex = null;
        _showEditPage = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${airplane.model} deleted successfully')));
    }
  }

  /// Shows instructions dialog explaining how to use the app.
  void _showInstructions() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Instructions'),
          content: const Text('1. Tap + to add a new airplane\n'
              '2. Tap an airplane to view details\n'
              '3. Edit or delete airplanes from the details view'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_showAddPage) {
      return _buildAddPage();
    }

    if (_showEditPage && _selectedAirplane != null) {
      return _buildEditPage();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Airplane List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help),
            onPressed: _showInstructions,
          ),
        ],
      ),
      body: _buildAirplaneList(),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              setState(() {
                _showAddPage = true;
              });
            },
            tooltip: 'Add Airplane',
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            onPressed: () => Navigator.pushNamedAndRemoveUntil(
              context,
              '/',
                  (route) => false,
            ),
            child: const Icon(Icons.home),
            tooltip: 'Back to Main',
          ),
        ],
      ),
    );
  }

  /// Builds the airplane list widget.
  ///
  /// Returns a responsive layout that shows either:
  /// - A master-detail view on wide screens (>600px)
  /// - A simple list view on narrow screens
  Widget _buildAirplaneList() {
    if (_airplanes.isEmpty) {
      return const Center(
        child: Text('No airplanes in fleet'),
      );
    }

    final isWideScreen = MediaQuery.of(context).size.width > 600;

    if (isWideScreen) {
      return Row(
        children: [
          Expanded(
            flex: 1,
            child: ListView.builder(
              itemCount: _airplanes.length,
              itemBuilder: (context, index) {
                final airplane = _airplanes[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  color: _selectedIndex == index
                      ? Theme.of(context).colorScheme.primaryContainer
                      : null,
                  child: ListTile(
                    title: Text(airplane.model),
                    subtitle: Text('Passengers: ${airplane.passengers}'),
                    trailing: Text('${airplane.maxSpeed} km/h'),
                    onTap: () {
                      setState(() {
                        _selectedAirplane = airplane;
                        _selectedIndex = index;
                      });
                    },
                  ),
                );
              },
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            flex: 2,
            child: _selectedAirplane != null
                ? _buildDetailsPanel()
                : const Center(child: Text('Select an airplane')),
          ),
        ],
      );
    } else {
      return ListView.builder(
        itemCount: _airplanes.length,
        itemBuilder: (context, index) {
          final airplane = _airplanes[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text(airplane.model),
              subtitle: Text('Passengers: ${airplane.passengers}'),
              trailing: Text('${airplane.maxSpeed} km/h'),
              onTap: () {
                setState(() {
                  _selectedAirplane = airplane;
                  _selectedIndex = index;
                  _showEditPage = true;
                });
              },
            ),
          );
        },
      );
    }
  }
}