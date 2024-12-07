import 'package:flutter/material.dart';
import 'package:parking_shared/models/parking.dart';
import 'package:parking_user/services/parking_service.dart';
import 'package:parking_user/utilities/user_session.dart';
import 'package:parking_user/views/main_layout.dart';
import 'package:parking_user/views/parking_history_view.dart';

class MyParkingsView extends StatefulWidget {
  const MyParkingsView({Key? key}) : super(key: key);

  @override
  State<MyParkingsView> createState() => _MyParkingsViewState();
}

class _MyParkingsViewState extends State<MyParkingsView> {
  final ParkingService _parkingService = ParkingService();
  late Future<List<Parking>> _activeParkingsFuture;
  final userEmail = UserSession().email;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    setState(() {
      _activeParkingsFuture = _parkingService.getActiveParkings(userEmail: userEmail!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Active Parkings Section
            const Text(
              'Aktiva Parkeringar',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                // color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            FutureBuilder<List<Parking>>(
              future: _activeParkingsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Fel vid hämtning: ${snapshot.error}'),
                  );
                } else if (snapshot.data == null || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      'Inga aktiva parkeringar just nu.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return Column(
                  children: snapshot.data!.map((parking) {
                    final remainingDuration = parking.endTime!.difference(DateTime.now());
                    final remainingHours = remainingDuration.inHours;
                    final remainingMinutes = remainingDuration.inMinutes % 60;

                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.local_parking, color: Colors.blueAccent),
                            title: Text(
                              'Plats: ${parking.parkingSpaceId}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Fordon: ${parking.vehicleRegistrationNumber}'),
                                Text('Kostnad: ${parking.totalCost.toStringAsFixed(2)} kr'),
                                Text('Slutar: ${_formatTime(parking.endTime)}'),
                                Text(
                                  remainingDuration.isNegative
                                      ? 'Parkeringen har gått ut'
                                      : 'Tid kvar: ${remainingHours > 0 ? '$remainingHours timmar ' : ''}${remainingMinutes} minuter',
                                  style: TextStyle(
                                    color: remainingDuration.isNegative ? Colors.red : Colors.blueAccent,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ButtonBar(
                            alignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () => _extendParking(parking),
                                icon: const Icon(Icons.timer),
                                label: const Text('Förläng'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                              ElevatedButton.icon(
                                onPressed: () => _stopParking(parking),
                                icon: const Icon(Icons.stop),
                                label: const Text('Stoppa'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 30),

            // History Section
            const Text(
              'Historik',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                // color: Colors.black87,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.history, color: Colors.blueAccent),
              title: const Text('Visa Parkeringshistorik'),
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: () {
                final userEmail = UserSession().email;
                if (userEmail != null) {
                  final parkingHistoryFuture = ParkingService().getParkingHistory(userEmail: userEmail);

                  MainLayout.setActivePage(
                    context,
                    ParkingHistoryView(parkingHistoryFuture: parkingHistoryFuture),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required Future<List<Parking>> future,
    required String emptyMessage,
    Function(Parking)? onExtend,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        FutureBuilder<List<Parking>>(
          future: future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Text('Fel inträffade: ${snapshot.error}');
            } else if (snapshot.hasData) {
              final parkings = snapshot.data!;
              if (parkings.isEmpty) {
                return Text(emptyMessage);
              }

              return Column(
                children: parkings
                    .map((parking) => _buildParkingTile(parking, onExtend))
                    .toList(),
              );
            } else {
              return Text(emptyMessage);
            }
          },
        ),
      ],
    );
  }

  Widget _buildParkingTile(Parking parking, Function(Parking)? onExtend) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 4,
      child: ListTile(
        title: Text('Fordon: ${parking.vehicleRegistrationNumber}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Starttid: ${parking.startTime}'),
            Text('Sluttid: ${parking.endTime ?? 'Inte avslutad'}'),
            Text('Kostnad: ${parking.totalCost.toStringAsFixed(2)} kr'),
          ],
        ),
        trailing: onExtend != null
            ? ElevatedButton(
                onPressed: () => onExtend(parking),
                child: const Text('Förläng'),
              )
            : null,
      ),
    );
  }

  String _formatTime(DateTime? time) {
    if (time == null) return 'Okänt';
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _extendParking(Parking parking) async {
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(parking.endTime!),
    );

    if (selectedTime != null) {
      final newEndTime = DateTime(
        parking.endTime!.year,
        parking.endTime!.month,
        parking.endTime!.day,
        selectedTime.hour,
        selectedTime.minute,
      );

      final success = await _parkingService.updateParkingEndTime(parking.id, newEndTime);

      if (success) {
        setState(() {
          parking.endTime = newEndTime;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Parkeringen har förlängts.')),
        );

        _refreshData(); // Refresh data after extending parking
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Misslyckades med att förlänga parkeringen.')),
        );
      }
    }
  }

  Future<void> _stopParking(Parking parking) async {
    final now = DateTime.now();
    final success = await _parkingService.updateParkingEndTime(parking.id, now);

    if (success) {
      setState(() {
        parking.endTime = now;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Parkeringen har stoppats.')),
      );

       MainLayout.refreshActiveParkingCount(context);
      _refreshData();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Misslyckades med att stoppa parkeringen.')),
      );
    }
  }
}