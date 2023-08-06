// ignore_for_file: public_member_api_docs, sort_constructors_first

class LocationModel {
  String? name;
  String? id;
  String? lat;
  String? lng;

  LocationModel({
    this.name,
    this.id,
    this.lat,
    this.lng,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      name: json["name"],
      id: json["id"],
      lat: json["lat"],
      lng: json["lng"],
    );
  }





  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'id': id,
      'lat': lat,
      'lng': lng,
    };
  }
//
}
