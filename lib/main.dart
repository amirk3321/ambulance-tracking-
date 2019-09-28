import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ksars_smart/bloc/request/ambulance_request_bloc.dart';
import 'package:ksars_smart/repository/firebase_repository.dart';
import 'package:ksars_smart/screen/HomeScreen.dart';
import 'package:ksars_smart/screen/login_screen.dart';
import 'package:splashscreen/splashscreen.dart';
import 'bloc/auth/bloc.dart';
import 'bloc/delegate/simple_delegate.dart';
import 'bloc/user/bloc.dart';

void main() {
  BlocSupervisor.delegate = SimpleDelegate();
  runApp(myApp());
}

class myApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => myAppState();
}

class myAppState extends State<myApp> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          builder: (_) => AuthBloc(repository: FirebaseRepository())
            ..dispatch(AppStartedEvent()),
        ),
        BlocProvider<UserBloc>(
          builder: (_) =>
              UserBloc(repository: FirebaseRepository())..dispatch(LoadUser()),
        ),
        BlocProvider<AmbulanceRequestBloc>(builder: (_) => AmbulanceRequestBloc(repository: FirebaseRepository()),)
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "Ksars Ambulance Smart System",
        theme: ThemeData(
          primarySwatch: Colors.blueGrey,
          accentColor: Colors.teal,
        ),
        routes: {
          '/': (context) {
            return SplashScreen(
              seconds: 3,

              title: Text("Ksars Smart Ambulance System",style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18
              ),),
              loaderColor: Colors.red,
              navigateAfterSeconds: MainScreen(),
              photoSize: 130,
              image: Image.asset('assets/logo.jpeg')
            );
          }
        },
      ),
    );
  }
}
class MainScreen extends StatelessWidget {
    MainScreen({Key key}) :super(key : key);
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthenticatedAuth) {
          return HomeScreen(uid: state.uid,);
        }
        if (state is UnAuthenticatedAuth) {
          return LoginScreen();
        }
        return Container();
      },
    );
  }
}
