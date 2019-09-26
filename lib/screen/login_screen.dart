import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ksars_smart/bloc/auth/bloc.dart';
import 'package:ksars_smart/bloc/login/bloc.dart';
import 'package:ksars_smart/repository/firebase_repository.dart';
import 'package:ksars_smart/screen/registration_screen.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({Key key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController _emailController = TextEditingController();

  TextEditingController _passwordController = TextEditingController();

  bool get isPopulated =>
      _emailController.text.isNotEmpty && _passwordController.text.isNotEmpty;

  LoginBloc _loginBloc;

  @override
  void initState() {
    _loginBloc = LoginBloc(repository: FirebaseRepository());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider<LoginBloc>(
        builder: (_) => _loginBloc,
        child: BlocListener<LoginBloc, LoginState>(
          listener: (BuildContext context, LoginState state) {
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
          child: BlocBuilder<LoginBloc, LoginState>(
            builder: (context, state) {
              return _buildSingleChildScrollView(context);
            },
          ),
        ),
      ),
    );
  }

  SingleChildScrollView _buildSingleChildScrollView(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 90,
            ),
            Container(
              height: 180,
              width: 180,
              child: Image.asset('assets/logo.jpeg'),
            ),
            SizedBox(
              height: 40,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: Colors.grey[300],
              ),
              child: TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.email),
                    hintText: 'enter your email address'),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: Colors.grey[300],
              ),
              child: TextFormField(
                obscureText: true,
                controller: _passwordController,
                keyboardType: TextInputType.visiblePassword,
                decoration: InputDecoration(
                    prefixIcon: Icon(Icons.lock),
                    border: InputBorder.none,
                    hintText: 'enter your password'),
              ),
            ),
            Container(
              alignment: Alignment.centerRight,
              child: FlatButton(
                child: Text(
                  'forget password',
                  style: TextStyle(color: Colors.grey),
                ),
                onPressed: () {},
              ),
            ),
            Container(
              width: 150,
              decoration: BoxDecoration(color: Colors.blueGrey[200]),
              child: FlatButton(
                child: Text('Login'),
                onPressed: () {
                  if (isPopulated) {
                    _loginBloc.dispatch(Submitted(
                        email: _emailController.text,
                        password: _passwordController.text));
                  }
                },
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      "Don't have an Account?",
                      style: TextStyle(color: Colors.grey),
                    ),
                    FlatButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => RegistrationScreen()));
                      },
                      child: Text(
                        'SignUp',
                        style: TextStyle(color: Colors.blueGrey),
                      ),
                    )
                  ],
                )),
          ],
        ),
      ),
    );
  }
}
