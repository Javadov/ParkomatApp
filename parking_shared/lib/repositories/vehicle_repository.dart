import '../models/vehicle.dart';
import '../objectbox.g.dart';

class VehicleRepository {
  final Box<Vehicle> _vehicleBox;

  VehicleRepository(Store store) : _vehicleBox = store.box<Vehicle>();

  /// Get all vehicles
  List<Vehicle> getAll() => _vehicleBox.getAll();

  // Get vehicles by user email
  List<Vehicle> getByUserEmail(String userEmail) {
    return _vehicleBox.query(Vehicle_.userEmail.equals(userEmail)).build().find();
  }

  // Get vehicles by user id
  List<Vehicle> getByUserId(int userId) {
    return _vehicleBox.query(Vehicle_.id.equals(userId)).build().find();
  }

  /// Add a new vehicle
  void add(Vehicle vehicle) => _vehicleBox.put(vehicle);

  /// Delete a vehicle by registration number
  void delete(String registrationNumber) {
    final vehicle = _vehicleBox
        .query(Vehicle_.registrationNumber.equals(registrationNumber))
        .build()
        .findFirst();
    if (vehicle != null) {
      _vehicleBox.remove(vehicle.id);
    }
  }

  /// Get a vehicle by registration number
  Vehicle? get(String registrationNumber) {
    return _vehicleBox
        .query(Vehicle_.registrationNumber.equals(registrationNumber))
        .build()
        .findFirst();
  }

  /// Update a vehicle
  bool update(int id, Vehicle updatedVehicle) {
    final existingVehicle = _vehicleBox.get(id);
    if (existingVehicle != null) {
      _vehicleBox.put(updatedVehicle); // Update the vehicle
      return true;
    }
    return false;
  }
}