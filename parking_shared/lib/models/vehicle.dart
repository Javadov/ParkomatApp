import 'package:objectbox/objectbox.dart';
import '../util/validators.dart';
import '../util/serializer.dart';
import '../util/identifiable.dart';

@Entity()
class Vehicle extends Identifiable {
  @override
  @Id()
  int id;

  String registrationNumber;
  String type;

  @Property()
  String userEmail; // Reference to User by email

  Vehicle(this.registrationNumber, this.type, this.userEmail, [this.id = -1]);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'registrationNumber': registrationNumber,
      'type': type,
      'userEmail': userEmail,
    };
  }

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      json['registrationNumber'] as String,
      json['type'] as String,
      json['userEmail'] as String,
      json['id'] as int? ?? 0,
    );
  }

  @override
  bool isValid() {
    return Validators.isValidRegistrationNumber(registrationNumber) &&
        Validators.isValidVehicleType(type);
  }

  @override
  String toString() {
    return "Id: $id, Registration Number: $registrationNumber, Type: $type, UserEmail: $userEmail";
  }
}

class VehicleSerializer extends Serializer<Vehicle> {
  @override
  Map<String, dynamic> toJson(Vehicle item) {
    return {
      'id': item.id,
      'registrationNumber': item.registrationNumber,
      'type': item.type,
      'userEmail': item.userEmail,
    };
  }

  @override
  Vehicle fromJson(Map<String, dynamic> json) {
    return Vehicle(
      json['registrationNumber'] as String,
      json['type'] as String,
      json['userEmail'] as String,
      json['id'] as int,
    );
  }
}