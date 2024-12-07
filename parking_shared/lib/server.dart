import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';

import 'handlers/user_handler.dart';
import 'handlers/vehicle_handler.dart';
import 'handlers/parking_space_handler.dart';
import 'handlers/parking_handler.dart';
import 'repositories/user_repository.dart';
import 'repositories/vehicle_repository.dart';
import 'repositories/parking_space_repository.dart';
import 'repositories/parking_repository.dart';
import 'objectbox.g.dart';

late final Store store;

Response _cors(Response response) {
  return response.change(headers: {
    ...response.headers,
    'Access-Control-Allow-Origin': '*', // Allow all origins
    'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type, Authorization',
  });
}


Future<void> main() async {
  // Open the ObjectBox store
  store = await openStore();

  // Initialize repositories with the appropriate ObjectBox boxes
  final userRepository = UserRepository(store);
  final vehicleRepository = VehicleRepository(store);
  final parkingSpaceRepository = ParkingSpaceRepository(store);
  final parkingRepository = ParkingRepository(store);

  // Setup Shelf router and handlers
  final app = Router()
    ..mount('/users', UserHandler(userRepository).router)
    ..mount('/vehicles', VehicleHandler(vehicleRepository).router)
    ..mount('/parking-spaces', ParkingSpaceHandler(parkingSpaceRepository).router)
    ..mount('/parkings', ParkingHandler(parkingRepository).router);

  // Add middleware and start server
  final handler = const Pipeline()
    .addMiddleware(logRequests())
    .addMiddleware((innerHandler) => (request) async {
          if (request.method == 'OPTIONS') {
            return _cors(Response.ok(''));
          }
          final response = await innerHandler(request);
          return _cors(response);
        })
    .addHandler(app);

  final server = await io.serve(handler, 'localhost', 8080);
  print('Server listening on http://${server.address.host}:${server.port}');
}