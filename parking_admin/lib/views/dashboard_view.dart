import 'package:flutter/material.dart';
import 'package:parking_shared/models/parking.dart';
import 'package:parking_admin/services/parking_service.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({Key? key}) : super(key: key);

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  final ParkingService _parkingService = ParkingService();
  int _activeParkingCount = 0;
  double _totalIncome = 0.0;
  List<MapEntry<int, int>> _popularParkingSpaces = [];
  int _totalParkingSpaces = 0;

  @override
  void initState() {
    super.initState();
    _calculateStatistics();
  }

  Future<void> _calculateStatistics() async {
    try {
      final allParkings = await _parkingService.getAllParkings();

      // Count active parkings
      final activeParkings = allParkings
          .where((p) => p.endTime == null || p.endTime!.isAfter(DateTime.now()))
          .toList();
      _activeParkingCount = activeParkings.length;

      // Calculate total income
      _totalIncome = allParkings.fold(0.0, (sum, p) => sum + (p.totalCost ?? 0.0));

      // Group by parking space ID
      final parkingSpacesMap = <int, int>{};
      for (var parking in allParkings) {
        parkingSpacesMap[parking.parkingSpaceId] =
            (parkingSpacesMap[parking.parkingSpaceId] ?? 0) + 1;
      }

      // Sort by popularity
      final sortedParkingSpaces = parkingSpacesMap.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      _popularParkingSpaces = sortedParkingSpaces;

      // Total unique parking spaces
      _totalParkingSpaces = parkingSpacesMap.keys.length;

      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to calculate statistics: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Grundläggande Statistik',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Statistics Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                DashboardCard(
                  title: 'Aktiva Parkeringar',
                  value: '$_activeParkingCount',
                  icon: Icons.local_parking,
                  color: Colors.blueAccent,
                ),
                DashboardCard(
                  title: 'Parkeringsplatser',
                  value: '$_totalParkingSpaces',
                  icon: Icons.location_on,
                  color: Colors.orange,
                ),
                DashboardCard(
                  title: 'Total Inkomst',
                  value: '${_totalIncome.toStringAsFixed(2)} kr',
                  icon: Icons.attach_money,
                  color: Colors.green,
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Popular Parking Spaces Section
            const Text(
              'Populäraste Parkeringsplatserna',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _popularParkingSpaces.isEmpty
                      ? const Center(
                          child: Text(
                            'Inga data tillgängliga.',
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _popularParkingSpaces.length,
                          itemBuilder: (context, index) {
                            final entry = _popularParkingSpaces[index];
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.blueAccent,
                                child: Text('${index + 1}'),
                              ),
                              title: Text('Plats-ID: ${entry.key}'),
                              subtitle: Text('Antal bokningar: ${entry.value}'),
                            );
                          },
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const DashboardCard({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SizedBox(
        width: 160,
        height: 120,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: color),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );
  }
}