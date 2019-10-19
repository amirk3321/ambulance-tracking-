import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart' show CalendarCarousel;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SchedulingScreen extends StatefulWidget {
    SchedulingScreen({Key key}) :super(key : key);

  @override
  _SchedulingScreenState createState() => _SchedulingScreenState();
}

class _SchedulingScreenState extends State<SchedulingScreen> {

  var _markedDateMap;
  var _currentDate;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Scheduling"),
      ),
      body: Stack(
        children: <Widget>[
          Positioned(
            top: 10,
            left: 5,
            right: 5,
            child:   calender(),
          ),
          Positioned(
              left: 5,
              right: 5,
              bottom: 10,
              child: Container(
                padding: EdgeInsets.all(5),
                color: Colors.green,
                width: MediaQuery.of(context).size.width,
                child: FlatButton(
                  onPressed:() {
                    Fluttertoast.showToast(
                        msg:
                        "Scheduling",
                        toastLength: Toast.LENGTH_SHORT);
                    Navigator.pop(context);
                  },
                  child: Text(
                    "Confirm",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ))
        ],
      ),
    );

  }

    Widget calender() {
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 16.0),
        child: CalendarCarousel<Event>(
          onDayPressed: (DateTime date, List<Event> events) {
            this.setState(() => _currentDate = date);
          },
          weekendTextStyle: TextStyle(
            color: Colors.red,
          ),
          thisMonthDayBorderColor: Colors.grey,
          customDayBuilder: (   /// you can provide your own build function to make custom day containers
              bool isSelectable,
              int index,
              bool isSelectedDay,
              bool isToday,
              bool isPrevMonthDay,
              TextStyle textStyle,
              bool isNextMonthDay,
              bool isThisMonthDay,
              DateTime day,
              ) {
            /// If you return null, [CalendarCarousel] will build container for current [day] with default function.
            /// This way you can build custom containers for specific days only, leaving rest as default.

            // Example: every 15th of month, we have a flight, we can place an icon in the container like that:
            if (day.day == 15) {
              return;
            } else {
              return;
            }
          },
          weekFormat: false,
          markedDatesMap: _markedDateMap,
          height: 420.0,
          selectedDateTime: _currentDate,
          daysHaveCircularBorder: false, /// null for not rendering any border, true for circular border, false for rectangular border
        ),
      );
    }
}