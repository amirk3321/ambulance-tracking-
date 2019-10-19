import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:ksars_smart/api_key.dart';
import 'package:google_maps_webservice/directions.dart';



class PlacesRepository{
  GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: API_KEY1);
  GoogleMapsDirections _directions=GoogleMapsDirections(apiKey: API_KEY2);

  Future<List<PlacesSearchResult>> getNearByPlaces(LatLng latLng)async{
    final location=Location(latLng.latitude,latLng.longitude);
    final response=await _places.searchByText("hospital",location: location,radius: 45000,type: "hospital");
    if (response.status == "OK")
      return response.results;
    else{
      print("placesErrorMessage${response.errorMessage}");
      return [];
    }
  }
  Future<List<Route>> direction(LatLng origin,LatLng destination)async{
      final startOrigin=Location(origin.latitude,origin.longitude);
      final endDestination=Location(destination.latitude,destination.longitude);
      final directionResponse=await _directions.directionsWithLocation(startOrigin, endDestination);
      if (directionResponse.status=="OK")
         return directionResponse.routes;
      else{
        print("DirectionError ${directionResponse.errorMessage}");
        return [];
      }
  }
}



class NoSearchResultException implements Exception{
  final message='No Result';
}