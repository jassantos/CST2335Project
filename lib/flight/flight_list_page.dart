// lib/flight/flight_list_page.dart

import 'package:flutter/material.dart';
import '../main.dart';                       // MyApp + MyHomePage
import '../customer/AppLocalizations.dart'; // shared JSON-loader
import 'flight.dart';
import 'flight_database.dart';
import 'flight_dao.dart';

/// Flight list screen with ENG/ESP toggle, “?” help, and Home button.
/// All text comes from `assets/translations/{en,es}.json`.
class FlightListPage extends StatefulWidget {
  const FlightListPage({super.key});

  /// Allow language switching from inside this page
  static void setLocale(BuildContext context, Locale locale) {
    MyApp.setLocale(context, locale);
  }

  @override
  State<FlightListPage> createState() => _FlightListPageState();
}

class _FlightListPageState extends State<FlightListPage> {
  // ────────── DB ──────────
  late FlightDatabase _db;
  late FlightDao      _dao;

  // ────────── UI state ──────────
  final _depC  = TextEditingController();
  final _dstC  = TextEditingController();
  final _depTC = TextEditingController();
  final _arrTC = TextEditingController();

  List<Flight> _flights = [];
  Flight?      _selected;

  @override
  void initState() {
    super.initState();
    _openDb();
  }

  Future<void> _openDb() async {
    _db  = await $FloorFlightDatabase
        .databaseBuilder('flight_database.db')
        .build();
    _dao = _db.flightDao;
    _refreshFlights();
  }

  Future<void> _refreshFlights() async {
    final list = await _dao.findAllFlights();
    if (!mounted) return;
    setState(() => _flights = list);
  }

  void _insert() async {
    if ([_depC, _dstC, _depTC, _arrTC].any((c) => c.text.trim().isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!
                .translate('fill_fields') ??
                'Fill all fields',
          ),
        ),
      );
      return;
    }
    await _dao.insertFlight(
      Flight(
        departure     : _depC.text.trim(),
        destination   : _dstC.text.trim(),
        departureTime : _depTC.text.trim(),
        arrivalTime   : _arrTC.text.trim(),
      ),
    );
    _clearFields();
    _refreshFlights();
  }

  void _update(Flight f) async {
    await _dao.updateFlight(f);
    _refreshFlights();
  }

  void _delete(Flight f) async {
    await _dao.deleteFlight(f);
    if (_selected?.id == f.id) _selected = null;
    _refreshFlights();
  }

  void _clearFields() {
    _depC.clear();
    _dstC.clear();
    _depTC.clear();
    _arrTC.clear();
  }

  void _showEditDialog(Flight flight) {
    final dep     = TextEditingController(text: flight.departure);
    final dst     = TextEditingController(text: flight.destination);
    final depTime = TextEditingController(text: flight.departureTime);
    final arrTime = TextEditingController(text: flight.arrivalTime);
    final loc     = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(loc.translate('update') ?? 'Update'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildText(dep, loc.translate('departure') ?? 'Departure'),
              _buildText(dst, loc.translate('destination') ?? 'Destination'),
              _buildText(depTime, loc.translate('departure_time') ?? 'Departure Time'),
              _buildText(arrTime, loc.translate('arrival_time') ?? 'Arrival Time'),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: Text(loc.translate('cancel') ?? 'Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: Text(loc.translate('save') ?? 'Save'),
            onPressed: () {
              final updated = Flight(
                id           : flight.id,
                departure    : dep.text.trim(),
                destination  : dst.text.trim(),
                departureTime: depTime.text.trim(),
                arrivalTime  : arrTime.text.trim(),
              );
              _update(updated);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildText(TextEditingController c, String hint) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: TextField(
        controller: c,
        decoration: InputDecoration(labelText: hint),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(loc.translate('flight_list') ?? 'Flight List'),
        actions: [
          OutlinedButton(
            onPressed: () => FlightListPage.setLocale(context, const Locale('en')),
            child: Text(loc.translate('english') ?? 'English'),
          ),
          const SizedBox(width: 8),
          OutlinedButton(
            onPressed: () => FlightListPage.setLocale(context, const Locale('es')),
            child: Text(loc.translate('spanish') ?? 'Spanish'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Stack(
        children: [
          _selected == null
              ? _buildListView(loc)
              : _buildDetailsView(loc),

          // help “?” at bottom-left
          Positioned(
            left: 8,
            bottom: 8,
            child: IconButton(
              icon: const Icon(Icons.help),
              onPressed: () => _showHelpDialog(loc),
            ),
          ),

          // 🏠 home at bottom-center
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              minimum: const EdgeInsets.only(bottom: 8),
              child: IconButton(
                iconSize: 28,
                icon: const Icon(Icons.house),
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (_) => const MyHomePage(title: 'CST2335 Final Group Project'),
                    ),
                        (_) => false,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListView(AppLocalizations loc) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _depC,
                  decoration: InputDecoration(labelText: loc.translate('departure') ?? 'Departure'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _dstC,
                  decoration: InputDecoration(labelText: loc.translate('destination') ?? 'Destination'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _depTC,
                  decoration: InputDecoration(labelText: loc.translate('departure_time') ?? 'Departure Time'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _arrTC,
                  decoration: InputDecoration(labelText: loc.translate('arrival_time') ?? 'Arrival Time'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _insert,
            child: Text(loc.translate('add_flight') ?? 'Add Flight'),
          ),
          const SizedBox(height: 24),
          _flights.isEmpty
              ? Text(loc.translate('no_flights') ?? 'No flights available.')
              : ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: _flights.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (_, i) {
              final f = _flights[i];
              return ListTile(
                title: Text('${f.departure} → ${f.destination}'),
                subtitle: Text('${f.departureTime} → ${f.arrivalTime}'),
                onTap: () => setState(() => _selected = f),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsView(AppLocalizations loc) {
    final f = _selected!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${f.departure} → ${f.destination}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('${loc.translate('departure_time') ?? 'Departure Time'}: ${f.departureTime}'),
          Text('${loc.translate('arrival_time')   ?? 'Arrival Time'}:   ${f.arrivalTime}'),
          const SizedBox(height: 24),
          Row(
            children: [
              ElevatedButton(
                child: Text(loc.translate('close') ?? 'Close'),
                onPressed: () => setState(() => _selected = null),
              ),
              const SizedBox(width: 12),
              ElevatedButton( child: Text(loc.translate('update') ?? 'Update'), onPressed: () => _showEditDialog(f)),
              const SizedBox(width: 12),
              ElevatedButton( child: Text(loc.translate('delete') ?? 'Delete'), onPressed: () => _delete(f)),
            ],
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(AppLocalizations loc) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(loc.translate('help_ttl') ?? 'Instructions'),
        content: Text(loc.translate('help_txt') ??
            'Fill all fields and tap “Add Flight”.\n'
                'Tap a row to view, Update or Delete.\n'
                'Use the language toggle for English / Spanish.'),
        actions: [
          TextButton(
            child: Text(loc.translate('close') ?? 'Close'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _depC.dispose();
    _dstC.dispose();
    _depTC.dispose();
    _arrTC.dispose();
    _db.close();
    super.dispose();
  }
}
