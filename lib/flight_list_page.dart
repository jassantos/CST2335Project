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
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: Center(
            child: Column(
                children: [ Text("FlightList Page"),]
            )
        )
    );
  }

}