import 'package:flutter/material.dart';
import 'package:parking_admin/services/parkin_space_service.dart';
import 'package:parking_shared/models/parking_space.dart';

class ParkingSpacesView extends StatefulWidget {
  const ParkingSpacesView({Key? key}) : super(key: key);

  @override
  State<ParkingSpacesView> createState() => _ParkingSpacesViewState();
}

class _ParkingSpacesViewState extends State<ParkingSpacesView> {
  final ParkingSpaceService _service = ParkingSpaceService();
  late Future<List<ParkingSpace>> _parkingSpacesFuture;

  @override
  void initState() {
    super.initState();
    _refreshParkingSpaces();
  }

  void _refreshParkingSpaces() {
    setState(() {
      _parkingSpacesFuture = _service.getAllParkingSpaces();
    });
  }

  void _showParkingSpaceDetails(ParkingSpace parkingSpace) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                parkingSpace.address,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text('City: ${parkingSpace.city}'),
              Text('Zip Code: ${parkingSpace.zipCode}'),
              Text('Country: ${parkingSpace.country}'),
              Text('Position: (${parkingSpace.latitude}, ${parkingSpace.longitude})'),
              Text('Price: ${parkingSpace.pricePerHour.toStringAsFixed(2)} kr/h'),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => _showEditParkingSpaceDialog(parkingSpace),
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    label: const Text('Edit'),
                  ),
                  TextButton.icon(
                    onPressed: () async {
                      final success = await _service.deleteParkingSpace(parkingSpace.id);
                      if (success) {
                        Navigator.pop(context);
                        _refreshParkingSpaces();
                      }
                    },
                    icon: const Icon(Icons.delete, color: Colors.red),
                    label: const Text('Delete'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddParkingSpaceDialog([ParkingSpace? parkingSpace]) {
    final addressController = TextEditingController(text: parkingSpace?.address);
    final cityController = TextEditingController(text: parkingSpace?.city);
    final zipCodeController = TextEditingController(text: parkingSpace?.zipCode);
    final countryController = TextEditingController(text: parkingSpace?.country);
    final latitudeController = TextEditingController(
        text: parkingSpace != null ? parkingSpace.latitude.toString() : '');
    final longitudeController = TextEditingController(
        text: parkingSpace != null ? parkingSpace.longitude.toString() : '');
    final priceController = TextEditingController(
        text: parkingSpace != null ? parkingSpace.pricePerHour.toString() : '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(parkingSpace == null ? 'Add Parking Space' : 'Edit Parking Space'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(controller: addressController, decoration: const InputDecoration(labelText: 'Address')),
                TextField(controller: cityController, decoration: const InputDecoration(labelText: 'City')),
                TextField(controller: zipCodeController, decoration: const InputDecoration(labelText: 'Zip Code')),
                TextField(controller: countryController, decoration: const InputDecoration(labelText: 'Country')),
                TextField(controller: latitudeController, decoration: const InputDecoration(labelText: 'Latitude')),
                TextField(controller: longitudeController, decoration: const InputDecoration(labelText: 'Longitude')),
                TextField(
                  controller: priceController,
                  decoration: const InputDecoration(labelText: 'Price Per Hour'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final updatedParkingSpace = ParkingSpace(
                  id: parkingSpace?.id ?? 0,
                  address: addressController.text,
                  city: cityController.text,
                  zipCode: zipCodeController.text,
                  country: countryController.text,
                  latitude: double.tryParse(latitudeController.text) ?? 0,
                  longitude: double.tryParse(longitudeController.text) ?? 0,
                  pricePerHour: double.tryParse(priceController.text) ?? 0,
                );

                final success = parkingSpace == null
                    ? await _service.addParkingSpace(updatedParkingSpace)
                    : await _service.updateParkingSpace(updatedParkingSpace);

                if (success) {
                  Navigator.pop(context);
                  _refreshParkingSpaces();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to save parking space')),
                  );
                }
              },
              child: Text(parkingSpace == null ? 'Add' : 'Save'),
            ),
          ],
        );
      },
    );
  }

  void _showEditParkingSpaceDialog(ParkingSpace parkingSpace) {
    final addressController = TextEditingController(text: parkingSpace.address);
    final cityController = TextEditingController(text: parkingSpace.city);
    final zipCodeController = TextEditingController(text: parkingSpace.zipCode);
    final countryController = TextEditingController(text: parkingSpace.country);
    final latitudeController = TextEditingController(text: parkingSpace.latitude.toString());
    final longitudeController = TextEditingController(text: parkingSpace.longitude.toString());
    final priceController = TextEditingController(text: parkingSpace.pricePerHour.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Parking Space'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(controller: addressController, decoration: const InputDecoration(labelText: 'Address')),
                TextField(controller: cityController, decoration: const InputDecoration(labelText: 'City')),
                TextField(controller: zipCodeController, decoration: const InputDecoration(labelText: 'Zip Code')),
                TextField(controller: countryController, decoration: const InputDecoration(labelText: 'Country')),
                TextField(controller: latitudeController, decoration: const InputDecoration(labelText: 'Latitude')),
                TextField(controller: longitudeController, decoration: const InputDecoration(labelText: 'Longitude')),
                TextField(
                  controller: priceController,
                  decoration: const InputDecoration(labelText: 'Price Per Hour'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final updatedParkingSpace = ParkingSpace(
                  id: parkingSpace.id,
                  address: addressController.text,
                  city: cityController.text,
                  zipCode: zipCodeController.text,
                  country: countryController.text,
                  latitude: double.tryParse(latitudeController.text) ?? 0,
                  longitude: double.tryParse(longitudeController.text) ?? 0,
                  pricePerHour: double.tryParse(priceController.text) ?? 0,
                );

                final success = await _service.updateParkingSpace(updatedParkingSpace);

                if (success) {
                  Navigator.pop(context);
                  _refreshParkingSpaces();
                  _handleDialogClose(context, 'Parking Space updated successfully');
                  // ScaffoldMessenger.of(context).showSnackBar(
                  //   const SnackBar(content: Text('Parking Space updated successfully')),
                  // );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to update parking space')),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _handleDialogClose(BuildContext context, String message) {
    Navigator.pop(context); // Close the dialog
    _refreshParkingSpaces(); // Refresh the list
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Parking Spaces'),
        backgroundColor: Colors.blueAccent,
      ),
      body: FutureBuilder<List<ParkingSpace>>(
        future: _parkingSpacesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.data == null || snapshot.data!.isEmpty) {
            return const Center(child: Text('No parking spaces available.'));
          }

          final parkingSpaces = snapshot.data!;
          return ListView.builder(
            itemCount: parkingSpaces.length,
            itemBuilder: (context, index) {
              final parkingSpace = parkingSpaces[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  title: Text(parkingSpace.address),
                  subtitle: Text('Price: ${parkingSpace.pricePerHour.toStringAsFixed(2)} kr/h'),
                  onTap: () => _showParkingSpaceDetails(parkingSpace),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddParkingSpaceDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}