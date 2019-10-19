import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ksars_smart/bloc/user/bloc.dart';
import 'package:ksars_smart/model/user.dart';

class UpdateProfileNumber extends StatefulWidget {
  final String uid;
  UpdateProfileNumber({Key key,this.uid}) : super(key: key);

  @override
  State<StatefulWidget> createState() => UpdateProfileNumberState();
}

class UpdateProfileNumberState extends State<UpdateProfileNumber> {
  TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    _phoneController.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return buildScaffold(context);
  }

  Scaffold buildScaffold(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  height: 100,
                ),
                Text(
                  "Update your phone number",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  "Easy to update your phone number, Your phone number start with county code e.g +92 and so on then pressed update button :)",
                ),
                TextField(
                  controller: _phoneController,
                  decoration: InputDecoration(hintText: "phone number e.g +923045202042"),
                )
              ],
            ),
          ),
          Positioned(
            top: 20,
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          Positioned(
              left: 5,
              right: 5,
              bottom: 10,
              child: Container(
                padding: EdgeInsets.all(5),
                color: _phoneController.text.isEmpty
                    ? Colors.green[200]
                    : Colors.green,
                width: MediaQuery.of(context).size.width,
                child: FlatButton(
                  onPressed: _phoneController.text.isEmpty
                      ? null
                      : () {
                    Fluttertoast.showToast(
                        msg:
                        "Your phone number updated success fully phone_N is : ${_phoneController.text}",
                        toastLength: Toast.LENGTH_LONG);
                    assert(_phoneController.text.isNotEmpty);
                    BlocProvider.of<UserBloc>(context).dispatch(
                        UpdateUser(
                            user: User(phone: _phoneController.text,uid: widget.uid)));
                    _phoneController.text="";
                  },
                  child: Text(
                    "Update",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ))
        ],
      ),
    );
  }
}
