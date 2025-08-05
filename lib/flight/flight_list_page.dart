import 'package:flutter/material.dart';
import 'flight.dart';
import 'flight_database.dart';
import 'flight_dao.dart';

class FlightList extends StatefulWidget {
  const FlightList({super.key});

  @override
  State<FlightList> createState() => _FlightListState();
}

class _FlightListState extends State<FlightList> {
  late FlightDatabase db;
  late FlightDao dao;
  List<Flight> flights = [];

  final _depC = TextEditingController();
  final _dstC = TextEditingController();
  final _depTC = TextEditingController();
  final _arrTC = TextEditingController();

  Flight? selected;

  @override
  void initState() {
    super.initState();
    _initDb();
  }

  Future<void> _initDb() async {
    db = await $FloorFlightDatabase
        .databaseBuilder('flight_database.db')
        .build();
    dao = db.flightDao;
    await _refresh();
  }

  Future<void> _refresh() async {
    flights = await dao.findAllFlights();
    if (mounted) setState(() {});
  }

  // ---------- CRUD ----------
  Future<void> _add() async {
    if ([_depC, _dstC, _depTC, _arrTC].any((c) => c.text.trim().isEmpty)) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Fill all fields')));
      return;
    }
    final flight = Flight(
      departure: _depC.text.trim(),
      destination: _dstC.text.trim(),
      departureTime: _depTC.text.trim(),
      arrivalTime: _arrTC.text.trim(),
    );
    await dao.insertFlight(flight);
    _depC.clear();
    _dstC.clear();
    _depTC.clear();
    _arrTC.clear();
    await _refresh();
  }

  Future<void> _delete(Flight f) async {
    await dao.deleteFlight(f);
    selected = null;
    await _refresh();
  }

  Future<void> _update(Flight original, Flight updated) async {
    await dao.updateFlight(updated);
    selected = null;
    await _refresh();
  }
  // ---------------------------

  Widget _field(String label, TextEditingController c) =>
      TextField(controller: c, decoration: InputDecoration(labelText: label));

  void _showEditDialog(Flight f) {
    final dep = TextEditingController(text: f.departure);
    final dst = TextEditingController(text: f.destination);
    final depT = TextEditingController(text: f.departureTime);
    final arrT = TextEditingController(text: f.arrivalTime);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Update Flight'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              _field('Departure', dep),
              _field('Destination', dst),
              _field('Departure Time', depT),
              _field('Arrival Time', arrT),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: Navigator.of(context).pop,
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final updated = Flight(
                id: f.id,
                departure: dep.text.trim(),
                destination: dst.text.trim(),
                departureTime: depT.text.trim(),
                arrivalTime: arrT.text.trim(),
              );
              _update(f, updated);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Navigator.canPop(context)
            ? IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        )
            : null,
        title: const Text('Flight List Page'),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            tooltip: 'Go Home',
            onPressed: () => Navigator.pushNamedAndRemoveUntil(
              context,
              '/',
                  (_) => false,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: selected == null ? _buildList() : _buildDetails(),
      ),
    );
  }

  // -------- list view ----------
  Widget _buildList() => Column(
    children: [
      Row(
        children: [
          Expanded(child: _field('Departure', _depC)),
          const SizedBox(width: 12),
          Expanded(child: _field('Destination', _dstC)),
        ],
      ),
      const SizedBox(height: 12),
      Row(
        children: [
          Expanded(child: _field('Departure Time', _depTC)),
          const SizedBox(width: 12),
          Expanded(child: _field('Arrival Time', _arrTC)),
        ],
      ),
      const SizedBox(height: 12),
      ElevatedButton(onPressed: _add, child: const Text('Add Flight')),
      const SizedBox(height: 16),
      Expanded(
        child: flights.isEmpty
            ? const Center(child: Text('No flights yet'))
            : ListView.builder(
          itemCount: flights.length,
          itemBuilder: (_, i) {
            final f = flights[i];
            return ListTile(
              title: Text('${f.departure} → ${f.destination}'),
              onTap: () => setState(() => selected = f),
            );
          },
        ),
      ),
    ],
  );

  // -------- detail view ----------
  Widget _buildDetails() {
    final f = selected!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Departure: ${f.departure}', style: const TextStyle(fontSize: 18)),
        Text('Destination: ${f.destination}', style: const TextStyle(fontSize: 18)),
        Text('Departure Time: ${f.departureTime}',
            style: const TextStyle(fontSize: 18)),
        Text('Arrival Time: ${f.arrivalTime}',
            style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 24),
        Row(
          children: [
            ElevatedButton(
              onPressed: () => setState(() => selected = null),
              child: const Text('Close'),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: () => _showEditDialog(f),
              child: const Text('Update'),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: () => _delete(f),
              child: const Text('Delete'),
            ),
          ],
        ),
      ],
    );
  }
}
