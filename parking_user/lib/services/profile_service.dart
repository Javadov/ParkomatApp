import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ProfileService {
  final String baseUrl = 'http://localhost:8080';

  Future<String?> fetchUserEmail(String sessionEmail) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/users/$sessionEmail'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['email'];
      }
    } catch (e) {
      print('Failed to fetch user email: $e');
    }
    return null;
  }

  // Future<List<Map<String, dynamic>>> fetchUserVehicles(int userId) async {
  //   try {
  //     final response = await http.get(Uri.parse('$baseUrl/vehicles/$userId'));
  //     if (response.statusCode == 200) {
  //       return List<Map<String, dynamic>>.from(jsonDecode(response.body));
  //     }
  //   } catch (e) {
  //     print('Failed to fetch vehicles: $e');
  //   }
  //   return [];
  // }

  Future<List<Map<String, dynamic>>> fetchUserVehicles(String email) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/vehicles/$email'));
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      }
    } catch (e) {
      print('Failed to fetch vehicles: $e');
    }
    return [];
  }

  Future<bool> updateUserEmail(String currentEmail, String newEmail) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/users'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': currentEmail, 'newEmail': newEmail}),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Failed to update email: $e');
    }
    return false;
  }

  Future<bool> addVehicle(String email, String registrationNumber, String type) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/vehicles'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userEmail': email,
          'registrationNumber': registrationNumber,
          'type': type,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Failed to add vehicle: $e');
    }
    return false;
  }

  Future<bool> updateVehicle(int id, Map<String, dynamic> updatedVehicle) async {
    try {
      final response = await http.put(
        Uri.parse('http://localhost:8080/vehicles/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(updatedVehicle),
      );

      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        print('Error updating vehicle: $e');
      }
      return false;
    }
  }

  Future<bool> deleteVehicle(String registrationNumber) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/vehicles/$registrationNumber'),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Failed to delete vehicle: $e');
    }
    return false;
  }
}
