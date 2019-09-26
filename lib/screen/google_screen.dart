import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ksars_smart/bloc/auth/bloc.dart';
import 'package:ksars_smart/bloc/user/bloc.dart';
import 'package:location/location.dart';

class GoogleScreen extends StatefulWidget {
  final String uid;

  GoogleScreen({Key key, this.uid}) : super(key: key);

  @override
  State<StatefulWidget> createState() => GoogleScreenState();
}

class GoogleScreenState extends State<GoogleScreen> {
  final markerId = MarkerId('current01');
  var scaffoldKey = GlobalKey<ScaffoldState>();
  List<Marker> markers = <Marker>[];
  GoogleMapController _mapController;
  MapType _mapType;
  bool isNormal = false;
  LatLng latLng = LatLng(24.9056, 67.0822);
  Map<MarkerId, Marker> marker = <MarkerId, Marker>{};
  Map<MarkerId, Marker> setMarkers = <MarkerId, Marker>{};
  Map<PolylineId, Polyline> polyline = <PolylineId, Polyline>{};
  Map<PolygonId, Polygon> polygon = <PolygonId, Polygon>{};

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      _mapController = controller;
      print('my uid ${widget.uid}');
    });
  }

  var _isShowScaffold = true;

  Location _location = Location();

  Geoflutterfire geo = Geoflutterfire();

  //GeoFirePoint point=geo.point(latitude: locationData.latitude, longitude: locationData.longitude);

  @override
  void initState() {
    _addCurrentMarker();
    _location.onLocationChanged().listen((locationData) {
      latLng = LatLng(locationData.latitude, locationData.longitude);
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
              .firstWhere((user) => user.uid == widget.uid, orElse: null);
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
            body: Stack(
              children: <Widget>[
                GoogleMap(
                  onMapCreated: _onMapCreated,
                  mapType: _mapType,
                  indoorViewEnabled: true,
                  trafficEnabled: true,
                  polylines:Set<Polyline>.of(polyline.values),
                  rotateGesturesEnabled: true,
                  polygons: Set<Polygon>.of(polygon.values),
                  onLongPress: (location) {
                    _setCurrentMarker(location.latitude, location.longitude);
                    assert(_isShowScaffold == true);
                    Scaffold.of(context).showSnackBar(SnackBar(
                      duration: Duration(minutes: 60),
                      content: Stack(
                        children: <Widget>[
                          RaisedButton(
                            child: Text('Start travel'),
                            onPressed: () {
                              _drawRoutePolygon(location.latitude, location.longitude);
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
                                Scaffold.of(context).hideCurrentSnackBar();
                                setState(() {
                                  _isShowScaffold=true;
                                  _removeMarker();
                                });

                              },
                            ),
                          ),
                        ],
                      ),
                    ));
                    setState(() {
                      _isShowScaffold = false;
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
                    onPressed: () => scaffoldKey.currentState.openDrawer(),
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

  _addCurrentMarker() async {

    var point = await _location.getLocation();
    final markerId = MarkerId('current0');
    var marker1 = Marker(
        markerId: markerId,
        position: LatLng(point.latitude, point.longitude),
        infoWindow: InfoWindow(
            title: "${point.latitude},${point.longitude}",
            snippet: '*current Location'));
    setState(() {
      setMarkers[markerId] = marker1;
    });
  }

  _setCurrentMarker(lat, long) async {

    var marker1 = Marker(
        markerId: markerId,
        position: LatLng(lat, long),
        infoWindow: InfoWindow(title: "$lat,$long", snippet: '*'));
    setState(() {
      setMarkers[markerId] = marker1;
    });
  }
  _removeMarker(){
   setState(() {
     if (markers.contains(markerId)){
       markers.remove(markerId);
     }
   });
  }
  _drawRoute(lat,lang)async{
    final current=await _location.getLocation();
    final List<LatLng> routes=List();
    routes.add(LatLng(lat,lang));
    routes.add(LatLng(current.latitude,current.longitude));
    final PolylineId polylineId=PolylineId('currentRoutes1');
    var line=Polyline(
      polylineId:polylineId,
      consumeTapEvents: true,
      width: 6,
      color: Colors.red,
      geodesic: true,
      endCap: Cap.roundCap,
      startCap: Cap.buttCap,
      visible: true,
      jointType: JointType.bevel,
      points: routes,
    );

    setState(() {
      polyline[polylineId]=line;
    });
  }

  _drawRoutePolygon(lat,lang)async{
    final current=await _location.getLocation();
    final List<LatLng> routes=List();
    routes.add(LatLng(lat,lang));
    routes.add(LatLng(current.latitude,current.longitude));
    final PolygonId polygonId=PolygonId('currentRoutes1');
    var line=Polygon(
      polygonId:polygonId,
      consumeTapEvents: true,
      geodesic: true,
      fillColor: Colors.red,
      points: routes,
    );

    setState(() {
      polygon[polygonId]=line;
    });
  }
}
