import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
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
import 'package:ksars_smart/repository/places_repository.dart';
import 'package:ksars_smart/screen/pages/scheduling_screen.dart';
import 'package:ksars_smart/screen/setting/settings.dart';
import 'package:ksars_smart/utils/shared_pref.dart';
import 'package:location/location.dart';

typedef onSaveCallBack = Function(String channelId);

class GoogleScreen extends StatefulWidget {
  final String uid;

  GoogleScreen({Key key, this.uid}) : super(key: key);

  @override
  State<StatefulWidget> createState() => GoogleScreenState();
}

//state class
class GoogleScreenState extends State<GoogleScreen> {
  var scaffoldKey = GlobalKey<ScaffoldState>();

  //mapController
  GoogleMapController _mapController;

  //customIds
  MapType _mapType;
  MarkerId _currentLocationMarkerId;
  MarkerId _patientLocationMarkerId;
  MarkerId _hospitalLocationMarkerId;
  MarkerId _ambulanceLocationMarkerId;
  PolylineId _customPolylineId;
  PolylineId _patientToHospitalPolylineId;
  MarkerId _allAmbulanceMarkerId;
  MarkerId _hospitalMarkerId;
  List<MarkerId> _ambulanceMarkerIdContiner = <MarkerId>[];
  List<MarkerId> _hospitalMarkerIdContainer = <MarkerId>[];
  List<PolylineId> _ambulancePatientPolyLineContainer = <PolylineId>[];

  //controller bool variable
  bool isNormal = false;
  bool _isSowAmbulance = true;
  bool _isSowHospital = true;
  bool _isEmergncy = true;
  bool _isLocationShare = false;
  bool _isShowAmbulanceDetails = false;
  int _updateDatabase = 0;

  //list of markers
  Map<MarkerId, Marker> setMarkers = <MarkerId, Marker>{};
  Map<PolylineId, Polyline> polyline = <PolylineId, Polyline>{};

  //location
  LatLng latLng;
  Location _location = Location();

  GeoPoint _patientCurrentLocation;
  GeoPoint _ambulanceCurrentLocation;
  GeoPoint _hospitalCurrentLocation;

  String _currentLocationChannelId;

  //locationForPolyline Patient
  GeoPoint _patientLocation;

  void setPatientLocation(GeoPoint patientLocation) {
    setState(() {
      this._patientLocation = patientLocation;
    });
  }

  GeoPoint getPatientLocation() {
    return this._patientLocation;
  }

  //create map
  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      _mapController = controller;
      print('my uid ${widget.uid}');
    });
  }

  void setChannelId({String channelId}) {
    this._currentLocationChannelId = channelId;
  }

  String getChannelId() => this._currentLocationChannelId;

  @override
  void initState() {
    _location.onLocationChanged().listen((locationData) {
      setState(() {
        latLng = LatLng(locationData.latitude, locationData.longitude);

        SharedPref.getChannelId().then((channelId) {
          if (_isLocationShare == true) {
            //setState
            _ambulanceCurrentLocation =
                GeoPoint(locationData.latitude, locationData.longitude);
            print(
                "checkLocationTesting ${getPatientLocation().latitude},${getPatientLocation().longitude}");
            _ambulancePatientPolyLine(
                patientLocation: GeoPoint(getPatientLocation().latitude,
                    getPatientLocation().longitude),
                ambulanceLocation: _ambulanceCurrentLocation);
            if (_ambulanceCurrentLocation != null)
              BlocProvider.of<LocationChannelBloc>(context).dispatch(
                  UpdateLocation(
                      isFlag: _isLocationShare,
                      channelId: channelId,
                      ambulanceLocation: _ambulanceCurrentLocation));
            //endSetState
            _updateDatabase = 0;
          } else {
            if (_updateDatabase == 0 || _updateDatabase == 1) {
              BlocProvider.of<LocationChannelBloc>(context).dispatch(
                  UpdateLocation(
                      channelId: channelId, isFlag: _isLocationShare));
              _removeAmbulanceLocationMarker();
              print("_updateDatabase updated ");
            } else if (_updateDatabase < 5) _updateDatabase = 3;

            _updateDatabase++;
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

                locationState.locationMessage.forEach((loc) {
                  if (loc.senderId == widget.uid) {
                    _removeAmbulancePatientPolyLineTest(
                      isFlag: loc.isFlag,
                      driverName: loc.driverName,
                      ambulance: loc.ambulancePosition,
                      patient: loc.patientPosition,
                      hospital: loc.hospitalPosition
                    );
                  }
                });
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
                            onTap: (){
                              Navigator.push(context, MaterialPageRoute(builder: (_) => SchedulingScreen()));
                            },
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
                            onTap: (){
                              Navigator.of(context).push(MaterialPageRoute(builder: (_) => SettingsScreen(uid: widget.uid)));
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
                                            print("ChannelIdCurrent ${getChannelId().toString()}");
                                            _removePatientMarkerId();
                                            _removeHospitalLocationMarker();
                                            _removeAmbulanceMarker();
                                            _removeAmbulancePatientPolyLine();
                                            _removePatientAmbulancePolyLine();
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
//                                              user.name,
//                                              locationMessage
//                                                  .patientPosition,
//                                              locationMessage.patientName,
                                              _bottomSheet(
                                                  driverName: user.name,
                                                  currentPatientLocation:
                                                      locationMessage
                                                          .patientPosition,
                                                  currentPatientName:
                                                      locationMessage
                                                          .patientName,
                                                  locationMessage:
                                                      locationState);
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
                                              color: _isSowHospital
                                                  ? Colors.yellow
                                                      .withOpacity(.6)
                                                  : Colors.red),
                                          child: IconButton(
                                            tooltip: "NearByHostpital",
                                            icon: Icon(
                                              Icons.local_hospital,
                                              color: _isSowHospital
                                                  ? Colors.black
                                                  : Colors.white,
                                            ),
                                            onPressed: () async {
                                              setState(() {
                                                if (_isSowHospital == true) {
                                                  getNearByPlaces();
                                                  _isSowHospital = false;
                                                } else {
                                                  _isSowHospital = true;
                                                  _removeHospitalMarker();
                                                }
                                              });
                                            },
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
                                              color: _isEmergncy
                                                  ? Colors.yellow
                                                      .withOpacity(.6)
                                                  : Colors.red),
                                          child: IconButton(
                                            tooltip: "Emergeny",
                                            icon: Icon(
                                              Icons.add_alert,
                                              color: _isEmergncy
                                                  ? Colors.black
                                                  : Colors.white,
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                if (_isEmergncy == true) {
                                                  _isEmergncy = false;
                                                } else {
                                                  _isEmergncy = true;
                                                }
                                              });
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
                                                  _removeAmbulanceLocationMarker();
                                                  _removePatientAmbulancePolyLine();
                                                  _removeHospitalLocationMarker();
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
                                              color: _isSowHospital
                                                  ? Colors.yellow
                                                      .withOpacity(.6)
                                                  : Colors.red),
                                          child: IconButton(
                                            tooltip: "NearByHospital",
                                            icon: Icon(
                                              Icons.local_hospital,
                                              color: _isSowHospital
                                                  ? Colors.black
                                                  : Colors.white,
                                            ),
                                            onPressed: () async {
                                              print(
                                                  "placesName NearByHospital button pressed");
                                              setState(() {
                                                if (_isSowHospital == true) {
                                                  getNearByPlaces();
                                                  _isSowHospital = false;
                                                } else {
                                                  _isSowHospital = true;
                                                  _removeHospitalMarker();
                                                }
                                              });
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ],
                        ),
                  floatingActionButton: FloatingActionButton(
                    onPressed: () {
                      if (latLng!=null){
                        _mapController.animateCamera(
                            CameraUpdate.newCameraPosition(CameraPosition(
                              target: latLng,
                              zoom: 16,
                            )));
                      }else{
                        setState(()async {
                          latLng=LatLng((await _location.getLocation()).latitude,(await _location.getLocation()).longitude);
                        });
                      }

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

    users.forEach((user) async {
      print("checkIsBusy ${user.isBusy}");
      List<Placemark> placeMarker = await Geolocator()
          .placemarkFromCoordinates(user.point.latitude, user.point.longitude);
      placeMarker.forEach((places) {
        if (!setMarkers.containsKey(user.uid)) {
          _allAmbulanceMarkerId =
              MarkerId("allAmbulanceMarkerId${Random().nextInt(50)}");
          _ambulanceMarkerIdContiner.add(_allAmbulanceMarkerId);
          Marker marker = Marker(
            markerId: _allAmbulanceMarkerId,
            onTap: () async {
              Scaffold.of(context).showSnackBar(
                SnackBar(
                  duration: Duration(minutes: 2),
                  content: Container(
                    child: SingleChildScrollView(
                      child: Row(
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
                                Text(
                                    "Distance ${(await Geolocator().distanceBetween(latLng.latitude, latLng.longitude, user.point.latitude, user.point.longitude)).round()}m"),
                                Container(
                                  height: 40,
                                  child: Row(
                                    children: <Widget>[
                                      RaisedButton(
                                        onPressed: () async {
                                          Fluttertoast.showToast(msg: "request cancel successfuly",gravity: ToastGravity.TOP,backgroundColor: Colors.green[800],toastLength: Toast.LENGTH_LONG);

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
                                        color: user.isBusy == true ? Colors.blue[200] : Colors.blue[800],
                                        onPressed: user.isBusy ==true ? null : () async {
                                          Fluttertoast.showToast(msg: "request send to ${user.name} successfuly",gravity: ToastGravity.TOP,backgroundColor: Colors.green[800],toastLength: Toast.LENGTH_LONG);
                                          BlocProvider.of<AmbulanceRequestBloc>(
                                                  context)
                                              .dispatch(AmbulanceRequest(
                                                  otherUID: user.uid,
                                                  patient: Patient(
                                                      name: curentUserInfo.name,
                                                      uid: curentUserInfo.uid,
                                                      profile: curentUserInfo
                                                          .profile,
                                                      hospitalPosition:
                                                          _hospitalCurrentLocation ==
                                                                  GeoPoint(0.0,0.0)
                                                              ? null
                                                              : _hospitalCurrentLocation,
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
                ),
              );
            },
            icon: BitmapDescriptor.fromBytes(markerIcon),
            infoWindow: InfoWindow(
                title: "${places.name} ,${places.administrativeArea}",
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

  _removeCurrentMarker() {
    setState(() {
      if (setMarkers.containsKey(_currentLocationMarkerId)) {
        setMarkers.remove(_currentLocationMarkerId);
      }
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
      {driverName,
      GeoPoint currentPatientLocation,
      currentPatientName,
      LocationLoaded locationMessage}) {
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
                                GeoPoint patientLocation = GeoPoint(
                                    state.patient[index].patientPosition
                                        .latitude,
                                    state.patient[index].patientPosition
                                        .longitude);
                                GeoPoint hospitalLocation;
                                if (state.patient[index].hospitalPosition !=null){
                                  hospitalLocation=GeoPoint(
                                      state.patient[index].hospitalPosition.latitude,
                                      state.patient[index].hospitalPosition.longitude
                                  );
                                }
                                return singlePatientLayout(
                                  hospitalLocation: hospitalLocation==null ? null : hospitalLocation,
                                    senderUID: state.patient[index].uid,
                                    locationMessage: locationMessage,
                                    currentPatientName: currentPatientName,
                                    currentPatientLocation:
                                        currentPatientLocation,
                                    patientLocation: patientLocation,
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
            ),
    );
  }

  singlePatientLayout(
          {name,
          time,
          profile,
          otherUID,
          driverName,
          String senderUID,
          GeoPoint patientLocation,
          GeoPoint hospitalLocation,
          GeoPoint currentPatientLocation,
          LocationLoaded locationMessage,
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
                if (_isLocationShare==true){
                  Fluttertoast.showToast(msg: "Stop Befere if you want to Cancel request",gravity: ToastGravity.BOTTOM,backgroundColor: Colors.red,toastLength: Toast.LENGTH_LONG);
                }else{
                  print('cancel');
                  BlocProvider.of<AmbulanceRequestBloc>(context).dispatch(AmbulanceRequestCancel(otherUID: otherUID));
                  BlocProvider.of<LocationChannelBloc>(context).dispatch(DeleteEngagedLocationChannel(otherUID: otherUID));
                  BlocProvider.of<LocationChannelBloc>(context).dispatch(DeleteLocationChannel(channelId: getChannelId().toString()));
                  BlocProvider.of<UserBloc>(context).dispatch(UpdateUser(user: User(isBusy: true,uid: widget.uid)));
                }

              },
              child: Text('cancel'),
            ),
            FlatButton(
              onPressed: () {
                BlocProvider.of<LocationChannelBloc>(context).dispatch(
                    ConfirmLocationChannelCreate(
                        otherUID: otherUID,
                        patientName: name,
                        isFlag: _isLocationShare,
                        currentUID: widget.uid,
                        driverName: driverName,
                        ambulancePosition: _ambulanceCurrentLocation == null
                            ? null
                            : _ambulanceCurrentLocation,
                        hospitalPosition: hospitalLocation,
                        patientPosition: GeoPoint(
                          patientLocation.latitude,
                          patientLocation.longitude,
                        )));
                setState(() async {
                  locationMessage.locationMessage.forEach((e) async {
                    if (senderUID == e.senderId) {
                      if (_isLocationShare == false) {
                        _isLocationShare = true;
                      } else {
                        _isLocationShare = false;
                      }
                      BlocProvider.of<UserBloc>(context).dispatch(UpdateUser(user: User(isBusy: false,uid: widget.uid)));
                      setChannelId(channelId: e.channelId);
                      setPatientLocation(e.patientPosition);
                      _removePatientMarkerId();
                      _patientLocationMarker(e.patientPosition, e.patientName);
                      _removeHospitalLocationMarker();
                      _hospitalLocationMarker(hospital: e.hospitalPosition);
                      _patientToHospitalPolyLine(patientLocation: e.patientPosition,hospitalLocation: e.hospitalPosition);
                    }
                  });
                });

              },
              child:  _isLocationShare ==false ? Text('Confirm') : Row(children: <Widget>[Text("Confirm"),CircularProgressIndicator()],),
            )
          ],
        ),
      );


  //markers routes below

  _patientLocationMarker(GeoPoint point, name) async {
    if (point != null) {
      final Uint8List patientMarker =
          await getBytesFromAsset("assets/patient.png", 100);
      print("checkPointLocation ${point.latitude} ,${point.longitude}");
      _patientLocationMarkerId = MarkerId('PatientMarkerId');
      var patientMarkerId = Marker(
          consumeTapEvents: true,
          onTap: () {
            print("patientName $name");
          },
          markerId: _patientLocationMarkerId,
          icon: BitmapDescriptor.fromBytes(patientMarker),
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


  //
  _ambulancePatientPolyLine(
      {GeoPoint patientLocation, GeoPoint ambulanceLocation}) async {
    final List<LatLng> routes = List();
    routes.add(LatLng(patientLocation.latitude, patientLocation.longitude));
    routes.add(LatLng(ambulanceLocation.latitude, ambulanceLocation.longitude));
    _customPolylineId = PolylineId('amhulancePaitentRountePoint001');
    _ambulancePatientPolyLineContainer.add(_customPolylineId);
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

  //single ambulance to patient route line remove
  _removeAmbulancePatientPolyLine() {
    setState(() {
      _ambulancePatientPolyLineContainer.forEach((polylineMarkerId) {
        if (polyline.containsKey(polylineMarkerId)) {
          polyline.remove(polylineMarkerId);
        }
      });
    });
  }

  //single ambulance to patient route line draw
  _removeAmbulancePatientPolyLineTest(
      {GeoPoint ambulance,
      String driverName,
      GeoPoint patient,
        GeoPoint hospital,
      bool isFlag}) async {
    assert(ambulance != null);
    if (isFlag == true) {
      _patientAmbulancePolyLine(
          ambulanceLocation: ambulance,
          patientLocation: GeoPoint(latLng.latitude, latLng.longitude));
      _ambulanceLocationMarker(ambulance, driverName);
      assert(hospital !=null);
      _hospitalLocationMarker(hospital: hospital);
      _patientToHospitalPolyLine(hospitalLocation: hospital,patientLocation: GeoPoint(latLng.latitude, latLng.longitude));
    } else {
      _removePatientAmbulancePolyLine();
      _removeHospitalLocationMarker();
    }
  }

  //single remove patient to ambulance route line
  _removePatientAmbulancePolyLine() {
    setState(() {
      _ambulancePatientPolyLineContainer.forEach((polylineMarkerId) {
        if (polyline.containsKey(polylineMarkerId)) {
          polyline.remove(polylineMarkerId);
        }
      });
    });
  }
//single patient to ambulance route line
  _patientAmbulancePolyLine({GeoPoint patientLocation, GeoPoint ambulanceLocation}) async {
    final List<LatLng> routes = List();
    routes.add(LatLng(patientLocation.latitude, patientLocation.longitude));
    routes.add(LatLng(ambulanceLocation.latitude, ambulanceLocation.longitude));
    _customPolylineId = PolylineId('currentRoutes1}');
    _ambulancePatientPolyLineContainer.add(_customPolylineId);
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

  //single ambulance marker that user selected
  _ambulanceLocationMarker(GeoPoint ambulance, String driverName) async {
    final Uint8List patientMarker =
        await getBytesFromAsset("assets/ambulance.png", 100);
    _ambulanceLocationMarkerId = MarkerId('AmbulanceMarkerId9291}');
    _ambulanceMarkerIdContiner.add(_ambulanceLocationMarkerId);
    var ambulanceMarker = Marker(
        consumeTapEvents: true,
        onTap: () {
          print("DriverName $driverName");
        },
        markerId: _ambulanceLocationMarkerId,
        icon: BitmapDescriptor.fromBytes(patientMarker),
        position: LatLng(ambulance.latitude, ambulance.longitude),
        infoWindow: InfoWindow(
            title: "${ambulance.latitude},${ambulance.longitude}",
            snippet: 'Patient name $driverName *Patient Location'));
    setState(() {
      setMarkers[_ambulanceLocationMarkerId] = ambulanceMarker;
    });
  }

  //single ambulance marker remove form the map
  _removeAmbulanceLocationMarker() {
    setState(() {
      _ambulanceMarkerIdContiner.forEach((ambulanceMarkerId) {
        if (setMarkers.containsKey(ambulanceMarkerId)) {
          setMarkers.remove(ambulanceMarkerId);
        }
      });
    });
  }
  //remove single hospital marker
  _removeHospitalLocationMarker(){
    setState(() {
      if (setMarkers.containsKey(_hospitalLocationMarkerId)) {
        setMarkers.remove(_hospitalLocationMarkerId);
      }
    });
  }
  //single hospital marker that patient select
  _hospitalLocationMarker({GeoPoint hospital})async{
    if (hospital != null) {
      final Uint8List hospitalMarker =
          await getBytesFromAsset("assets/hospital.png", 100);
      print("checkPointLocation ${hospital.latitude} ,${hospital.longitude}");
      _hospitalLocationMarkerId = MarkerId('hospitalMarkerId001');
      var hospitalMarkerId = Marker(
          consumeTapEvents: true,
          onTap: () {

          },
          markerId: _hospitalLocationMarkerId,
          icon: BitmapDescriptor.fromBytes(hospitalMarker),
          position: LatLng(hospital.latitude, hospital.longitude),
          infoWindow: InfoWindow(
              title: "${hospital.latitude},${hospital.longitude}",),);
      setState(() {
        setMarkers[_hospitalLocationMarkerId] = hospitalMarkerId;
      });
    }
  }

  //single route line btw patient and hospital
  _patientToHospitalPolyLine(
      {GeoPoint patientLocation, GeoPoint hospitalLocation}) async {
    assert(patientLocation!=null);
    assert(hospitalLocation!=null);
    final List<LatLng> routes = List();
    routes.add(LatLng(patientLocation.latitude, patientLocation.longitude));
    routes.add(LatLng(hospitalLocation.latitude, hospitalLocation.longitude));
    _patientToHospitalPolylineId = PolylineId('PaitenttoHospitalRountePoint001');
    _ambulancePatientPolyLineContainer.add(_patientToHospitalPolylineId);
    var line = Polyline(
      polylineId: _patientToHospitalPolylineId,
      consumeTapEvents: true,
      width: 6,
      color: Colors.red,
      jointType: JointType.bevel,
      points: routes,
    );

    setState(() {
      polyline[_patientToHospitalPolylineId] = line;
    });
  }


  //get nearbyHospital form server
  void getNearByPlaces() async {
    final result = await PlacesRepository().getNearByPlaces(latLng);
    final Uint8List hospitalMarkerIcon =
        await getBytesFromAsset("assets/hospital.png", 100);
    result.forEach((places) {
      _hospitalMarkerId = MarkerId("hospitalMarkerId${Random().nextInt(50)}");
      _hospitalMarkerIdContainer.add(_hospitalMarkerId);
      Marker marker = Marker(
        markerId: _hospitalMarkerId,
        onTap: () async {
          setState(() {
            _hospitalCurrentLocation = GeoPoint(
                places.geometry.location.lat,
                places.geometry.location.lng);
            Fluttertoast.showToast(msg: "${places.name} is sellected successfuly",toastLength: Toast.LENGTH_SHORT,backgroundColor: Colors.red);
            print("hospitalName ${places.name},${ places.geometry.location.lat},${places.geometry.location.lng}");
          });
        },
        icon: BitmapDescriptor.fromBytes(hospitalMarkerIcon),
        infoWindow: InfoWindow(
            title: "${places.name}",
            snippet: "${places.formattedAddress}"),
        position:
            LatLng(places.geometry.location.lat, places.geometry.location.lng),
      );
      setState(() {
        setMarkers[_hospitalMarkerId] = marker;
      });
    });
  }
  //nearbyHospital all marker remove form the map
  _removeHospitalMarker() async {
    setState(() {
      _hospitalMarkerIdContainer.forEach((markerIds) {
        if (setMarkers.containsKey(markerIds)) {
          setMarkers.remove(markerIds);
        }
      });
    });
  }
}
