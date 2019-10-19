import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ksars_smart/bloc/user/bloc.dart';
import 'package:ksars_smart/model/user.dart';

class UpdateProfileNameScreen extends StatefulWidget {
  final String uid;
  UpdateProfileNameScreen({Key key,this.uid}) : super(key: key);

  @override
  State<StatefulWidget> createState() => UpdateProfileNameScreenState();
}

class UpdateProfileNameScreenState extends State<UpdateProfileNameScreen> {
  TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    _nameController.addListener(() {
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
                  "Update your name",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  "Easy to update your name, just enter your full name and pressed update button :)",
                ),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(hintText: "Enter your full name"),
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
                color: _nameController.text.isEmpty
                    ? Colors.green[200]
                    : Colors.green,
                width: MediaQuery.of(context).size.width,
                child: FlatButton(
                  onPressed: _nameController.text.isEmpty
                      ? null
                      : () {
                          Fluttertoast.showToast(
                              msg:
                                  "Your name updated success fully name is : ${_nameController.text}",
                              toastLength: Toast.LENGTH_SHORT);
                          assert(_nameController.text.isNotEmpty);
                          BlocProvider.of<UserBloc>(context).dispatch(
                              UpdateUser(
                                  user: User(name: _nameController.text,uid: widget.uid)));
                        _nameController.text="";
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
