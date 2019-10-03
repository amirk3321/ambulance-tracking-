import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:ksars_smart/app_constent.dart';
import 'package:ksars_smart/bloc/auth/bloc.dart';
import 'package:ksars_smart/bloc/location/bloc.dart';
import 'package:ksars_smart/bloc/request/ambulance_request_bloc.dart';
import 'package:ksars_smart/bloc/request/ambulance_request_event.dart';
import 'package:ksars_smart/bloc/request/ambulance_request_state.dart';
import 'package:ksars_smart/bloc/user/bloc.dart';
import 'package:ksars_smart/model/LocationMessage.dart';
import 'package:ksars_smart/model/paitent.dart';
import 'package:ksars_smart/model/user.dart';
import 'package:ksars_smart/utils/shared_pref.dart';
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

  GoogleMapController _mapController;

  //customIds
  MapType _mapType;
  MarkerId _currentLocationMarkerId;
  MarkerId _patientLocationMarkerId;
  PolylineId _customPolylineId;
  MarkerId _customMarkerId;
  MarkerId _allAmbulanceMarkerId;
  List<MarkerId> _ambulanceMarkerIdContiner = <MarkerId>[];

  //controller bool variable
  bool isNormal = false;
  bool _isShowScaffoldSnakeBar = true;
  bool _isSowAmbulance = true;
  bool _isLocationShare = false;

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

  GeoPoint _patientCurrentLocation;
  GeoPoint _ambulanceCurrentLocation;

  @override
  void initState() {
    _location.onLocationChanged().listen((locationData) {
      setState(() {
        latLng = LatLng(locationData.latitude, locationData.longitude);
        point = geo.point(
            latitude: locationData.latitude, longitude: locationData.longitude);

        SharedPref.getChannelId().then((channelId) {
          if (_isLocationShare == true) {
            setState(() {
              _ambulanceCurrentLocation =
                  GeoPoint(locationData.latitude, locationData.longitude);

              if (_ambulanceCurrentLocation!=null)
                BlocProvider.of<LocationChannelBloc>(context).dispatch(UpdateLocation(
                  channelId: channelId,ambulanceLocation: _ambulanceCurrentLocation
                ));
              print(
                  "locationTestingGeopoint ${_ambulanceCurrentLocation.latitude}");
            });
            print('_isLocationShare $_isLocationShare , ChannelId $channelId');
          }
        });
      });
    });
    setState(() {
      _removeCurrentMarker();
      _addCurrentMarker();
    });
    _getPatientLocation();
    super.initState();
  }

  _getPatientLocation() async {
    setState(() async {
      var data = await Location().getLocation();
      _patientCurrentLocation = GeoPoint(data.latitude, data.longitude);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        if (state is UsersLoaded) {
          final user = state.user.firstWhere((user) => user.uid == widget.uid,
              orElse: () => User());

          return BlocBuilder<LocationChannelBloc, LocationChannelState>(
            builder: (context, LocationChannelState locationState) {

              if (locationState is LocationLoaded) {
                final locationMessage = locationState.locationMessage
                    .firstWhere(
                        (locationMessage) =>
                            locationMessage.recipientId == widget.uid,
                        orElse: () => LocationMessage());

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
                                    border: Border.all(
                                        color: const Color(0x33A6A6A6)),
                                    // image: new Image.asset(_image.)
                                  ),
                                  child: Image.asset('assets/default.png'),
                                ),
                                Text(
                                  user.name.isNotEmpty ? user.name : 'John De',
                                ),
                                Text(
                                  user.type == AppConst.patient
                                      ? "Account Type ${AppConst.patient}"
                                      : "Account Type ${AppConst.ambulance}",
                                  style: TextStyle(),
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
                            child: RefreshIndicator(
                              child: CircularProgressIndicator(),
                              onRefresh: () {},
                            ),
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
                                          _drawRoute(location.latitude,
                                              location.longitude);
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
                              onTap: (location) {},
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
                              right: 160,
                              child: _isLocationShare == false
                                  ? Text("")
                                  : Container(
                                decoration: BoxDecoration(
                                    borderRadius:
                                    BorderRadius.circular(50),
                                    color: Colors.red),
                                child: IconButton(
                                  tooltip: "Stop Communction",
                                  icon: Icon(
                                    Icons.stop,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      if (_isLocationShare == true)
                                        _isLocationShare = false;
                                    });
                                  },
                                ),
                              ),
                            ),
                            Positioned(
                              top: 30,
                              right: 20,
                              child: user.type == AppConst.ambulance
                                  ? Row(
                                      children: <Widget>[
                                        Container(
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                              color: Colors.yellow
                                                  .withOpacity(.6)),
                                          child: IconButton(
                                            tooltip: "Paitent List",
                                            icon: Icon(Icons.notifications),
                                            onPressed: () {
                                              _bottomSheet(
                                                  user.name,
                                                  locationMessage
                                                      .patientPosition,
                                                  locationMessage.patientName);
                                            },
                                          ),
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                              color: Colors.yellow
                                                  .withOpacity(.6)),
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
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                              color: Colors.yellow
                                                  .withOpacity(.6)),
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
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                              color: _isSowAmbulance
                                                  ? Colors.yellow
                                                      .withOpacity(.6)
                                                  : Colors.red),
                                          child: IconButton(
                                            tooltip: "Ambulance tracker",
                                            icon: Icon(
                                              Icons.directions_bus,
                                              color: _isSowAmbulance
                                                  ? Colors.black
                                                  : Colors.white,
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                if (_isSowAmbulance == true) {
                                                  _setAmbulance(state);
                                                  _isSowAmbulance = false;
                                                } else {
                                                  _isSowAmbulance = true;
                                                  _removeAmbulanceMarker();
                                                }
                                              });
                                            },
                                          ),
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                              color: Colors.yellow
                                                  .withOpacity(.6)),
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
        return Container();
      },
    );
  }

  //not yet implemented
  _removeAmbulanceMarker() async {
    setState(() {
      _ambulanceMarkerIdContiner.forEach((markerIds) {
        if (setMarkers.containsKey(markerIds)) {
          setMarkers.remove(markerIds);
          print(markerIds);
        }
      });
    });
  }

  _setAmbulance(UsersLoaded state) async {
    var curentUserInfo = state.user
        .firstWhere((user) => user.uid == widget.uid, orElse: () => User());

    var users =
        state.user.where((user) => user.type == AppConst.ambulance).toList();

    final Uint8List markerIcon =
        await getBytesFromAsset("assets/ambulance.png", 100);

    users.forEach((user) {
      if (!setMarkers.containsKey(user.uid)) {
        _allAmbulanceMarkerId =
            MarkerId("allAmbulanceMarkerId${Random().nextInt(50)}");
        _ambulanceMarkerIdContiner.add(_allAmbulanceMarkerId);
        Marker marker = Marker(
          markerId: _allAmbulanceMarkerId,
          onTap: () {
            Scaffold.of(context).showSnackBar(SnackBar(
              duration: Duration(minutes: 3),
              content: Container(
                child: SingleChildScrollView(
                  child: Row(
                    children: <Widget>[
                      Container(
                        height: 80.0,
                        width: 80.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0x33A6A6A6)),
                          // image: new Image.asset(_image.)
                        ),
                        child: Image.asset('assets/default.png'),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 20, left: 5),
                        height: 95,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              user.name,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(user.email),
                            Text(user.phone),
                            Container(
                              height: 40,
                              child: Row(
                                children: <Widget>[
                                  RaisedButton(
                                    onPressed: () async {
                                      print(
                                          "AmbulanceRequestBloc cancel button pressed");
                                      BlocProvider.of<AmbulanceRequestBloc>(
                                              context)
                                          .dispatch(AmbulanceRequestCancel(
                                              otherUID: user.uid));
                                    },
                                    child: Text("cancel"),
                                  ),
                                  RaisedButton(
                                    onPressed: () async {
                                      print(
                                          "AmbulanceRequestBloc button pressed");
                                      BlocProvider.of<AmbulanceRequestBloc>(
                                              context)
                                          .dispatch(AmbulanceRequest(
                                              otherUID: user.uid,
                                              patient: Patient(
                                                  name: curentUserInfo.name,
                                                  uid: curentUserInfo.uid,
                                                  profile:
                                                      curentUserInfo.profile,
                                                  time: Timestamp.now(),
                                                  patientPosition:
                                                      _patientCurrentLocation,
                                                  request_type: 'sent')));
                                    },
                                    child: Text("Pick"),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
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
          setMarkers[_allAmbulanceMarkerId] = marker;
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

  _removeCurrentMarker() {
    setState(() {
      if (setMarkers.containsKey(_currentLocationMarkerId)) {
        setMarkers.remove(_currentLocationMarkerId);
      }
    });
  }

  _removeCustomMarker() {
    setState(() {
      if (setMarkers.containsKey(_customMarkerId)) {
        setMarkers.remove(_customMarkerId);
      }

      if (polyline.containsValue(_customPolylineId)) {
        polyline.removeWhere((id,polyline) => id == _customPolylineId);
      }
    });
  }

  _drawRoute(lat, lang) async {
    final current = await _location.getLocation();
    final List<LatLng> routes = List();
    routes.add(LatLng(lat, lang));
    routes.add(LatLng(current.latitude, current.longitude));
    _customPolylineId = PolylineId('currentRoutes1${Random().nextInt(50)}');
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

  void _bottomSheet(
      driverName, GeoPoint currentPatientLocation, currentPatientName) {
    showModalBottomSheet(
        context: context,
        builder: (builder) =>
            BlocBuilder<AmbulanceRequestBloc, AmbulanceRequestState>(
              builder: (BuildContext context, AmbulanceRequestState state) {
                //final patient=(state as AmbulanceRequestLoaded).patient;

                if (state is AmbulanceRequestLoaded) {
                  return Container(
                      color: Colors.grey,
                      child: Stack(
                        children: <Widget>[
                          ListView.builder(
                              itemCount: state.patient.length,
                              itemBuilder: (BuildContext context, int index) {
                                GeoPoint point = GeoPoint(
                                    state.patient[index].patientPosition
                                        .latitude,
                                    state.patient[index].patientPosition
                                        .longitude);
                                return singlePatientLayout(
                                    currentPatientName: currentPatientName,
                                    currentPatientLocation:
                                        currentPatientLocation,
                                    patientLocation: point,
                                    driverName: driverName,
                                    otherUID: state.patient[index].uid,
                                    profile: state.patient[index].profile == ''
                                        ? 'assets/default.png'
                                        : state.patient[index].profile,
                                    name: state.patient[index].name == ''
                                        ? ''
                                        : state.patient[index].name,
                                    time: DateFormat('hh:mm a').format(
                                        state.patient[index].time.toDate()));
                              }),
                          Positioned(
                            bottom: 10,
                            right: 10,
                            child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50),
                                  color: Colors.white),
                              child: IconButton(
                                icon: Icon(Icons.refresh),
                                onPressed: () {
                                  SharedPref.getCurrentUID().then((value) {
                                    BlocProvider.of<AmbulanceRequestBloc>(
                                            context)
                                        .dispatch(AmbulanceRequestLoad(value));
                                  });
                                },
                              ),
                            ),
                          )
                        ],
                      ));
                }
                return Container(
                  child: Text("BottomSheet not Generated"),
                );
              },
            ));
  }

  singlePatientLayout(
          {name,
          time,
          profile,
          otherUID,
          driverName,
          GeoPoint patientLocation,
          GeoPoint currentPatientLocation,
          currentPatientName}) =>
      Container(
        color: Colors.white54,
        padding: EdgeInsets.all(8),
        margin: EdgeInsets.all(3),
        child: Row(
          children: <Widget>[
            Container(
              height: 50,
              width: 50,
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(50)),
              child: Image.asset(profile),
            ),
            SizedBox(
              width: 5,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  name,
                  style: TextStyle(fontSize: 18),
                ),
                Text(
                  time,
                  style: TextStyle(fontSize: 14),
                )
              ],
            ),
            Spacer(),
            FlatButton(
              onPressed: () {
                print('cancel');
              },
              child: Text('cancel'),
            ),
            FlatButton(
              onPressed: () {
                BlocProvider.of<LocationChannelBloc>(context).dispatch(
                    ConfirmLocationChannelCreate(
                        otherUID: otherUID,
                        patientName: name,
                        currentUID: widget.uid,
                        driverName: driverName,
                        ambulancePosition: _ambulanceCurrentLocation == null
                            ? null
                            : _ambulanceCurrentLocation,
                        patientPosition: GeoPoint(
                          patientLocation.latitude,
                          patientLocation.longitude,
                        )));
                setState(() {
                  if (_isLocationShare == false) {
                    _isLocationShare = true;
                    print("isLocationShareTesting $_isLocationShare");
                  } else {
                    _isLocationShare = false;
                    print("isLocationShareTesting $_isLocationShare");
                  }
                });
                _removePatientMarkerId();
                _paitentLocationMarker(
                    currentPatientLocation, currentPatientName);
              },
              child: Text('Confirm'),
            )
          ],
        ),
      );

  _paitentLocationMarker(GeoPoint point, name) {
    print("checkPointLocation ${point.latitude} ,${point.longitude}");
    if (point != null) {
      _patientLocationMarkerId = MarkerId('PatientMarkerId');
      var patientMarkerId = Marker(
          consumeTapEvents: true,
          onTap: () {
            print("patientName $name");
          },
          markerId: _patientLocationMarkerId,
          position: LatLng(point.latitude, point.longitude),
          infoWindow: InfoWindow(
              title: "${point.latitude},${point.longitude}",
              snippet: 'Patient name $name *Patient Location'));
      setState(() {
        setMarkers[_patientLocationMarkerId] = patientMarkerId;
      });
    }
  }

  _removePatientMarkerId() {
    setState(() {
      if (setMarkers.containsKey(_patientLocationMarkerId)) {
        setMarkers.remove(_patientLocationMarkerId);
      }
    });
  }
}
