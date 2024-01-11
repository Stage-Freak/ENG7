

import 'package:flutter/material.dart';
import 'package:notify/Pages/primary_button.dart';
import 'package:notify/Pages/user_type.dart';

class OnBoarding2 extends StatelessWidget {
  const OnBoarding2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const Image(image: AssetImage('assets/images/map.png')),
          const Image(image: AssetImage('assets/images/rodeway.png')),
          const Center(
            child: Image(image: AssetImage('assets/images/truck.png')),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 650.0),
            child: Column(
              children: [
                const Padding(
                  padding:  EdgeInsets.only(left: 20.0),
                  child:  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('Track your',
                          style:  TextStyle(
                              color: Colors.black,
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Judson'
                          )),
                      Text('Garbage truck',
                          style:  TextStyle(
                              color: Colors.black,
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Judson'
                          )),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                PrimaryButton(buttonText: 'Next', onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => UserType()));
                }),
              ],
            ),
          )
        ],
      ),
    );
  }
}
