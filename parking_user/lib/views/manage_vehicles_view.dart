import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:parking_user/services/profile_service.dart';
import 'package:parking_user/utilities/user_session.dart';

class ManageVehiclesView extends StatefulWidget {
  final List<Map<String, dynamic>> vehicles;
  final VoidCallback onRefreshProfile; 

   const ManageVehiclesView({
      Key? key,
      required this.vehicles,
      required this.onRefreshProfile, // Accept the callback
    }) : super(key: key);

  @override
  State<ManageVehiclesView> createState() => _ManageVehiclesViewState();
}

class _ManageVehiclesViewState extends State<ManageVehiclesView> {
  final ProfileService _profileService = ProfileService();
  late List<Map<String, dynamic>> _vehicles;

  @override
  void initState() {
    super.initState();
    _vehicles = widget.vehicles;
  }

  Future<void> _addVehicleDialog() async {
    final registrationController = TextEditingController();
    String? selectedType;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Lägg till fordon'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: registrationController,
                decoration: const InputDecoration(labelText: 'Registreringsnummer'),
              ),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Fordonstyp'),
                items: const [
                  DropdownMenuItem(value: 'Car', child: Text('Bil')),
                  DropdownMenuItem(value: 'Motorcycle', child: Text('Motorcykel')),
                  DropdownMenuItem(value: 'Truck', child: Text('Lastbil')),
                ],
                onChanged: (value) {
                  selectedType = value;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (registrationController.text.isNotEmpty && selectedType != null) {
                  final userEmail = UserSession().email;

                  if (userEmail != null) {
                    final success = await _profileService.addVehicle(
                      userEmail,
                      registrationController.text,
                      selectedType!,
                    );

                    if (success) {
                      Navigator.pop(context);
                      widget.onRefreshProfile();
  
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Fordonet har lagts till')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Det gick inte att lägga till fordon')),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Användaren är inte inloggad')),
                    );
                  }
                  Navigator.pop(context);
                }
              },
              child: const Text('Lägg till'),
            ),
          ],
        );
      },
    );
  }
  
 void _editVehicleDialog(Map<String, dynamic> vehicle) {
  final registrationController = TextEditingController(text: vehicle['registrationNumber']);
  String? selectedType = vehicle['type'];

  // Ensure vehicle ID is an int
  final vehicleId = vehicle['id'] is String ? int.tryParse(vehicle['id']) : vehicle['id'];

  if (vehicleId == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ogiltigt fordons-ID')),
    );
    return;
  }

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Redigera fordon'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: registrationController,
              decoration: const InputDecoration(labelText: 'Registreringsnummer'),
            ),
            DropdownButtonFormField<String>(
              value: selectedType,
              decoration: const InputDecoration(labelText: 'Fordonstyp'),
              items: const [
                DropdownMenuItem(value: 'Car', child: Text('Bil')),
                DropdownMenuItem(value: 'Motorcycle', child: Text('Motorcykel')),
                DropdownMenuItem(value: 'Truck', child: Text('Lastbil')),
              ],
              onChanged: (value) {
                selectedType = value;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Avbryt'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (registrationController.text.isNotEmpty && selectedType != null) {
                final updatedVehicle = {
                  'id': vehicleId,
                  'userEmail': UserSession().email,
                  'registrationNumber': registrationController.text,
                  'type': selectedType,
                };

                final success = await _profileService.updateVehicle(vehicleId, updatedVehicle);

                if (success) {
                  setState(() {
                    final index = _vehicles.indexWhere((v) => v['id'] == vehicleId);
                    if (index != -1) {
                      _vehicles[index] = updatedVehicle;
                    }
                  });

                  // widget.onRefreshProfile();
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Det gick inte att uppdatera fordonet')),
                  );
                }
              }
            },
            child: const Text('Spara'),
          ),
        ],
      );
    },
  );
}

  Future<void> _deleteVehicle(String registrationNumber) async {
    final success = await _profileService.deleteVehicle(registrationNumber);

    if (success) {
      setState(() {
        _vehicles.removeWhere((vehicle) => vehicle['registrationNumber'] == registrationNumber);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Det gick inte att radera fordonet.')),
      );
    }
  }
  

  Widget _buildVehicleTile(Map<String, dynamic> vehicle) {
  return Card(
    elevation: 2,
    margin: const EdgeInsets.symmetric(vertical: 8),
    child: ListTile(
      title: Text(vehicle['registrationNumber']),
      subtitle: Text('Type: ${vehicle['type']}'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue),
            onPressed: () => _editVehicleDialog(vehicle),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _deleteVehicle(vehicle['registrationNumber']),
          ),
        ],
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fordon'),
        // backgroundColor: const Color.fromARGB(255, 167, 196, 210),
        // foregroundColor: const Color.fromARGB(255, 255, 255, 255),
        // titleTextStyle: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          ElevatedButton(
            onPressed: _addVehicleDialog,
            child: const Text('Lägg till fordon'),
            style: const ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(Color.fromARGB(255, 255, 124, 124)),
              foregroundColor: WidgetStatePropertyAll(Colors.white),
              iconColor: WidgetStatePropertyAll(Colors.white),
            ),
          ),
          const SizedBox(height: 10),
          ..._vehicles.map((vehicle) => _buildVehicleTile(vehicle)).toList(),
        ],
      ),
    );
  }
}
