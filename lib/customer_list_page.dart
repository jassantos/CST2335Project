import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomerList extends StatefulWidget{
  const CustomerList({super.key});
  @override
  State<CustomerList> createState() => _CustomerListState();
}

class _CustomerListState extends State<CustomerList>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: Center(
            child: Column(
                children: [ Text("CustomerList Page"),]
            )
        )
    );
  }
  
}