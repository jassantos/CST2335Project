
import 'package:flutter/material.dart';
import 'airplane_list_page.dart';
import 'customer_list_page.dart';
import 'flight_list_page.dart';
import 'reservation_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      initialRoute: '/',
      routes: {
        '/': (context) => const MyHomePage(title: 'Final Group Project'),
        '/customer_list_page': (context) => const CustomerList(),
        '/airplane_list_page': (context) => const AirplaneList(),
        '/flights_list_page': (context) => const FlightList(),
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
  }  void redirectFlights(){
    Navigator.pop(context);
    Navigator.pushNamed(context, '/flights_list_page');
  }  void redirectReservation(){
    Navigator.pop(context);
    Navigator.pushNamed(context, '/reservation_page');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title),
        ),
        body: Center(
        child: Column(
         children: [ Text("hello world"),
                  ElevatedButton(
                    onPressed: redirectCustomers,
                    child: const Text('Customers'),
                  ),
                  Spacer(),
                  ElevatedButton(
                    onPressed: redirectAirplanes,
                    child: const Text('Airplanes'),
                  ),
                  Spacer(),
                  ElevatedButton(
                    onPressed: redirectFlights,
                    child: const Text('Flights'),
                  ),
                  Spacer(),
                  ElevatedButton(
                    onPressed: redirectReservation,
                    child: const Text('Reservation'),
                  ),
                ]
            )
    ));
  }
}

