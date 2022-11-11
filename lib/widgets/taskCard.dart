import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Widget taskCard(Size size, String status, String taskState, String title,
    DateTime startDate, DateTime endDate, String catagory, String description) {
  String startDay = DateFormat('yyyy-MM-dd').format(startDate);
  String startTime = DateFormat('kk:mm').format(startDate);
  String endDay = DateFormat('yyyy-MM-dd').format(endDate);
  String endTime = DateFormat('kk:mm').format(endDate);

  return Card(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20.0),
    ),
    child: Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(15),
            child: Text(
              title,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 18),
            ),
          ),
          Container(
            decoration: BoxDecoration(
                color: taskState == "High"
                    ? const Color.fromARGB(255, 255, 215, 213)
                    : (taskState == "Normal"
                        ? Colors.blue[100]
                        : Colors.green[100]),
                borderRadius: BorderRadius.circular(20)
                ),
            child: Column(children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 15, top: 20),
                    child: Text(
                      taskState,
                      style: const TextStyle(
                          color: Color.fromARGB(255, 181, 55, 55),
                          fontWeight: FontWeight.bold,
                          fontSize: 14),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 15),
                    child: Text(
                      status,
                      style: const TextStyle(
                          color: Color.fromARGB(255, 181, 55, 55),
                          fontWeight: FontWeight.bold,
                          fontSize: 14),
                    ),
                  )
                ],
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 15, top: 10),
                        child: Text("Started on: $startDay"),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 15, top: 10),
                        child: Text("Time: $startTime"),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 15, top: 10),
                        child: Text("Due Date: $endDay"),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 15, top: 10),
                        child: Text("Time: $endTime"),
                      ),
                    ],
                  )
                ],
              ),
              Divider(),
              Padding(
                padding:
                    const EdgeInsets.only(left: 6.0, right: 6.0, bottom: 6.0),
                child: ExpansionTile(
                  title: const Text(
                    'Description',
                    style: TextStyle(color: Colors.black54),
                  ),
                  children: <Widget>[Text(description)],
                ),
              ),
            ]),
          )
        ],
      ),
    ),
  );
}
