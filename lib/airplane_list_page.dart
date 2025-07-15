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
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: Center(
            child: Column(
                children: [ Text("AirplaneList Page"),]
            )
        )
    );
  }

}