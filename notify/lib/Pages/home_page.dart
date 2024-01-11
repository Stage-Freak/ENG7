import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notify/Pages/primary_button.dart';
import 'package:notify/notificationServices.dart';
import 'package:http/http.dart' as http;


class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

final TextEditingController dateInput = TextEditingController();
final TextEditingController timeInput = TextEditingController();

class _HomePageState extends State<HomePage> {
  NotificationServices notificationServices = NotificationServices();

  @override
  void initState() {
    super.initState();
    notificationServices.requestNotificationPermission();
    notificationServices.firebaseInit();
    notificationServices.getDeviceToken().then((value) {
      print('Device token: $value');
    });
    dateInput.text =
        DateFormat('yyyy-MM-dd').format(DateTime.now()); // Initial date
    timeInput.text = DateFormat('HH:mm').format(DateTime.now()); // Initial time
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Schedule Pickup",
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 26,
            fontFamily: 'Judson',
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF98C28C),
      ),
      body: Column(
        children: [
          // Next Pickup
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              height: 300,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                color: Colors.grey[350],
              ),
              child: Column(
                children: [
                  Container(
                    height: 50,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10)),
                      color: Color(0xFF98C28C),
                    ),
                    child: const Center(
                      child: Text(
                        'Next Scheduled Pickup',
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                          fontFamily: 'Judson',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Date:',
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 18,
                                  fontFamily: 'Judson',
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Time: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 18,
                                  fontFamily: 'Judson',
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),

          // Schedule next pickup
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              height: 180,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                color: Colors.grey[300],
              ),
              child: Column(
                children: [
                  Container(
                    height: 50,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10)),
                      color: Color(0xFF98C28C),
                    ),
                    child: const Center(
                      child: Text(
                        'Schedule Next Pickup',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'Judson',
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: dateInput,
                      decoration: const InputDecoration(
                        icon: Icon(Icons.date_range_outlined),
                      ),
                      readOnly: true,
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );

                        if (pickedDate != null) {
                          String formattedDate =
                              DateFormat('yyyy-MM-dd').format(pickedDate);
                          setState(() {
                            dateInput.text = formattedDate;
                          });
                        } else {
                          // User canceled the date picking
                        }
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                    child: TextField(
                      controller: timeInput,
                      decoration: const InputDecoration(
                        icon: Icon(Icons.access_time),
                      ),
                      readOnly: true,
                      onTap: () async {
                        TimeOfDay? pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );

                        if (pickedTime != null) {
                          String formattedTime = pickedTime.format(context);
                          setState(() {
                            timeInput.text = formattedTime;
                          });
                        } else {
                          // User canceled the time picking
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(
            height: 20,
          ),

          PrimaryButton(
            onTap: () {
              CollectionReference collRef =
                  FirebaseFirestore.instance.collection('Collector');
              collRef.add({
                'pickupDateTime': {
                  'Date': dateInput.text.toString(),
                  'Time': timeInput.text.toString(),
                },
              });

              //Notifications
              notificationServices.getDeviceToken().then((value) async {
                var data = {
                  'to': value.toString(),
                  //'to': 'fCN-9gBHSCurUdH0mubBnm:APA91bF6tQXyiH0-qj6xig1yOILKyWhtXJGh5W-wlvHS6EstMhnFWrcPlqCej8Iyalz36owJYOu2lkl6vgWoat74vbUSla2N7CO0GrvwpnUoLMq-ucLi5YF2bwOLq2jQMbps917uIFnS',
                  'priority': 'high',
                  'notification': {
                    'title': 'Pickup Scheduled',
                    'body': 'Garbage pickup scheduled for ' +
                        formatDateForNotification(dateInput.text) +
                        ' at ' +
                        timeInput.text,
                  }
                };

                await http.post(
                  Uri.parse('https://fcm.googleapis.com/fcm/send'),
                  body: jsonEncode(data),
                  headers: {
                    'Content-Type': 'application/json; charset=utf-8',
                    'Authorization':
                        'key=AAAARfaUx0c:APA91bHgHAhID9O6SitasqynYPSqZEW_LUPiOcDDBKs7yA7CfrEYnC45flZ_YxjwNOQPyzJkuYswEtjRpCGTHYEEd9pEB7IO0lCQ4c-WUB0dDKqI5NQc5VUKsGV27FTa9UHtsYu64mjb'
                  },
                );
              });
            },
            buttonText: "Schedule",
          ),
        ],
      ),
    );
  }

  String formatDateForNotification(String inputDate) {
    DateTime parsedDate = DateTime.parse(inputDate);
    String formattedDate = DateFormat('dd MMM yyyy').format(parsedDate);
    return formattedDate;
  }
}
