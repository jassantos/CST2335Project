import 'package:flutter/material.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'AirplaneDAO.dart';
import 'AirplaneDatabase.dart';
import 'Airplane.dart';

class AirplaneList extends StatefulWidget {
  const AirplaneList({super.key});

  @override
  State<AirplaneList> createState() => _AirplaneListState();
}

class _AirplaneListState extends State<AirplaneList> {
  final List<Airplane> _airplanes = [];
  late AirplaneDAO airplaneDAO;
  final EncryptedSharedPreferences _encryptedPrefs = EncryptedSharedPreferences();
  String _lastModel = '';

  @override
  void initState() {
    super.initState();
    _loadLastModel();
    _initializeDatabase();
  }

  Future<void> _loadLastModel() async {
    _lastModel = await _encryptedPrefs.getString('last_airplane_model') ?? '';
  }

  Future<void> _initializeDatabase() async {
    final database = await $FloorAirplaneDatabase.databaseBuilder('airplane_database.db').build();
    airplaneDAO = database.airplaneDAO;
    final airplanes = await airplaneDAO.getAllAirplanes();

    setState(() {
      _airplanes.addAll(airplanes);
      if (_airplanes.isNotEmpty) {
        Airplane.ID = _airplanes.last.id + 1;
      }
    });
  }

  void _showAddAirplaneDialog({bool copyPrevious = false}) {
    final modelController = TextEditingController();
    final passengersController = TextEditingController();
    final speedController = TextEditingController();
    final rangeController = TextEditingController();

    if (copyPrevious && _lastModel.isNotEmpty) {
      modelController.text = _lastModel;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Airplane'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: modelController,
                  decoration: const InputDecoration(
                    labelText: 'Model',
                    hintText: 'e.g., Boeing 747',
                  ),
                ),
                TextField(
                  controller: passengersController,
                  decoration: const InputDecoration(
                    labelText: 'Passengers',
                  ),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: speedController,
                  decoration: const InputDecoration(
                    labelText: 'Max Speed',
                    hintText: 'in km/h',
                  ),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: rangeController,
                  decoration: const InputDecoration(
                    labelText: 'Range',
                    hintText: 'in km',
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (modelController.text.isEmpty ||
                    passengersController.text.isEmpty ||
                    speedController.text.isEmpty ||
                    rangeController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please fill all fields'))
                  );
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
                await _encryptedPrefs.setString('last_airplane_model', modelController.text);

                setState(() {
                  _airplanes.add(newAirplane);
                });

                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${modelController.text} added successfully'))
                );
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _showAirplaneDetails(Airplane airplane, int index) {
    final modelController = TextEditingController(text: airplane.model);
    final passengersController = TextEditingController(text: airplane.passengers.toString());
    final speedController = TextEditingController(text: airplane.maxSpeed.toString());
    final rangeController = TextEditingController(text: airplane.range.toString());

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Airplane Details'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: modelController,
                  decoration: const InputDecoration(
                    labelText: 'Model',
                  ),
                ),
                TextField(
                  controller: passengersController,
                  decoration: const InputDecoration(
                    labelText: 'Passengers',
                  ),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: speedController,
                  decoration: const InputDecoration(
                    labelText: 'Max Speed',
                  ),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: rangeController,
                  decoration: const InputDecoration(
                    labelText: 'Range',
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await airplaneDAO.deleteAirplane(airplane);
                setState(() {
                  _airplanes.removeAt(index);
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${airplane.model} deleted successfully'))
                );
              },
              child: const Text('Delete',
                  style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () async {
                final updatedAirplane = Airplane(
                  airplane.id,
                  modelController.text,
                  int.parse(passengersController.text),
                  int.parse(speedController.text),
                  int.parse(rangeController.text),
                );

                await airplaneDAO.updateAirplane(updatedAirplane);
                setState(() {
                  _airplanes[index] = updatedAirplane;
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${airplane.model} updated successfully'))
                );
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  void _showInstructions() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Instructions'),
          content: const Text('1. Tap + to add a new airplane\n'
              '2. Tap an airplane to view/edit details\n'
              '3. Long press to delete an airplane'),
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
            onPressed: () => _showAddAirplaneDialog(),
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

  Widget _buildAirplaneList() {
    if (_airplanes.isEmpty) {
      return const Center(
        child: Text('No airplanes in fleet'),
      );
    }

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
            onTap: () => _showAirplaneDetails(airplane, index),
          ),
        );
      },
    );
  }
}