

import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseApi{
  //create an instance of the Firebase messaging
  final _firebaseMessaging = FirebaseMessaging.instance;
  //function to initialize notification
  Future<void> initializeNotification() async {
    // request permission from user (will prompt user)
    await _firebaseMessaging.requestPermission();

    //fetch the FCM token for this device
    final fCMToken = await _firebaseMessaging.getToken();

    // print the token
    print('Token is : $fCMToken');
  }

  //function to handle received messages
void handleMessage(RemoteMessage? message) {
    //if the message is null
    if (message == null) return;

    //
}
  //function to initialize fg/bg settings
}