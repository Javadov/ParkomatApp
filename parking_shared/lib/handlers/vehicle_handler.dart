import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../repositories/vehicle_repository.dart';
import '../models/vehicle.dart';

class VehicleHandler {
  final VehicleRepository repository;

  VehicleHandler(this.repository);

  Router get router {
    final router = Router();

    // Get all vehicles
    router.get('/', (Request request) async {
      final vehicles = repository.getAll();
      return Response.ok(
        jsonEncode(vehicles.map((vehicle) => vehicle.toJson()).toList()),
        headers: {'Content-Type': 'application/json'},
      );
    });

    // Get vehicles by user UserMail
    router.get('/<userEmail>', (Request request, String userEmail) async {
      try {
        final vehicles = repository.getByUserEmail(userEmail);
        return Response.ok(
          jsonEncode(vehicles.map((vehicle) => vehicle.toJson()).toList()),
          headers: {'Content-Type': 'application/json'},
        );
      } catch (e) {
        return Response.internalServerError(body: 'Failed to fetch vehicles');
      }
    });

    // Get vehicles by user ID
    router.get('/<userId|[0-9]+>', (Request request, String userId) async {
      try {
        final id = int.parse(userId); 
        final vehicles = repository.getByUserId(id);
        return Response.ok(
          jsonEncode(vehicles.map((vehicle) => vehicle.toJson()).toList()),
          headers: {'Content-Type': 'application/json'},
        );
      } catch (e) {
        return Response.internalServerError(body: 'Failed to fetch vehicles');
      }
    });

    // Add a new vehicle
    router.post('/', (Request request) async {
      try {
        final payload = await request.readAsString();
        final data = jsonDecode(payload);
        final newVehicle = Vehicle.fromJson(data);
        repository.add(newVehicle);
        return Response.ok('Vehicle added successfully');
      } catch (e) {
        return Response.internalServerError(body: 'Failed to add vehicle');
      }
    });

    // Update a vehicle by ID
    router.put('/<id|[0-9]+>', (Request request, String id) async {
      try {
        final vehicleId = int.parse(id);
        final payload = await request.readAsString();
        final updatedData = jsonDecode(payload);

        final updatedVehicle = Vehicle.fromJson(updatedData);
        updatedVehicle.id = vehicleId; // Ensure the ID is preserved

        final success = repository.update(vehicleId, updatedVehicle);

        if (success) {
          return Response.ok('Vehicle updated successfully');
        } else {
          return Response.notFound('Vehicle not found');
        }
      } catch (e) {
        return Response.internalServerError(body: 'Failed to update vehicle');
      }
    });

    // Delete a vehicle
    router.delete('/<registrationNumber>', (Request request, String registrationNumber) async {
      try {
        repository.delete(registrationNumber);
        return Response.ok('Vehicle deleted successfully');
      } catch (e) {
        return Response.internalServerError(body: 'Failed to delete vehicle');
      }
    });

    return router;
  }
}