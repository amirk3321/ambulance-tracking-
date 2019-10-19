
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ksars_smart/bloc/auth/bloc.dart';
import 'package:ksars_smart/bloc/user/bloc.dart';
import 'package:ksars_smart/model/user.dart';
import 'package:ksars_smart/screen/setting/update_profile_name_screen.dart';
import 'package:ksars_smart/screen/setting/update_proifle_number.dart';

class SettingsScreen extends StatefulWidget{
  final String uid;
    SettingsScreen({Key key,this.uid}) :super(key : key);
  @override
  State<StatefulWidget> createState() => SettingsScreenState();
}
class SettingsScreenState extends State<SettingsScreen>{
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc,UserState>(
      builder: (BuildContext context,UserState state){
        if (state is UsersLoaded){
          return buildScaffold(context,state);
        }
        return Container();
      },
    );
  }

  Scaffold buildScaffold(BuildContext context,UsersLoaded state) {
    final user = state.user.firstWhere((user) => user.uid == widget.uid,
        orElse: () => User());
    return Scaffold(
    appBar: AppBar(
      title: Text("Settings"),
    ),
    body: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 10),
            Text("Profile",style: TextStyle(color: Colors.blueGrey),),
            InkWell(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (_) => UpdateProfileNameScreen(uid: widget.uid,)));
              },
              child: nameFiled(label: "Name",content: user.name.isEmpty || user.name == null ? "John De" : user.name,icon: Icons.person_pin),
            ),
            InkWell(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (_) => UpdateProfileNumber(uid: widget.uid,)));
              },
              child: nameFiled(label: "Mobile number",content: user.phone.isEmpty || user.phone == null ? "e.g +923045202042" : user.phone,icon: Icons.phone_android),
            ),
            InkWell(
              child: nameFiled(label: "Email",content:  user.email.isEmpty || user.email == null ?"ksarsSmartAmbulace@gmail.com" : user.email,icon: Icons.email),
            ),
            InkWell(
              child: customButton(label: "Change Password",icon: Icons.lock_outline),
            ),
            InkWell(
              child: nameFiled(label: "Gender",content: "Not added",icon: Icons.person_outline),
            ),
            InkWell(
              child: nameFiled(label: "Date of birth",content: "Not added",icon: Icons.calendar_today),
            ),
            SizedBox(height: 8,),
            Text("Account Type : ${user.type}",style: TextStyle(color: Colors.blueGrey),),
            SizedBox(height: 8,),
            Divider(color: Colors.grey,height: 1,),
            SizedBox(height: 8,),
            Text("General",style: TextStyle(color: Colors.blueGrey),),
            InkWell(
              child: customButton(label: "Add a missing place",icon: Icons.location_on),
            ),
            InkWell(
              child: nameFiled(label: "Language",content: "English",icon: Icons.language),
            ),
            InkWell(
              child: customButton(label: "Rate the App",icon: Icons.star_border),
            ),
            Divider(height: 1,color: Colors.grey,),
            SizedBox(height: 8,),
            Text("About",style: TextStyle(color: Colors.blueGrey),),
            SizedBox(height: 8,),
            Text("App Version 1.0",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.grey[400]),),
            SizedBox(height: 8,),
            SizedBox(height: 8,),
            InkWell(
              child: customButton(label: "Terms and Conditions",icon: Icons.pages),
            ),
            InkWell(
              onTap: (){
                BlocProvider.of<AuthBloc>(context)
                    .dispatch(LoggedOut());
                Navigator.pop(context);
              },
              child: customButton(label: "Sign out",icon: Icons.exit_to_app),
            ),
          ],
        ),
      ),
    )
  );
  }
//custom widgets for layout profile
  Widget nameFiled({icon,label,content}){
    return Container(
      padding: EdgeInsets.only(top: 10),
      child: Row(
        children: <Widget>[
          Container(
            height: 55,
            width: 55,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(icon,color: Colors.blueGrey,),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(label,style: TextStyle(fontWeight: FontWeight.bold),),
                Text(content,style: TextStyle(color: Colors.grey[700]),)
              ],
            ),
          )
        ],
      ),
    );
  }

  //change password widget
  Widget customButton({label,icon}){
    return Container(
      padding: EdgeInsets.only(top: 10),
      child: Row(
        children: <Widget>[
          Container(
            height: 55,
            width: 55,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(icon,color: Colors.blueGrey,),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(label,style: TextStyle(fontWeight: FontWeight.bold),),
              ],
            ),
          )
        ],
      ),
    );
  }
}