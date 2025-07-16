import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FlightList extends StatefulWidget{
  const FlightList({super.key});
  @override
  State<FlightList> createState() => _FlightListState();
}

class _FlightListState extends State<FlightList>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flight List Page'),
        actions: [
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamedAndRemoveUntil(
          context,
          '/',
              (route) => false,
        ),
        child: const Icon(Icons.home),
        tooltip: 'Back to Main',
      ),
    );
  }
}