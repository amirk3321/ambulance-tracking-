

import 'package:geolocator/geolocator.dart';


class LocationRepo{

  //current location of the device
  getCurrentLocation()async{
    Position position =await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
    return position;
  }
  getLastLocation()async{
    Position position=await Geolocator().getLastKnownPosition(desiredAccuracy: LocationAccuracy.best);
    return position;
  }
  getPermissionLocation()async{
    Geolocator geolocator=Geolocator()..forceAndroidLocationManager=true;
    GeolocationStatus geolocationStatus=await geolocator.checkGeolocationPermissionStatus();

  }
//To translate an address into latitude and longitude coordinates
  setPlaceMarkFromAddress(String address)async{
    List<Placemark> placeMark=await Geolocator().placemarkFromAddress(address);
    return placeMark;
  }
  //latitude and longitude coordinates into an address
  setPlaceMarkFromCoordinates(lat,long)async{
    List<Placemark> placeMark=await Geolocator().placemarkFromCoordinates(lat, long);
    return placeMark;
  }

  getCalculateDistance(startLat,startLong,endLat,endLong)async{
    double distanceInMeter=await Geolocator().distanceBetween(startLat, startLong, endLat, endLong);
    return distanceInMeter;
  }
  setCustomMarker()async{
    
  }

  setCurrentMarker(){}

  removeCustomMarker(){}

  calculateDistanceInMeter(){}


}