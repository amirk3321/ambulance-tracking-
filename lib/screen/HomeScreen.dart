import 'package:flutter/material.dart';
import 'package:ksars_smart/screen/google_screen.dart';
class HomeScreen extends StatelessWidget {
  final String uid;
    HomeScreen({Key key,this.uid}) :super(key : key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleScreen(uid: uid,),
    );
  }
}