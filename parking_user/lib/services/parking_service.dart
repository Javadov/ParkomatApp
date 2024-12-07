import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:parking_shared/models/parking.dart';
import 'package:parking_shared/models/parking_space.dart';

class ParkingService {
  final String baseUrl = 'http://localhost:8080';

  Future<List<ParkingSpace>> getAllParkingSpaces() async {
    final response = await http.get(Uri.parse('$baseUrl/parking-spaces'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => ParkingSpace.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch parking spaces');
    }
  }

  Future<List<ParkingSpace>> searchParkingSpaces(String query) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/parking-spaces/search?query=$query'));
      if (response.statusCode == 200) {
        return List<ParkingSpace>.from(jsonDecode(response.body).map((x) => ParkingSpace.fromJson(x)));
      } else {
        throw Exception('Failed to search parking spaces');
      }
    } catch (e) {
      throw Exception('Error searching parking spaces: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getUserVehicles(String userEmail) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/vehicles/$userEmail'));
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      } else {
        throw Exception('Failed to fetch vehicles');
      }
    } catch (e) {
      throw Exception('Error fetching vehicles: $e');
    }
  }

  Future<bool> startParking({required String userEmail, required String registrationNumber, required int parkingSpaceId, required DateTime startTime, required DateTime endTime, required double totalCost}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/parkings'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'startTime': startTime.toIso8601String(),
          'endTime': endTime.toIso8601String(),
          'totalCost': totalCost,
          'userEmail': userEmail,
          'vehicleRegistrationNumber': registrationNumber,
          'parkingSpaceId': parkingSpaceId,
        }),
      );

      if (response.statusCode == 200) {
        return true; // Parking start successful
      } else {
        print('Failed to start parking: ${response.body}');
        return false; // Parking start failed
      }
    } catch (e) {
      print('Error starting parking: $e');
      return false; // Error occurred
    }
  }

  /// Fetches the active parkings for the logged-in user.
  Future<List<Parking>> getActiveParkings({required String userEmail}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/parkings/active?userEmail=$userEmail'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Parking.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch active parkings');
      }
    } catch (e) {
      throw Exception('Error fetching active parkings: $e');
    }
  }

  /// Fetches the parking history for the logged-in user.
  Future<List<Parking>> getParkingHistory({required String userEmail}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/parkings/history?userEmail=$userEmail'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Parking.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch parking history');
      }
    } catch (e) {
      throw Exception('Error fetching parking history: $e');
    }
  }

  /// Updates the end time of an active parking and recalculates the total cost.
  Future<bool> updateParkingEndTime(int parkingId, DateTime newEndTime) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/parkings/$parkingId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'newEndTime': newEndTime.toIso8601String()}),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to update parking end time');
      }
    } catch (e) {
      throw Exception('Error updating parking end time: $e');
    }
  }
}
