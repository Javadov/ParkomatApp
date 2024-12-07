import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:parking_shared/models/parking_space.dart';

class ParkingSpaceService {
  final String baseUrl = 'http://localhost:8080/parking-spaces';

  Future<bool> addParkingSpace(ParkingSpace parkingSpace) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(parkingSpace.toJson()),
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Failed to add parking space: $e');
    }
  }

  Future<bool> updateParkingSpace(ParkingSpace parkingSpace) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/${parkingSpace.id}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(parkingSpace.toJson()),
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Failed to update parking space: $e');
    }
  }

  Future<bool> deleteParkingSpace(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/$id'),
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Failed to delete parking space: $e');
    }
  }

  Future<List<ParkingSpace>> getAllParkingSpaces() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => ParkingSpace.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch parking spaces');
      }
    } catch (e) {
      throw Exception('Error fetching parking spaces: $e');
    }
  }
}
