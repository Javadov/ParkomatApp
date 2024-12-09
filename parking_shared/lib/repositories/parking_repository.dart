import '../models/parking.dart';
import '../objectbox.g.dart';

class ParkingRepository {
  final Box<Parking> _parkingBox;

  ParkingRepository(Store store) : _parkingBox = store.box<Parking>();

  List<Parking> getAll() => _parkingBox.getAll();

  // Get active parkings for a specific user
  List<Parking> getActiveParkingsByUser(String email) {
    final now = DateTime.now();
    return _parkingBox
      .query(
        Parking_.userEmail.equals(email) &
        Parking_.endTime.greaterThan(now.millisecondsSinceEpoch),
      )
      .build()
      .find();
  }

  // Get parking history for a specific user
  List<Parking> getParkingHistoryByUser(String email) {
    final now = DateTime.now();
    return _parkingBox
      .query(
        Parking_.userEmail.equals(email) &
        Parking_.endTime.lessThan(now.millisecondsSinceEpoch),
      )
      .build()
      .find();
  }

  List<Parking> getByUserEmail(String email) {
    return _parkingBox.query(Parking_.userEmail.equals(email)).build().find();
  }

  Parking? getById(int id) => _parkingBox.get(id); 

  void add(Parking parking) => _parkingBox.put(parking);

  void update(Parking parking) => _parkingBox.put(parking);

  void delete(int id) => _parkingBox.remove(id);
}
