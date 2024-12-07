import 'package:objectbox/objectbox.dart';
import '../util/serializer.dart';
import '../util/identifiable.dart';

@Entity()
class ParkingSpace extends Identifiable {
  @override
  @Id()
  int id;

  String address;
  String city;
  String zipCode;
  String country;
  double latitude;
  double longitude;
  double pricePerHour;

  ParkingSpace({required this.address, required this.city, required this.zipCode, required this.country, required this.latitude, required this.longitude, required this.pricePerHour, this.id = -1});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'address': address,
      'city': city,
      'zipCode': zipCode,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
      'pricePerHour': pricePerHour,
    };
  }

  factory ParkingSpace.fromJson(Map<String, dynamic> json) {
    return ParkingSpace(
      address: json['address'] as String,
      city: json['city'] as String,
      zipCode: json['zipCode'] as String,
      country: json['country'] as String,
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
      pricePerHour: json['pricePerHour'] as double,
      id: json['id'] as int? ?? 0,
    );
  }

  @override
  bool isValid() {
    return address.isNotEmpty &&
    city.isNotEmpty &&
    zipCode.isNotEmpty &&
    country.isNotEmpty &&
    pricePerHour > 0 &&
    latitude != 0 &&
    longitude != 0;
  }

  @override
  String toString() {
    return "Id: $id, Address: $address, City: $city, Zip: $zipCode, Country: $country, "
        "Position: ($latitude, $longitude), Price Per Hour: \$${pricePerHour.toStringAsFixed(2)}";
  }
}

class ParkingSpaceSerializer extends Serializer<ParkingSpace> {
  @override
  Map<String, dynamic> toJson(ParkingSpace item) {
    return item.toJson();
  }

  @override
  ParkingSpace fromJson(Map<String, dynamic> json) {
    return ParkingSpace.fromJson(json);
  }
}