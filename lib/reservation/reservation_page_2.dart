import 'package:flutter/material.dart';
import 'package:my_flutter_labs/reservation/reservation_database.dart';

class reservation_page_2 extends StatefulWidget {
  reservation_page_2(this.database, {super.key});
final AppDatabase database;



  @override
  State<reservation_page_2> createState() => reservation_page_2State();
  late List reservations;
}

class reservation_page_2State extends State<reservation_page_2>
{
  @override
  Widget build(BuildContext context) {

    return Scaffold(appBar: AppBar(title: Text("Reservation Page 2"),),
        body: ListPage(),
        floatingActionButton: Align( alignment: Alignment.bottomRight,
          child: Padding( padding: EdgeInsets.all(16),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
            FloatingActionButton(
            onPressed: () => Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/',
              (route) => false,

                ),
                child: const Icon(Icons.home),
                tooltip: 'Back to Main',
                ),
                FloatingActionButton(onPressed: () => Navigator.pushNamedAndRemoveUntil(
                context,
                '/reservation_page',
                (route) => false,

                ),
                child: Icon(Icons.airplane_ticket),
                tooltip: "Make a Reservation",)
                ]
                ),
          ),
        )
    );
  }

  getReservations() async {
    final dao = widget.database.dao;
    List reservations = await dao.findAllReservation_Entities();
    return reservations;
  }


  @override
  void initState() {
    super.initState();
    getReservations();
  }

  Widget ListPage() {
    List reservations = getReservations();
  return Column(
    children: [
      Expanded(child:
      ListView.builder( itemCount:reservations.length,
          itemBuilder: (context, rowNum) {  return
            Column(
              children: [
                GestureDetector(
                  onLongPress: () {
                    //revealDialog(rowNum);
                  },
                  child: Padding(padding: EdgeInsets.all(6), //padding is to give text a hitbox to tap
                    child: Text("Test"),

                  ),
                ),
              ],
            );
          }
      )
      )
    ],

  );



  }
}