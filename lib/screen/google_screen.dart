import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ksars_smart/app_constent.dart';
import 'package:ksars_smart/bloc/auth/bloc.dart';
import 'package:ksars_smart/bloc/user/bloc.dart';
import 'package:location/location.dart';

class GoogleScreen extends StatefulWidget {
  final String uid;

  GoogleScreen({Key key, this.uid}) : super(key: key);

  @override
  State<StatefulWidget> createState() => GoogleScreenState();
}

//state class
class GoogleScreenState extends State<GoogleScreen> {
  var scaffoldKey = GlobalKey<ScaffoldState>();
  List<Marker> markers = <Marker>[];
  GoogleMapController _mapController;

  //customIds
  MapType _mapType;
  MarkerId _currentLocationMarkerId;
  PolylineId _customPolylineId;
  MarkerId _customMarkerId;

  //controller bool variable
  bool isNormal = false;
  var _isShowScaffoldSnakeBar = true;

  //list of markers
  Map<MarkerId, Marker> setMarkers = <MarkerId, Marker>{};
  Map<PolylineId, Polyline> polyline = <PolylineId, Polyline>{};

  //location
  Geoflutterfire geo = Geoflutterfire();
  LatLng latLng;
  GeoFirePoint point;
  Location _location = Location();

  //create map
  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      _mapController = controller;
      print('my uid ${widget.uid}');
    });
  }

  @override
  void initState() {
    _addCurrentMarker();
    _location.onLocationChanged().listen((locationData) {
      latLng = LatLng(locationData.latitude, locationData.longitude);
      point = geo.point(
          latitude: locationData.latitude, longitude: locationData.longitude);
      //_addCurrentMarker(locationData.latitude, locationData.longitude);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        if (state is UsersLoaded) {
          final user = state.user
              .firstWhere((user) => user.uid == widget.uid, orElse: () => null);

          final ambulance = state.user
              .where((user) => user.type == AppConst.ambulance)
              .toList();

          return Scaffold(
            key: scaffoldKey,
            drawer: Theme(
              data: Theme.of(context)
                  .copyWith(canvasColor: Colors.white.withOpacity(.6)),
              child: Drawer(
                child: ListView(
                  children: <Widget>[
                    DrawerHeader(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            height: 80.0,
                            width: 80.0,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border:
                                  Border.all(color: const Color(0x33A6A6A6)),
                              // image: new Image.asset(_image.)
                            ),
                            child: Image.asset('assets/default.png'),
                          ),
                          Text(
                            user.name.isNotEmpty ? user.name : 'John De',
                          ),
                        ],
                      ),
                    ),
                    ListTile(
                      leading: Icon(Icons.calendar_today),
                      title: Text('Scheduling'),
                    ),
                    ListTile(
                      leading: Icon(Icons.notifications),
                      title: Text('Notification'),
                    ),
                    ListTile(
                      leading: Icon(Icons.help),
                      title: Text('Help'),
                    ),
                    ListTile(
                      leading: Icon(Icons.settings),
                      title: Text('Settings'),
                    ),
                    ListTile(
                      leading: Icon(Icons.exit_to_app),
                      title: Text('Logout'),
                      onTap: () {
                        BlocProvider.of<AuthBloc>(context)
                            .dispatch(LoggedOut());
                      },
                    ),
                  ],
                ),
              ),
            ),
            body: latLng == null
                ? Container(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                : Stack(
                    children: <Widget>[
                      GoogleMap(
                        onMapCreated: _onMapCreated,
                        mapType: _mapType,
                        indoorViewEnabled: true,
                        trafficEnabled: true,
                        polylines: Set<Polyline>.of(polyline.values),
                        onLongPress: (location) {
                          _setCustomMarker(
                              location.latitude, location.longitude);
                          assert(_isShowScaffoldSnakeBar == true);
                          Scaffold.of(context).showSnackBar(SnackBar(
                            duration: Duration(minutes: 60),
                            content: Stack(
                              children: <Widget>[
                                RaisedButton(
                                  child: Text('Start travel'),
                                  onPressed: () {
                                    _drawRoute(
                                        location.latitude, location.longitude);
                                  },
                                ),
                                Positioned(
                                  right: 5,
                                  child: IconButton(
                                    icon: Icon(
                                      Icons.close,
                                      color: Colors.red,
                                    ),
                                    onPressed: () {
                                      Scaffold.of(context)
                                          .hideCurrentSnackBar();
                                      setState(() {
                                        _isShowScaffoldSnakeBar = true;
                                        _removeCustomMarker();
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ));
                          setState(() {
                            _isShowScaffoldSnakeBar = false;
                          });
                        },
                        onTap: (location) {
                          if (user.type == AppConst.patient)
                            _setAmbulance(state);
                          else
                            print('you are not patient');
                        },
                        myLocationEnabled: true,
                        myLocationButtonEnabled: false,
                        markers: Set<Marker>.of(setMarkers.values),
                        initialCameraPosition: CameraPosition(
                          target: latLng,
                          zoom: 15,
                        ),
                      ),
                      Positioned(
                        top: 25,
                        left: 10,
                        child: IconButton(
                          icon: Icon(Icons.menu),
                          onPressed: () =>
                              scaffoldKey.currentState.openDrawer(),
                        ),
                      ),
                      Positioned(
                        top: 39,
                        left: 37,
                        child: Container(
                          height: 10,
                          width: 10,
                          decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(50)),
                        ),
                      ),
                      //map switch positioned
                      Positioned(
                        right: 20,
                        bottom: 80,
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              color: Colors.white.withOpacity(.8)),
                          child: IconButton(
                            icon: Icon(Icons.map),
                            onPressed: () {
                              setState(() {
                                if (isNormal == false) {
                                  _mapType = MapType.satellite;
                                  isNormal = true;
                                } else {
                                  _mapType = MapType.normal;
                                  isNormal = false;
                                }

                                print("my type $isNormal");
                              });
                            },
                          ),
                        ),
                      ),
                      //emergency position
                      Positioned(
                        top: 30,
                        right: 20,
                        child: user.type == AppConst.ambulance
                            ? Row(
                                children: <Widget>[
                                  Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(50),
                                        color: Colors.yellow.withOpacity(.6)),
                                    child: IconButton(
                                      tooltip: "Paitent List",
                                      icon: Icon(Icons.notifications),
                                      onPressed: () {},
                                    ),
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(50),
                                        color: Colors.yellow.withOpacity(.6)),
                                    child: IconButton(
                                      tooltip: "NearByHostpital",
                                      icon: Icon(Icons.local_hospital),
                                      onPressed: () {},
                                    ),
                                  ),
                                ],
                              )
                            : Row(
                                children: <Widget>[
                                  Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(50),
                                        color: Colors.yellow.withOpacity(.6)),
                                    child: IconButton(
                                      tooltip: "Emergeny",
                                      icon: Icon(Icons.add_alert),
                                      onPressed: () {},
                                    ),
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(50),
                                        color: Colors.yellow.withOpacity(.6)),
                                    child: IconButton(
                                      tooltip: "Ambulance tracker",
                                      icon: Icon(Icons.directions_bus),
                                      onPressed: () {},
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(50),
                                        color: Colors.yellow.withOpacity(.6)),
                                    child: IconButton(
                                      tooltip: "NearByHospital",
                                      icon: Icon(Icons.local_hospital),
                                      onPressed: () {},
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ],
                  ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                _mapController.animateCamera(
                    CameraUpdate.newCameraPosition(CameraPosition(
                  target: latLng,
                  zoom: 16,
                )));
              },
              child: Icon(
                Icons.my_location,
                color: Colors.black,
              ),
              backgroundColor: Colors.white.withOpacity(.8),
            ),
          );
        }
        return Container();
      },
    );
  }

  _setAmbulance(UsersLoaded state) async {
    var users =
        state.user.where((user) => user.type == AppConst.ambulance).toList();
    final Uint8List markerIcon =
        await getBytesFromAsset("assets/ambulance.png", 100);
    users.forEach((user) {
      if (!setMarkers.containsValue(user.uid)) {
        MarkerId markerId = MarkerId(user.uid);
        Marker marker = Marker(
          markerId: markerId,
          onTap: () {
            Scaffold.of(context).showSnackBar(
                SnackBar(
                  duration: Duration(minutes: 3),
              content: Container(
                child: SingleChildScrollView(
                  child: Row(
                    children: <Widget>[
                      Container(
                        height: 60.0,
                        width: 60.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border:
                          Border.all(color: const Color(0x33A6A6A6)),
                          // image: new Image.asset(_image.)
                        ),
                        child: Image.asset('assets/default.png'),
                      ),

                      Container(
                        margin: EdgeInsets.only(top: 20,left: 5),
                        height: 80,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(user.name,style: TextStyle(fontWeight: FontWeight.bold),),
                            Text(user.email),
                            Text(user.phone),
                          ],
                        ),
                      ),
                      SizedBox(width: 5,),
                      RaisedButton(
                        onPressed: (){},
                        child: Text('pick'),
                      ),
                    ],
                  ),
                ),
              ),
            ));
          },
          icon: BitmapDescriptor.fromBytes(markerIcon),
          infoWindow: InfoWindow(
              title: "${user.uid}",
              snippet: "${user.name} * driver ${user.type}"),
          position: LatLng(user.point.latitude, user.point.longitude),
        );
        setState(() {
          setMarkers[markerId] = marker;
        });
        print(user.name);
      } else {
        print('Already Marker set');
      }
    });
  }

  _addCurrentMarker() async {
    var point = await _location.getLocation();
    _currentLocationMarkerId = MarkerId('${point.latitude}');
    var currentLocationMarker = Marker(
        consumeTapEvents: true,
        markerId: _currentLocationMarkerId,
        position: LatLng(point.latitude, point.longitude),
        infoWindow: InfoWindow(
            title: "${point.latitude},${point.longitude}",
            snippet: '*current Location'));
    setState(() {
      setMarkers[_currentLocationMarkerId] = currentLocationMarker;
    });
  }

  _setCustomMarker(lat, long) async {
    _customMarkerId = MarkerId("customMarkerId${Random.secure().nextInt(20)}");
    var customMarker = Marker(
        markerId: _customMarkerId,
        position: LatLng(lat, long),
        infoWindow: InfoWindow(title: "$lat,$long", snippet: '*'));
    setState(() {
      setMarkers[_customMarkerId] = customMarker;
    });
  }

  _removeCustomMarker() {
    setState(() {
      if (setMarkers.containsKey(_customMarkerId)) {
        setMarkers.remove(_customMarkerId);
      }

      if (polyline.containsValue(_customPolylineId)) {
        polyline.clear();
      }
    });
  }

  _drawRoute(lat, lang) async {
    final current = await _location.getLocation();
    final List<LatLng> routes = List();
    routes.add(LatLng(lat, lang));
    routes.add(LatLng(current.latitude, current.longitude));
    _customPolylineId = PolylineId('currentRoutes1');
    var line = Polyline(
      polylineId: _customPolylineId,
      consumeTapEvents: true,
      width: 6,
      color: Colors.red,
      jointType: JointType.bevel,
      points: routes,
    );

    setState(() {
      polyline[_customPolylineId] = line;
    });
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))
        .buffer
        .asUint8List();
  }
}
