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
        title: Text('Customer List Page'),
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