import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image(image: AssetImage('assets/images/logowow.png')),
            SizedBox(
              height: 10,
            ),
            Text(
              'wOw',
              style: TextStyle(
                  color: Colors.black87,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Judson'),
            ),
            Text(
              'Waste On Wheels',
              style: TextStyle(
                  color: Colors.black54,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Judson'),
            )
          ],
        ),
      ),
    );
  }
}
