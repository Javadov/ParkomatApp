import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../repositories/parking_repository.dart';
import '../models/parking.dart';

class ParkingHandler {
  final ParkingRepository repository;

  ParkingHandler(this.repository);

  Router get router {
    final router = Router();

    // Get all parkings
    router.get('/', (Request request) async {
      final parkings = repository.getAll();
      return Response.ok(
        jsonEncode(parkings.map((parking) => parking.toJson()).toList()),
        headers: {'Content-Type': 'application/json'},
      );
    });

    // Get active parkings
    router.get('/active', (Request request) async {
      final email = request.url.queryParameters['userEmail'];
      if (email == null) {
        return Response.badRequest(body: 'userEmail is required');
      }

      final activeParkings = repository.getActiveParkingsByUser(email);
      return Response.ok(
        jsonEncode(activeParkings.map((parking) => parking.toJson()).toList()),
        headers: {'Content-Type': 'application/json'},
      );
    });

    // Get parking history
    router.get('/history', (Request request) async {
      final email = request.url.queryParameters['userEmail'];
      if (email == null) {
        return Response.badRequest(body: 'userEmail is required');
      }

      final parkingHistory = repository.getParkingHistoryByUser(email);
      return Response.ok(
        jsonEncode(parkingHistory.map((parking) => parking.toJson()).toList()),
        headers: {'Content-Type': 'application/json'},
      );
    });

    // Get parkings by user email
    router.get('/user/<email>', (Request request, String email) async {
      try {
        final userParkings = repository.getByUserEmail(email);
        return Response.ok(
          jsonEncode(userParkings.map((parking) => parking.toJson()).toList()),
          headers: {'Content-Type': 'application/json'},
        );
      } catch (e) {
        return Response.internalServerError(body: 'Failed to fetch parkings for user');
      }
    });

    // Add a new parking
    router.post('/', (Request request) async {
      try {
        final payload = await request.readAsString();
        final data = jsonDecode(payload);
        final newParking = Parking.fromJson(data);
        repository.add(newParking);
        return Response.ok('Parking added successfully');
      } catch (e) {
        return Response.internalServerError(body: 'Failed to add parking');
      }
    });

    // Update active parking
    router.put('/<id|[0-9]+>', (Request request, String id) async {
      try {
        final parkingId = int.parse(id);
        final payload = await request.readAsString();
        final data = jsonDecode(payload);
        final newEndTime = DateTime.parse(data['newEndTime']);

        final parking = repository.getById(parkingId);
        double parkingCostPerHour = 10.0;

        if (parking == null) {
          return Response.notFound('Parking not found');
        }

        final durationInMinutes = newEndTime.difference(parking.startTime).inMinutes;
        final updatedCost = (durationInMinutes / 60) * parkingCostPerHour; // Adjust total cost

        parking.endTime = newEndTime;
        parking.totalCost = updatedCost;

        repository.update(parking);

        return Response.ok(jsonEncode(parking.toJson()), headers: {'Content-Type': 'application/json'});
      } catch (e) {
        return Response.internalServerError(body: 'Failed to update parking: $e');
      }
    });

    // Delete active parking
    router.delete('/<id|[0-9]+>', (Request request, String id) async {
      try {
        final int parsedId = int.parse(id);

        repository.delete(parsedId);
        return Response.ok('Parking deleted successfully');
      } catch (e) {
        return Response.internalServerError(body: 'Failed to delete parking');
      }
    });

    return router;
  }
}