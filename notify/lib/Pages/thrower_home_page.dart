import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notify/Pages/mapscreen.dart';
import 'package:notify/Pages/primary_button.dart';

class ThrowerHomePage extends StatefulWidget {
  const ThrowerHomePage({super.key});

  @override
  State<ThrowerHomePage> createState() => _ThrowerHomePagweState();
}

class _ThrowerHomePagweState extends State<ThrowerHomePage> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
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
      body: Column(
        children: [
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
                          Duration remainingTimeDuration = now.difference(scheduledTime);

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
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          'Remaining time for pickup:',
                                          style: const TextStyle(
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
          const SizedBox(height: 30),
          PrimaryButton(buttonText: 'Track Pickup Vehicle', onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MapScreen()));
          }),
        ],
      ),
    );
  }
}