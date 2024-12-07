import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../repositories/parking_space_repository.dart';
import '../models/parking_space.dart';

class ParkingSpaceHandler {
  final ParkingSpaceRepository repository;

  ParkingSpaceHandler(this.repository);

  Router get router {
    final router = Router();

    // Get all parking spaces
    router.get('/', (Request request) async {
      final parkingSpaces = repository.getAll();
      return Response.ok(
        jsonEncode(parkingSpaces.map((space) => space.toJson()).toList()),
        headers: {'Content-Type': 'application/json'},
      );
    });

    // Add a new parking space
    router.post('/', (Request request) async {
      try {
        final payload = await request.readAsString();
        final data = jsonDecode(payload);
        final newSpace = ParkingSpace.fromJson(data);
        repository.add(newSpace);
        return Response.ok('Parking space added successfully');
      } catch (e) {
        return Response.internalServerError(body: 'Failed to add parking space');
      }
    });

    // Update a parking space by ID
    router.put('/<id|[0-9]+>', (Request request, String id) async {
      try {
        final spaceId = int.parse(id);
        final payload = await request.readAsString();
        final updatedData = jsonDecode(payload);

        final updatedParkingSpace = ParkingSpace.fromJson(updatedData);
        updatedParkingSpace.id = spaceId; // Ensure the ID is preserved

        final success = repository.update(spaceId, updatedParkingSpace);

        if (success) {
          return Response.ok('Vehicle updated successfully');
        } else {
          return Response.notFound('Vehicle not found');
        }
      } catch (e) {
        return Response.internalServerError(body: 'Failed to update vehicle');
      }
    });

    // Search a parking space
    router.get('/search', (Request request) async {
      try {
        final queryParams = request.url.queryParameters['query'];
        if (queryParams == null || queryParams.isEmpty) {
          return Response(400, body: 'Query parameter is required');
        }

        final parkingSpaces = repository.search(queryParams);
        return Response.ok(
          jsonEncode(parkingSpaces.map((parking) => parking.toJson()).toList()),
          headers: {'Content-Type': 'application/json'},
        );
      } catch (e) {
        return Response.internalServerError(body: 'Failed to search parking spaces');
      }
    });

    // Delete a parking space
    router.delete('/<id|[0-9]+>', (Request request, String id) async {
      try {
        final spaceId = int.parse(id);
        repository.delete(spaceId);
        return Response.ok('Parking space deleted successfully');
      } catch (e) {
        return Response.internalServerError(body: 'Failed to delete parking space');
      }
    });

    return router;
  }
}
