import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ksars_smart/app_constent.dart';
import 'package:ksars_smart/bloc/auth/bloc.dart';
import 'package:ksars_smart/bloc/registor/bloc.dart';
import 'package:ksars_smart/repository/firebase_repository.dart';
import 'package:location/location.dart';

class RegistrationScreen extends StatefulWidget {
  RegistrationScreen({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => RegistrationScreenState();
}

class RegistrationScreenState extends State<RegistrationScreen> {
  bool _isTypeOfUser = false;
  bool _obscureText = true;

  TextEditingController _emailController;
  TextEditingController _nameController;
  TextEditingController _phoneController;
  TextEditingController _passwordController;

  bool get isPopulated =>
      _emailController.text.isNotEmpty &&
      _nameController.text.isNotEmpty &&
      _phoneController.text.isNotEmpty &&
      _passwordController.text.isNotEmpty;


  GeoPoint _point;
  Location _location=Location();
  RegistorBloc _registorBloc;

  @override
  void initState(){
    _registorBloc = RegistorBloc(repository: FirebaseRepository());
    _emailController = TextEditingController();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _passwordController = TextEditingController();
    getMyLocation();
    super.initState();
  }
  getMyLocation()async{
    var data=await _location.getLocation();
    _point=GeoPoint(data.latitude,data.longitude);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Registration screen"),
      ),
      body: BlocProvider<RegistorBloc>(
        builder: (_) => _registorBloc,
        child: BlocListener<RegistorBloc,RegistorState>(
          listener: (context,state){
            if (state is LoadingState) {
              Scaffold.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(
                  content: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text('SettingUp an account...'),
                      CircularProgressIndicator(),
                    ],
                  ),
                  backgroundColor: Colors.green,
                ));
            }
            if (state is SuccessState) {
              BlocProvider.of<AuthBloc>(context).dispatch(LoggedIn());
              Navigator.pop(context);
            }
            if (state is FailureState) {
              Scaffold.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(
                  content: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text('error occurr'),
                      CircularProgressIndicator(),
                    ],
                  ),
                  backgroundColor: Colors.red,
                ));
            }
          },
          child: BlocBuilder<RegistorBloc,RegistorState>(
            builder: (context,state){
              return _buildSingleChildScrollView();
            },
          ),
        ),
      ),
    );
  }

  SingleChildScrollView _buildSingleChildScrollView() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 50,
            ),
            SizedBox(
              height: 40,
            ),
            buildTextField('enter your name', Icon(Icons.perm_identity),
                _nameController),
            SizedBox(
              height: 10,
            ),
            buildTextField('enter your email address', Icon(Icons.email),
                _emailController),
            SizedBox(
              height: 10,
            ),
            buildTextField('enter your phone number', Icon(Icons.phone),
                _phoneController),
            SizedBox(
              height: 10,
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: Colors.grey[300],
              ),
              child: TextFormField(
                controller: _passwordController,
                obscureText: _obscureText,
                keyboardType: TextInputType.visiblePassword,
                decoration: InputDecoration(
                    prefixIcon: Icon(Icons.lock),
                    border: InputBorder.none,
                    suffixIcon: IconButton(
                      icon: Icon(
                        Icons.remove_red_eye,
                        color: _obscureText ? Colors.grey : Colors.red,
                      ),
                      onPressed: () => setState(
                          () => _obscureText = _obscureText ? false : true),
                    ),
                    hintText: 'enter your password'),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              child: Row(
                children: <Widget>[
                  Checkbox(
                    onChanged: (value) {
                      setState(() {
                        _isTypeOfUser = value;
                      });
                    },
                    value: _isTypeOfUser,
                  ),
                  Text('are you patient?'),
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              width: 150,
              decoration: BoxDecoration(color: Colors.blueGrey[200]),
              child: FlatButton(
                child: Text('Registraion'),
                onPressed: () {
                  if (isPopulated){
                    _registorBloc.dispatch(
                      Submitted(
                        name: _nameController.text,
                        email: _emailController.text,
                        phoneNumber: _phoneController.text,
                        password: _passwordController.text,
                        profile: '',
                        point: _point,
                        type: _isTypeOfUser ? AppConst.patient : AppConst.ambulance
                      )
                    );
                  }
                },
              ),
            ),
            SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }

  Container buildTextField(hint, icon, controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        color: Colors.grey[300],
      ),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
            border: InputBorder.none, prefixIcon: icon, hintText: hint),
      ),
    );
  }
  @override
  void dispose() {
    super.dispose();
  }
}
