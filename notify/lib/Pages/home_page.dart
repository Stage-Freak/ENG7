import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notify/Pages/primary_button.dart';
import 'package:http/http.dart' as http;
import 'CurrentLocationMapPage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

final TextEditingController dateInput = TextEditingController();
final TextEditingController timeInput = TextEditingController();

class _HomePageState extends State<HomePage> {

  @override
  void initState() {
    super.initState();
    dateInput.text =
        DateFormat('yyyy-MM-dd').format(DateTime.now()); // Initial date
    timeInput.text = DateFormat('HH:mm').format(DateTime.now()); // Initial time
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Home",
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 26,
            fontFamily: 'Judson',
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF98C28C),
      ),
      body: SingleChildScrollView(
        child: Column(
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
                    StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: FirebaseFirestore.instance
                          .collection('Collector')
                          .orderBy('pickupDateTime', descending: true)
                          .limit(1)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const CircularProgressIndicator(); // Show loading indicator
                        } else if (snapshot.hasError) {
                          return Center(child: Text('Error: ${snapshot.error}'));
                        } else if (!snapshot.hasData || snapshot.data?.docs.isEmpty == true) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.only(top: 50.0),
                              child: Column(
                                children: [
                                  Image(
                                    image: AssetImage('assets/images/Schedule.png'),
                                    width: 100,
                                    height: 100,
                                  ),
                                  Text(
                                    'No Pickup Scheduled currently.',
                                    style: TextStyle(
                                      fontFamily: 'Judson',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        } else {
                          final collector = snapshot.data!.docs.first;
                          var pickupDateTime = collector.data()['pickupDateTime'];
                          final additionalData = collector.data()['additionalData'];

                          print('pickupDateTime: $pickupDateTime');
                          print('additionalData: $additionalData');

                          if (pickupDateTime is Timestamp) {
                            String dateStr = additionalData['Date'];
                            String timeStr = additionalData['Time'];

                            DateTime scheduledDate = DateFormat('yyyy-MM-dd').parse(dateStr);
                            DateTime scheduledTime = DateFormat('HH:mm').parse(timeStr);
                            DateTime now = DateTime.now();

                            Duration remainingDuration = scheduledDate.difference(now);
                            Duration remainingTimeDuration = now.difference(scheduledTime); // Corrected line

                            int remainingDay = remainingDuration.inDays;
                            int remainingHour = remainingTimeDuration.inHours.remainder(24);

                            print('Scheduled Date: $scheduledDate');
                            print('Current DateTime: $now');
                            print('Remaining Days: $remainingDay');
                            print('Remaining Hours: $remainingHour');



                            return Expanded(
                              child: ListView(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Column(
                                      children: [
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            'Scheduled Date: ${DateFormat('yyyy-MM-dd').format(scheduledDate)}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w900,
                                              fontSize: 18,
                                              fontFamily: 'Judson',
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            'Scheduled Time: ${DateFormat('HH:mm').format(scheduledTime)}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w900,
                                              fontSize: 18,
                                              fontFamily: 'Judson',
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 20,
                                        ),
                                        const Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            'Remaining time for pickup:',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                              fontFamily: 'Judson',
                                            ),
                                          ),
                                        ),
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            '$remainingDay days and $remainingHour hours',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                              fontFamily: 'Judson',
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          } else {
                            return const Center(
                              child: Text(
                                'No pickup scheduled currently!',
                                style: TextStyle(
                                  fontFamily: 'Judson',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            );
                          }
                        }
                      },
                    ),
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
              onTap: () async {


                CollectionReference collRef =
                FirebaseFirestore.instance.collection('Collector');
                collRef.add({
                  'pickupDateTime': Timestamp.fromDate(DateTime.now()),
                  'additionalData': {
                    'Date': dateInput.text.toString(),
                    'Time': timeInput.text.toString(),
                  },
                });


                // Notifications
                List<String> tokens =  [
                  'dbcjdbcdsjcbjsdbcjbdsjcbjdbcjbfvconcdsncbidbckdsnckdscjbjsbdjvbjdbcjdbvjbdjvcbjbvjbcjbdjcvbjbvjbvjfdbvjbdvjbfjdvbjbvjdbvjdjvbjfdvbjdbvj',
                  'cPTtS_1zTxKIoCwyxA_Cv6:APA91bEBvLK7lkAMoXR3_TXBaqIMmXPM2J8h2HnCQy2aig2xHSqstd4Wq8F288PaOH3r86V3PElKDFeQShZDU-Tt5CEhhv0gvfoYYD6LWC0KYhx2-5acof1USZah8FRZgdOWE8-m4V03',
                  'fCN-9gBHSCurUdH0mubBnm:APA91bF6tQXyiH0-qj6xig1yOILKyWhtXJGh5W-wlvHS6EstMhnFWrcPlqCej8Iyalz36owJYOu2lkl6vgWoat74vbUSla2N7CO0GrvwpnUoLMq-ucLi5YF2bwOLq2jQMbps917uIFnS',
                  'fvJXr7ViSyaYs0JPTsXxxd:APA91bEbun0aZqbBPsqZwsXNoo0pTDGlNg9_z7M3HPAQKzPL2d1Wcp2WHMcjmp-Q2ZVUHFyQv-177yyz9VQ3sWPqTeopsBOZroMwOb5glT1jFcDH1TmcnIPJ60JZeG-yhphkmk7-B0oU'
              ];

                await Future.forEach(tokens, (String token) async {
                  print(token);
                  var data = {
                    'to': token,
                    'priority': 'high',
                    'notification': {
                      'title': 'Pickup Scheduled',
                      'body':
                      'Garbage pickup scheduled for ${formatDateForNotification(dateInput.text)} at ${timeInput.text}',
                    },
                    'data': {
                      'type' : 'schedule'
                    }
                  };

                  await http.post(
                    Uri.parse('https://fcm.googleapis.com/fcm/send'),
                    body: jsonEncode(data),
                    headers: {
                      'Content-Type': 'application/json; charset=utf-8',
                      'Authorization':
                      'key=AAAARfaUx0c:APA91bHgHAhID9O6SitasqynYPSqZEW_LUPiOcDDBKs7yA7CfrEYnC45flZ_YxjwNOQPyzJkuYswEtjRpCGTHYEEd9pEB7IO0lCQ4c-WUB0dDKqI5NQc5VUKsGV27FTa9UHtsYu64mjb',
                    },
                  );
                });
              },
              buttonText: "Schedule",
            ),


            const SizedBox(height: 30,),
            PrimaryButton(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CurrentLocationMapPage()));
              }, buttonText: 'Start Pickup Service',)
          ],
        ),
      ),
    );
  }

  String formatDateForNotification(String inputDate) {
    DateTime parsedDate = DateTime.parse(inputDate);
    String formattedDate = DateFormat('dd MMM yyyy').format(parsedDate);
    return formattedDate;
  }
}