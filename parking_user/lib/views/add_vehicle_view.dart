// import 'package:flutter/material.dart';
// import 'package:parking_shared/models/vehicle.dart';
// import 'package:parking_shared/services/vehicle_service.dart';

// class AddVehicleView extends StatefulWidget {
//   final int ownerId; // Pass the owner ID when navigating to this view

//   const AddVehicleView({Key? key, required this.ownerId}) : super(key: key);

//   @override
//   State<AddVehicleView> createState() => _AddVehicleViewState();
// }

// class _AddVehicleViewState extends State<AddVehicleView> {
//   final _registrationNumberController = TextEditingController();
//   final _vehicleService = VehicleService();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Add Vehicle')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             TextFormField(
//               controller: _registrationNumberController,
//               decoration: const InputDecoration(labelText: 'Registration Number'),
//               validator: (value) {
//                 if (value == null || value.isEmpty) {
//                   return 'Please enter a registration number';
//                 }
//                 return null;
//               },
//             ),
//             const SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: () async {
//                 if (_registrationNumberController.text.isEmpty) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(content: Text('Please fill out all fields')),
//                   );
//                   return;
//                 }

//                 // Create a new Vehicle object with a placeholder ID
//                 final vehicle = Vehicle(
//                   // id: 0, 
//                   registrationNumber: _registrationNumberController.text,
//                   type: 'Car', // Replace with actual type selection if needed
//                   ownerId: widget.ownerId, // Use the owner ID passed to the widget
//                 );

//                 try {
//                   await _vehicleService.addVehicle(vehicle);
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(content: Text('Vehicle added successfully')),
//                   );
//                   Navigator.pop(context);
//                 } catch (e) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(content: Text('Failed to add vehicle')),
//                   );
//                 }
//               },
//               child: const Text('Add Vehicle'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }