

import 'package:flutter/material.dart';
import 'package:notify/Pages/home_page.dart';
import 'package:notify/Pages/mapscreen.dart';
import 'package:notify/Pages/primary_button.dart';

class UserType extends StatelessWidget {
  const UserType({super.key});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
        body: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
               Image(image: AssetImage('assets/images/questions.png')),
              SizedBox(height: 20),
              Text(
                'What type of user are you?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 40,
                fontFamily: 'Judson',
                fontWeight: FontWeight.bold),),
              SizedBox(height: 120),
              PrimaryButton(buttonText: 'Collector', onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage()));
              }),
              SizedBox(height: 20,),
              PrimaryButton(buttonText: 'Thrower', onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MapScreen()));
              }),
            ],
          ),
        ),
    );
  }
}
