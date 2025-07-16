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
        title: Text('Reservation Page'),
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