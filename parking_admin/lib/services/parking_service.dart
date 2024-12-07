import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:parking_shared/models/parking.dart';

class ParkingService {
  final String baseUrl = 'http://localhost:8080';

  /// Fetches all parkings (active and historical).
  Future<List<Parking>> getAllParkings() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/parkings'));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Parking.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch all parkings');
      }
    } catch (e) {
      throw Exception('Error fetching all parkings: $e');
    }
  }

  /// Fetches all active parkings.
  Future<List<Parking>> getActiveParkings() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/parkings/active'));

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

  /// Fetches all parking history.
  Future<List<Parking>> getParkingHistory() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/parkings/history'));

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

  /// Stops an active parking by updating its end time.
  Future<bool> stopParking(int parkingId, DateTime endTime) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/parkings/$parkingId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'newEndTime': endTime.toIso8601String()}),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to stop parking');
      }
    } catch (e) {
      throw Exception('Error stopping parking: $e');
    }
  }

  /// Extends a parking's end time.
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
        throw Exception('Failed to extend parking end time');
      }
    } catch (e) {
      throw Exception('Error extending parking end time: $e');
    }
  }

  /// Deletes a parking record (for admin purposes).
  Future<bool> deleteParking(int parkingId) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/parkings/$parkingId'));

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to delete parking');
      }
    } catch (e) {
      throw Exception('Error deleting parking: $e');
    }
  }

  /// Searches for parkings globally by various fields.
  Future<List<Parking>> searchParkings(String query) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/parkings/search?query=$query'));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Parking.fromJson(json)).toList();
      } else {
        throw Exception('Failed to search parkings');
      }
    } catch (e) {
      throw Exception('Error searching parkings: $e');
    }
  }
}