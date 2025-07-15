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

  /*
  String  getString( {  int a = 0, double b=0.0, bool c = false }){

    return "hello world";

  }*/

  @override
  Widget build(BuildContext context) {



    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
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
  double _counter = 0;
  late TextEditingController _controller; //this is to read what was typed



  var isChecked = false;

  @override
  void initState() { //similar to onloaded=
    super.initState();

    _controller = TextEditingController(); //making _controller
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose(); // free the memory of what was typed
  }

  void _incrementCounter() {
    setState(() {
      if(_counter<99.0)
        _counter++;
    });
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
         children: [ Text("hello world")]
        )
    )
    );
  }

  void setNewValue(double value)
  {
    setState(() {
      _counter = value;
    }); //update the GUI to new values
  }


  void buttonClicked(){

  }
}
