// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:parking_shared/models/parking.dart';
import 'package:parking_shared/models/parking_space.dart';
import 'package:parking_user/views/main_layout.dart';
import '../services/parking_service.dart';
import '../utilities/user_session.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late GoogleMapController _mapController;
  final ParkingService _parkingService = ParkingService();
  final Set<Marker> _markers = {};
  final userEmail = UserSession().email;
  LatLng _selectedLocation = const LatLng(0, 0);
  String? _selectedVehicle;
  DateTime? _startTime;
  DateTime? _endTime;
  double _parkingCostPerHour = 10.0;
  double _totalCost = 0.0;
  List<Map<String, dynamic>> _userVehicles = [];
  late Future<List<Parking>> _activeParkingsFuture;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchExpanded = false;


  List<ParkingSpace> _allParkingSpaces = []; // Cache for all parking spaces
  List<ParkingSpace> _filteredParkingSpaces = []; // Filtered parking spaces

  @override
  void initState() {
    super.initState();
    _refreshData();();
     //_addParkingMarkers();
    _fetchAndAddParkingMarkers();
  }

  void _refreshData() {
    setState(() {
      _activeParkingsFuture = _parkingService.getActiveParkings(userEmail: userEmail!);
    });
  }

  Future<void> _fetchAndAddParkingMarkers() async {
    try {
      final parkingSpaces = await _parkingService.getAllParkingSpaces();
      setState(() {
        _allParkingSpaces = parkingSpaces;
        _filteredParkingSpaces = parkingSpaces; // Initially, all spaces are shown
      });
      _updateMarkers();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load parking spaces')),
      );
    }
  }

   void _updateMarkers() {
    _markers.clear();
    for (var parkingSpace in _filteredParkingSpaces) {
      _markers.add(
        Marker(
          markerId: MarkerId(parkingSpace.id.toString()),
          position: LatLng(parkingSpace.latitude, parkingSpace.longitude),
          onTap: () => _showParkingModal(
            parkingSpace.id,
            parkingSpace.pricePerHour,
            '${parkingSpace.address}, ${parkingSpace.zipCode}, ${parkingSpace.city}, ${parkingSpace.country}',
          ),
        ),
      );
    }
    setState(() {});
  }

  Future<void> _addParkingMarkers() async {
    try {
      final parkingSpaces = await _parkingService.getAllParkingSpaces();

      for (var parkingSpace in parkingSpaces) {
        _markers.add(
          Marker(
            markerId: MarkerId(parkingSpace.id.toString()),
            position: LatLng(parkingSpace.latitude, parkingSpace.longitude),
            onTap: () async {
              print('Marker tapped for parking space ID: ${parkingSpace.id}');
              setState(() {
                _selectedLocation = LatLng(parkingSpace.latitude, parkingSpace.longitude);
                _parkingCostPerHour = parkingSpace.pricePerHour;
              });

              if (userEmail != null) {
                try {
                  final vehicles = await _parkingService.getUserVehicles(userEmail!);
                  setState(() {
                    _userVehicles = vehicles;
                  });
                  print('Fetched vehicles: $vehicles');
                } catch (e) {
                  print('Error fetching vehicles: $e');
                }
              } else {
                print('User email is null.');
              }
            },
          ),
        );
      }

      setState(() {}); // Refresh markers
    } catch (e) {
      print('Error in _addParkingMarkers: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load parking spaces')),
      );
    }
  }

  void _searchParkingSpaces(String query) {
    final lowerCaseQuery = query.toLowerCase(); // Convert query to lowercase
    setState(() {
      _filteredParkingSpaces = _allParkingSpaces.where((space) {
        final lowerCaseAddress = space.address.toLowerCase();
        final lowerCaseCity = space.city.toLowerCase();
        final lowerCaseZipCode = space.zipCode.toLowerCase();
        return lowerCaseAddress.contains(lowerCaseQuery) ||
            lowerCaseCity.contains(lowerCaseQuery) ||
            lowerCaseZipCode.contains(lowerCaseQuery) ||
            space.id.toString().contains(query); // Include ID search
      }).toList();
    });
    _updateMarkers(); // Update markers based on filtered results
  }

  void _showParkingModal(int locationId, double price, String address) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(26.0),
          width: double.infinity, // Ensures the modal takes full width
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Parkeringsplats: $locationId',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text('Adress: $address'),
              const SizedBox(height: 10),
              Text('Kostnad: ${price.toStringAsFixed(2)}kr/tim'),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween, // Space between buttons
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _navigateToSelectedLocation();
                      },
                      icon: const Icon(Icons.directions),
                      label: const Text('Navigera'),
                      style: const ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(Colors.blue),
                        foregroundColor: WidgetStatePropertyAll(Colors.white),
                        iconColor: WidgetStatePropertyAll(Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10), // Add space between buttons
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context);

                        if (userEmail != null) {
                          try {
                            final vehicles = await _parkingService.getUserVehicles(userEmail!);
                            setState(() {
                              _userVehicles = vehicles;
                            });
                            print('Fetched vehicles');
                          } catch (e) {
                            print('Error fetching vehicles: $e');
                          }
                        } else {
                          print('User email is null.');
                        }
                        
                        _showParkDialog(locationId);
                      },
                      child: const Text('Parkera här'),
                      style: const ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(Color.fromARGB(255, 252, 75, 72)),
                        foregroundColor: WidgetStatePropertyAll(Colors.white),
                      )
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _navigateToSelectedLocation() {
    // Placeholder for navigation functionality
    print('Navigating to $_selectedLocation...');
  }

  void _showParkDialog(int locationId) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            title: const Text(
              'Parkera',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
              textAlign: TextAlign.center,
            ),
            content: SizedBox(
              height: 270,
              width: 260,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Select Vehicle Dropdown
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Välj fordon',
                      labelStyle: const TextStyle(fontSize: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    items: _userVehicles.map((vehicle) {
                      final registrationNumber = vehicle['registrationNumber'] as String;
                      return DropdownMenuItem<String>(
                        value: registrationNumber,
                        child: Text(registrationNumber),
                      );
                    }).toList(),
                    borderRadius: BorderRadius.circular(20),
                    onChanged: (value) {
                      setState(() {
                        _selectedVehicle = value;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  ListTile(
                    leading: const Icon(Icons.timer, color: Colors.blueAccent),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween, // Space between the text and time
                      children: [
                        const Text(
                          'Starttid:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                        ),
                        Text(
                          _startTime != null
                              ? '${_startTime!.hour.toString().padLeft(2, '0')}:${_startTime!.minute.toString().padLeft(2, '0')}     '
                              : 'Nu         ',
                          style: const TextStyle(
                            fontSize: 14,
                            // fontWeight: FontWeight.normal,
                            color: Colors.blueAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.access_time, color: Colors.blueAccent),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween, // Space between "Sluttid" and button
                      children: [
                        const Text(
                          'Sluttid:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () async {
                            final selectedTime = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                            );
                            if (selectedTime != null) {
                              final now = DateTime.now();
                              setState(() {
                                _startTime ??= now;
                                _endTime = DateTime(
                                  now.year,
                                  now.month,
                                  now.day,
                                  selectedTime.hour,
                                  selectedTime.minute,
                                );
                                _totalCost = _calculateParkingCost();
                              });
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Sluttid är obligatoriskt')),
                              );
                            }
                          },
                          child: Text(
                            _endTime != null
                                ? '${_endTime!.hour.toString().padLeft(2, '0')}:${_endTime!.minute.toString().padLeft(2, '0')}'
                                : 'Välj Tid',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Circular Timer and Cost
                  Center(
                    child: Column(
                      children: [
                        Text(
                          _endTime != null
                              ? '${_formatRemainingTime(_endTime!.difference(DateTime.now()))}'
                              : '',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _endTime != null
                              ? 'Total kostnad: ${_totalCost.toStringAsFixed(2)} kr'
                              : '',                        
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Avbryt', style: TextStyle(color: Colors.red)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () async {
                  if (_selectedVehicle != null && _endTime != null) {
                    final success = await _parkingService.startParking(userEmail: userEmail!, registrationNumber: _selectedVehicle!, parkingSpaceId: locationId, startTime: _startTime!, endTime: _endTime!, totalCost: _totalCost);
                    
                    if (success) {
                      Navigator.pop(context);  
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Parkering har påbörjats')),
                      );
                      MainLayout.refreshActiveParkingCount(context);
                      _refreshData();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Kunde inte starta parkeringen')),
                      );
                    }
                  }
                },
                child: const Text('Starta parkering', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        });
      },
    );
  }

  double _calculateParkingCost() {
    if (_startTime == null || _endTime == null) return 0.0;

    final duration = _endTime!.difference(_startTime!);

    // Calculate the total cost based on the duration in minutes
    final totalMinutes = duration.inMinutes;
    return (totalMinutes / 60) * _parkingCostPerHour;
  }

  String _formatRemainingTime(Duration duration) {
    final totalMinutes = duration.inMinutes;
    if (totalMinutes < 60) {
      // Less than 1 hour, show only minutes
      return '$totalMinutes min';
    } else {
      // 1 hour or more, show hours and minutes
      final hours = totalMinutes ~/ 60; // Integer division
      final minutes = totalMinutes % 60; // Remainder
      return '$hours ${hours > 1 ? 'timmar' : 'timme'} ${minutes > 0 ? '$minutes min' : ''}'.trim();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (controller) => _mapController = controller,
            initialCameraPosition: const CameraPosition(
              target: LatLng(59.272376, 15.219534),
              zoom: 14,
            ),
            markers: _markers,
          ),
          Positioned(
            bottom: 9,
            left: 10,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: _isSearchExpanded ? MediaQuery.of(context).size.width - 20 : 56,
                  height: 56,
                  padding: _isSearchExpanded ? const EdgeInsets.symmetric(horizontal: 10) : null,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromARGB(94, 0, 0, 0),
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      if (_isSearchExpanded)
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            decoration: const InputDecoration(
                              hintText: '  Sök på ID, adress, stad...',
                              border: InputBorder.none,
                            ),
                            onChanged: _searchParkingSpaces, // Trigger search on every input change
                          ),
                        ),
                      IconButton(
                        icon: Icon(
                          _isSearchExpanded ? Icons.close : Icons.search,
                        ),
                        onPressed: () {
                          setState(() {
                            _isSearchExpanded = !_isSearchExpanded;
                            if (!_isSearchExpanded) {
                              _searchController.clear();
                              _filteredParkingSpaces = _allParkingSpaces; // Reset filtered list
                              _updateMarkers(); // Reset markers
                            }
                          });
                        },
                        constraints: const BoxConstraints(
                          minWidth: 56,
                          minHeight: 56,
                        ), //
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}