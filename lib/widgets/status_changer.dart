import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../data_models/task_model.dart';
import '../db_helpers/task_db_helper.dart';

Widget statusChager(
    String status, String uniqueId, Task task, BuildContext context) {
  TasksDatabase test = TasksDatabase.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  if (status == "Active") {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        InkWell(
          onTap: () {
            var newData = Task(
                id: task.id,
                email: task.email,
                unique_id: task.unique_id,
                taskState: task.taskState,
                title: task.title,
                startDate: task.startDate,
                endDate: task.endDate,
                catagory: task.catagory,
                description: task.description,
                status: "Completed",
                updatedOn: task.updatedOn);

            log("clicked");
            test.changeStatus(newData);
            DocumentReference users = FirebaseFirestore.instance
                .collection('users')
                .doc(task.email)
                .collection(uniqueId)
                .doc(uniqueId);

            users.set({
              "email": task.email,
              "unique_id": task.unique_id,
              "taskState": task.taskState,
              "title": task.title,
              "startDate": task.startDate,
              "endDate": task.endDate,
              "catagory": task.catagory,
              "description": task.description,
              "status": "Completed",
              "updatedOn": task.updatedOn
            });
            DocumentReference deelteTask = FirebaseFirestore.instance
                .collection('users')
                .doc(task.email)
                .collection(task.unique_id)
                .doc(task.unique_id);
            Navigator.pop(context);
            pushHome(context);
          },
          child: Container(
            alignment: Alignment.center,
            height: 40,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.greenAccent),
            child: const Padding(
              padding: EdgeInsets.fromLTRB(30, 5, 30, 5),
              child: Text(
                "Completed",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
        InkWell(
          onTap: () {
            var newData = Task(
                id: task.id,
                email: task.email,
                unique_id: task.unique_id,
                taskState: task.taskState,
                title: task.title,
                startDate: task.startDate,
                endDate: task.endDate,
                catagory: task.catagory,
                description: task.description,
                status: "Paused",
                updatedOn: task.updatedOn);
            TasksDatabase test = TasksDatabase.instance;
            log("clicked");

            test.changeStatus(newData);
            DocumentReference users = FirebaseFirestore.instance
                .collection('users')
                .doc(task.email)
                .collection(uniqueId)
                .doc(uniqueId);

            users.set({
              "email": task.email,
              "unique_id": task.unique_id,
              "taskState": task.taskState,
              "title": task.title,
              "startDate": task.startDate,
              "endDate": task.endDate,
              "catagory": task.catagory,
              "description": task.description,
              "status": "Paused",
              "updatedOn": task.updatedOn
            });
            Navigator.pop(context);
            pushHome(context);
          },
          child: Container(
            alignment: Alignment.center,
            height: 40,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.orangeAccent),
            child: const Padding(
              padding: EdgeInsets.fromLTRB(30, 5, 30, 5),
              child: Text(
                "Pause",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ],
    );
  } else if (status == "Completed") {
    return Container();
  } else {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        InkWell(
          onTap: () {
            var newData = Task(
                id: task.id,
                email: task.email,
                unique_id: task.unique_id,
                taskState: task.taskState,
                title: task.title,
                startDate: task.startDate,
                endDate: task.endDate,
                catagory: task.catagory,
                description: task.description,
                status: "Active",
                updatedOn: task.updatedOn);
            TasksDatabase test = TasksDatabase.instance;
            log("clicked");
            test.changeStatus(newData);
            DocumentReference users = FirebaseFirestore.instance
                .collection('users')
                .doc(task.email)
                .collection(uniqueId)
                .doc(uniqueId);

            users.set({
              "email": task.email,
              "unique_id": task.unique_id,
              "taskState": task.taskState,
              "title": task.title,
              "startDate": task.startDate,
              "endDate": task.endDate,
              "catagory": task.catagory,
              "description": task.description,
              "status": "Active",
              "updatedOn": task.updatedOn
            });
            Navigator.pop(context);
            pushHome(context);
          },
          child: Container(
            alignment: Alignment.center,
            height: 40,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.blueAccent),
            child: const Padding(
              padding: EdgeInsets.fromLTRB(15, 5, 15, 5),
              child: Text(
                "Activate",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

pushHome(BuildContext context) {
  Navigator.pushReplacementNamed(context, "/home");
}
