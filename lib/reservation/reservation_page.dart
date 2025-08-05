import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_flutter_labs/reservation/reservation_database.dart';
import 'package:my_flutter_labs/reservation/reservation_page_2.dart';
import 'reservation_dao.dart';
import 'reservation_entity.dart';
import 'reservation_database.dart';

///Francesca's reservation page
class Reservation extends StatefulWidget{
  const Reservation({super.key});
  @override
  State<Reservation> createState() => _ReservationState();
}

class _ReservationState extends State<Reservation>{

  late TextEditingController customerId;
  late TextEditingController flightId;
  late TextEditingController flightDate;
  late TextEditingController reservationName;
  late AppDatabase database;
  List<reservation_entity> items = [];
  bool isDbReady = false;

  void initState() {
    super.initState();
    buildDb();
    assignControllers();
    setState(() {
      isDbReady = true; // Notify UI that DB is ready
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isDbReady == false) {
      return Scaffold();
    }
    else {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reservation Page'),
        actions: [
        ],
      ),
      body: ReservationPage(),
      floatingActionButton: Column(children: [
       FloatingActionButton(
        onPressed: () => Navigator.pushNamed(
          context,
          '/',
              arguments: database,

        ),
        child: const Icon(Icons.home),
        tooltip: 'Back to Main',
      )
    ]
      )
        );
    }
  }

  void assignControllers() {
    customerId = TextEditingController();
    flightId = TextEditingController();
    flightDate = TextEditingController();
    reservationName = TextEditingController();
  }

  ///creates the database
  buildDb() async {
    database = await $FloorAppDatabase
        .databaseBuilder('app_database.db')
        .build();
  }

  addReservation() async {
    if (customerId.value.text != "" && flightId.value.text != "" &&
    flightDate.value.text != "" && reservationName.value.text != "") {
      final reservation = reservation_entity(customerId.value.text,
          flightId.value.text, flightDate.value.text, reservationName.value.text);
      final dao = database.dao;
      await dao.insertReservation(reservation);
      setState(() {
        customerId.text = "";
        flightId.text = "";
        flightDate.text = "";
        reservationName.text = "";
      });

    }
    else {
      revealDialog();
    }

  }

  revealDialog() {
    showDialog(context: context, builder: (BuildContext context) =>
        AlertDialog(title: Text("Invalid Submission"),
            content: Text("All fields must be filled to save a reservation."),
            actions: [
              FilledButton(onPressed: () {Navigator.pop(context);}, child: Text("Ok")),
            ]
        )
    );
  }

  ///builds ReservationPage
  Widget ReservationPage(){
    double padding = 20;
    double width = 400;
    setState(() {

    });
    return Column(
      children: [
        SizedBox( width: width,
          child: Row(
            children: [
              Expanded(
                  child: Padding(padding: EdgeInsets.all(padding),
                    child: TextField(decoration:
                    InputDecoration(hintText:"Type your customer ID"
                    ),
                      controller: customerId,
                    ),
                  )
              ),
            ],
          ),
        ),
        SizedBox( width: width,
          child: Row(
            children: [
              Expanded(
                  child: Padding(padding: EdgeInsets.all(padding),
                    child: TextField(decoration:
                    InputDecoration(hintText:"Type your flight ID"
                    ),
                      controller: flightId,
                    ),
                  )
              ),
            ],
          ),
        ),
        SizedBox( width: width,
          child: Row(
            children: [
              Expanded(
                  child: Padding(padding: EdgeInsets.all(padding),
                    child: TextField(decoration:
                    InputDecoration(hintText:"Type your flight date (yyyy/mm/ddd)"
                    ),
                      controller: flightDate,
                    ),
                  )
              ),
            ],
          ),
        ),
        SizedBox( width: width,
          child: Row(
            children: [
              Expanded(
                  child: Padding(padding: EdgeInsets.all(padding),
                    child: TextField(decoration:
                    InputDecoration(hintText:"What do you want to call this reservation?"
                    ),
                      controller: reservationName,
                    ),
                  )
              ),
            ],
          ),
        ),
        ElevatedButton(onPressed: addReservation,
            child: Text("Add Reservation")),
        Expanded(child:
        ListView.builder( itemCount:items.length,
            itemBuilder: (context, rowNum) {  return
              Column(
                children: [
                     Padding(padding: EdgeInsets.all(6), //padding is to give text a hitbox to tap
                      child: Text("$rowNum: ${items[rowNum]} quantity: ${items[rowNum]}"),

                    ),
                ],
              );
            }
        )
        ),
      ],
    );
  }
}