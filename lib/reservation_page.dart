import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Reservation extends StatefulWidget{
  const Reservation({super.key});
  @override
  State<Reservation> createState() => _ReservationState();
}

class _ReservationState extends State<Reservation>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: Center(
            child: Column(
                children: [ Text("Reservation Page"),]
            )
        )
    );
  }

}