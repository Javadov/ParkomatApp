// import 'package:flutter/material.dart';
// import 'package:parking_shared/models/vehicle.dart';
// import 'package:parking_shared/services/vehicle_service.dart';

// class VehicleListView extends StatefulWidget {
//   final int ownerId; // Pass ownerId as a parameter

//   const VehicleListView({Key? key, required this.ownerId}) : super(key: key);

//   @override
//   State<VehicleListView> createState() => _VehicleListViewState();
// }

// class _VehicleListViewState extends State<VehicleListView> {
//   final _vehicleService = VehicleService();

//   late Future<List<Vehicle>> _vehicles;

//   @override
//   void initState() {
//     super.initState();
//     // Use the ownerId passed to the widget
//     _vehicles = _vehicleService.fetchVehicles(ownerId: widget.ownerId);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('My Vehicles')),
//       body: FutureBuilder<List<Vehicle>>(
//         future: _vehicles,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           } else if (snapshot.hasError) {
//             return const Center(child: Text('Failed to load vehicles'));
//           } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             return const Center(child: Text('No vehicles found'));
//           } else {
//             return ListView.builder(
//               itemCount: snapshot.data!.length,
//               itemBuilder: (context, index) {
//                 final vehicle = snapshot.data![index];
//                 return ListTile(
//                   title: Text(vehicle.registrationNumber),
//                   subtitle: Text(vehicle.type),
//                 );
//               },
//             );
//           }
//         },
//       ),
//     );
//   }
// }