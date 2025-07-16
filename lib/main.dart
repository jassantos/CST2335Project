
import 'package:flutter/material.dart';
import 'airplane/airplane_list_page.dart';
import 'customer/customer_list_page.dart';
import 'flight/flight_list_page.dart';
import 'reservation/reservation_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CST2335 Final Group Project',
      initialRoute: '/',
      routes: {
        '/': (context) => const MyHomePage(title: 'CST2335 Final Group Project'),
        '/customer_list_page': (context) => const CustomerList(),
        '/airplane_list_page': (context) => const AirplaneList(),
        '/flight_list_page': (context) => const FlightList(),
        '/reservation_page': (context) => const Reservation(),
      },
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  void redirectCustomers(){
    Navigator.pop(context);
    Navigator.pushNamed(context, '/customer_list_page');
  }
  void redirectAirplanes(){
    Navigator.pop(context);
    Navigator.pushNamed(context, '/airplane_list_page');
  }
  void redirectFlights(){
    Navigator.pop(context);
    Navigator.pushNamed(context, '/flight_list_page');
  }
  void redirectReservation(){
    Navigator.pop(context);
    Navigator.pushNamed(context, '/reservation_page');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('CST2335 Final Group Project'),
        actions: [
          IconButton(
            icon: Icon(Icons.help),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Instructions'),
                  content: Text('Select one of the modules to manage different aspects of the system.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('OK'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: redirectCustomers,
                  child: Text('Customer'),
                ),
              ),
              SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: redirectAirplanes,
                  child: Text('Airplane'),
                ),
              ),
              SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: redirectFlights,
                  child: Text('Flight'),
                ),
              ),
              SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: redirectReservation,
                  child: Text('Reservation'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
