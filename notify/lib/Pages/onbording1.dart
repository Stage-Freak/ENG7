import 'package:flutter/material.dart';
import 'package:notify/Pages/onboarding2.dart';
import 'package:notify/Pages/primary_button.dart';

class OnBoarding1 extends StatelessWidget {
  const OnBoarding1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const Image(image: AssetImage('assets/images/map.png')),
          const Center(
            child: Image(image: AssetImage('assets/images/bell.png')),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 620.0,),
            child: Column(
              children: [
               const Padding(
                  padding:  EdgeInsets.all(23.0),
                  child:     Text('Get Scheduled Date Notification',
                      style:  TextStyle(
                        color: Colors.black,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Judson'
                      )),
                ),
                const SizedBox(height: 20),
                PrimaryButton(buttonText: 'Next', onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => OnBoarding2()));
                }),
              ],
            ),
          )
        ],
      ),
    );
  }
}
