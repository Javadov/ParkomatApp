import 'package:objectbox/objectbox.dart';
import 'package:parking_shared/objectbox.g.dart';
import '../models/parking_space.dart';

class ParkingSpaceRepository {
  final Box<ParkingSpace> _parkingSpaceBox;

  ParkingSpaceRepository(Store store) : _parkingSpaceBox = store.box<ParkingSpace>();

  List<ParkingSpace> getAll() => _parkingSpaceBox.getAll();

  ParkingSpace? getById(int id) => _parkingSpaceBox.get(id);

  void add(ParkingSpace parkingSpace) => _parkingSpaceBox.put(parkingSpace);

  bool update(int id, ParkingSpace updatedParkingSpace) {
    final existingVehicle = _parkingSpaceBox.get(id);
    if (existingVehicle != null) {
      _parkingSpaceBox.put(updatedParkingSpace);
      return true;
    }
    return false;
  }  

  List<ParkingSpace> search(String query) {
    return _parkingSpaceBox
        .query(
          ParkingSpace_.address.contains(query) |
          ParkingSpace_.city.contains(query) |
          ParkingSpace_.zipCode.contains(query) |
          ParkingSpace_.country.contains(query),
        )
        .build()
        .find();
  }

  void delete(int id) => _parkingSpaceBox.remove(id);
}
