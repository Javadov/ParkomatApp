import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../repositories/user_repository.dart';
import '../models/user.dart';

class UserHandler {
  final UserRepository repository;

  UserHandler(this.repository);

  Router get router {
    final router = Router();

    // Route: Get all users
    router.get('/', (Request request) async {
      final users = repository.getAll();
      final response = jsonEncode(users.map((user) => user.toJson()).toList());
      return Response.ok(response, headers: {'Content-Type': 'application/json'});
    });

    // Route: Register a new user
    router.post('/', (Request request) async {
      try {
        final payload = await request.readAsString();
        final data = jsonDecode(payload);
        final newUser = User.fromJson(data);

        if (!newUser.isValid()) {
          return Response(400, body: 'Invalid user data');
        }

        repository.add(newUser);
        return Response(200, body: jsonEncode(newUser.toJson()), headers: {'Content-Type': 'application/json'});
      } catch (e) {
        return Response.internalServerError(body: 'Failed to register user');
      }
    });

        // Route: Update User Email
    router.put('/', (Request request) async {
      try {
        final payload = await request.readAsString();
        final data = jsonDecode(payload);

        final currentEmail = data['email'] as String?;
        final newEmail = data['newEmail'] as String?;

        if (currentEmail == null || newEmail == null) {
          return Response(400, body: 'Both currentEmail and newEmail are required');
        }

        final user = repository.getByEmail(currentEmail);
        if (user == null) {
          return Response(404, body: 'User not found');
        }

        user.email = newEmail;
        repository.update(user);

        return Response.ok(jsonEncode(user.toJson()), headers: {'Content-Type': 'application/json'});
      } catch (e) {
        return Response.internalServerError(body: 'Failed to update email');
      }
    });

    // Route: Login
    router.post('/login', (Request request) async {
      try {
        final payload = await request.readAsString();
        final data = jsonDecode(payload);

        final email = data['email'] as String?;
        final password = data['password'] as String?;

        if (email == null || password == null) {
          return Response(400, body: 'Email and password are required');
        }

        final user = repository.getByEmail(email);
        if (user == null || user.password != password) {
          return Response(401, body: 'Invalid email or password');
        }

        return Response.ok(jsonEncode(user.toJson()), headers: {'Content-Type': 'application/json'});
      } catch (e) {
        return Response.internalServerError(body: 'Failed to login');
      }
    });

    return router;
  }
}