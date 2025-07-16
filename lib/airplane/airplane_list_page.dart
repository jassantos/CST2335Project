import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AirplaneList extends StatefulWidget{
  const AirplaneList({super.key});
  @override
  State<AirplaneList> createState() => _AirplaneListState();
}

class _AirplaneListState extends State<AirplaneList>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Airplane List Page'),
        actions: [
          IconButton(
            icon: Icon(Icons.help),
            onPressed: (){},
          ),
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