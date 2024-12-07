import 'package:objectbox/objectbox.dart';
import '../util/serializer.dart';
import '../util/identifiable.dart';

@Entity()
class Parking extends Identifiable {
  @override
  @Id()
  int id;

  @Property(type: PropertyType.date)
  DateTime startTime;

  @Property(type: PropertyType.date)
  DateTime? endTime;

  double totalCost;

  @Property()
  String userEmail; // Reference to User by email

  @Property()
  String vehicleRegistrationNumber; // Relation to Vehicle

  @Property()
  int parkingSpaceId; // Relation to ParkingSpace

  Parking({
    required this.startTime,
    this.endTime,
    required this.totalCost,
    required this.userEmail,
    required this.vehicleRegistrationNumber,
    required this.parkingSpaceId,
    this.id = -1,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'totalCost': totalCost,
      'userEmail': userEmail,
      'vehicleRegistrationNumber': vehicleRegistrationNumber,
      'parkingSpaceId': parkingSpaceId,
    };
  }

  factory Parking.fromJson(Map<String, dynamic> json) {
    return Parking(
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime'] as String) : null,
      totalCost: json['totalCost'] as double,
      userEmail: json['userEmail'] as String,
      vehicleRegistrationNumber: json['vehicleRegistrationNumber'] as String,
      parkingSpaceId: json['parkingSpaceId'] as int,
      id: json['id'] as int? ?? 0,
    );
  }

  @override
  bool isValid() {
    return totalCost >= 0 && parkingSpaceId > 0;
  }

  @override
  String toString() {
    return "Id: $id, Start Time: $startTime, End Time: $endTime, Total Cost: \$${totalCost.toStringAsFixed(2)}, UserEmail: $userEmail, vehicleRegistrationNumber: $vehicleRegistrationNumber, ParkingSpaceId: $parkingSpaceId";
  }
}

class ParkingSerializer extends Serializer<Parking> {
  @override
  Map<String, dynamic> toJson(Parking item) {
    return {
      'id': item.id,
      'startTime': item.startTime.toIso8601String(),
      'endTime': item.endTime?.toIso8601String(),
      'totalCost': item.totalCost,
      'userEmail': item.userEmail,
      'vehicleRegistrationNumber': item.vehicleRegistrationNumber,
      'parkingSpaceId': item.parkingSpaceId,
    };
  }

  @override
  Parking fromJson(Map<String, dynamic> json) {
    return Parking(
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime'] as String) : null,
      totalCost: json['totalCost'] as double,
      userEmail: json['userEmail'] as String,
      vehicleRegistrationNumber: json['vehicleRegistrationNumber'] as String,
      parkingSpaceId: json['parkingSpaceId'] as int,
      id: json['id'] as int,
    );
  }
}