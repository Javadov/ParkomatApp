import 'package:flutter/material.dart';
import 'package:parking_admin/utilities/license_plate.dart';
import 'package:parking_shared/models/parking.dart';
import 'package:parking_admin/services/parking_service.dart';

class ParkingsView extends StatefulWidget {
  const ParkingsView({Key? key}) : super(key: key);

  @override
  State<ParkingsView> createState() => _ParkingsViewState();
}

class _ParkingsViewState extends State<ParkingsView> {
  final ParkingService _parkingService = ParkingService();
  late Future<List<Parking>> _allParkingsFuture;
  late List<Parking> _activeParkings = [];
  late List<Parking> _historicalParkings = [];
  late List<Parking> _filteredParkings = [];
  final TextEditingController _searchController = TextEditingController();
  String _selectedSort = 'By ID';
  final List<String> _sortOptions = ['By ID', 'By Vehicle', 'By Start Date', 'By End Date'];
  bool _showHistory = false;

  @override
  void initState() {
    super.initState();
    _loadAllParkings();
  }

  Future<void> _loadAllParkings() async {
    try {
      final parkings = await _parkingService.getAllParkings();
      setState(() {
        _activeParkings = parkings.where((p) => p.endTime == null || p.endTime!.isAfter(DateTime.now())).toList();
        _historicalParkings = parkings.where((p) => p.endTime != null && p.endTime!.isBefore(DateTime.now())).toList();
        _filteredParkings = _historicalParkings;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load parkings: $e')),
      );
    }
  }

  void _applySort(String sortOption) {
    setState(() {
      _selectedSort = sortOption;
      switch (sortOption) {
        case 'By ID':
          _filteredParkings.sort((a, b) => a.parkingSpaceId.compareTo(b.parkingSpaceId));
          break;
        case 'By Vehicle':
          _filteredParkings.sort((a, b) => (a.vehicleRegistrationNumber ?? '').compareTo(b.vehicleRegistrationNumber ?? ''));
          break;
        case 'By Start Date':
          _filteredParkings.sort((a, b) => a.startTime.compareTo(b.startTime));
          break;
        case 'By End Date':
          _filteredParkings.sort((a, b) {
            if (a.endTime == null && b.endTime == null) return 0;
            if (a.endTime == null) return 1;
            if (b.endTime == null) return -1;
            return b.endTime!.compareTo(a.endTime!);
          });
          break;
      }
    });
  }

  void _filterParkings(String query) {
    setState(() {
      _filteredParkings = _historicalParkings.where((parking) {
        final matchesId = parking.parkingSpaceId.toString().contains(query);
        final matchesVehicle = (parking.vehicleRegistrationNumber ?? '').toLowerCase().contains(query.toLowerCase());
        final matchesStartDate = _formatTime(parking.startTime).contains(query);
        final matchesEndDate = _formatTime(parking.endTime).contains(query);
        return matchesId || matchesVehicle || matchesStartDate || matchesEndDate;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Parkeringar'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Aktiva Parkeringar',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _activeParkings.isEmpty
                ? const Text(
                    'Inga aktiva parkeringar just nu.',
                    style: TextStyle(color: Colors.grey),
                  )
                : Column(
                    children: _activeParkings.map((parking) {
                      return _buildParkingCard(context, parking, isActive: true);
                    }).toList(),
                  ),
            const SizedBox(height: 30),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Historik',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: Icon(_showHistory ? Icons.expand_less : Icons.expand_more),
                  onPressed: () {
                    setState(() {
                      _showHistory = !_showHistory;
                    });
                  },
                ),
              ],
            ),
            if (_showHistory)
              Expanded(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.search),
                              hintText: 'Sök historik...',
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            onChanged: _filterParkings,
                          ),
                        ),
                        const SizedBox(width: 10),
                        DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedSort,
                            items: _sortOptions.map((option) {
                              return DropdownMenuItem<String>(
                                value: option,
                                child: Text(option),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) _applySort(value);
                            },
                            icon: const Icon(Icons.sort),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _filteredParkings.length,
                        itemBuilder: (context, index) {
                          final parking = _filteredParkings[index];
                          return _buildParkingCard(context, parking, isActive: false);
                        },
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildParkingCard(BuildContext context, Parking parking, {required bool isActive}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showParkingDetails(context, parking),
        child: ListTile(
          leading: LicensePlate(registrationNumber: parking.vehicleRegistrationNumber),
          title: Text('Plats: ${parking.parkingSpaceId}'),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Starttid: ${_formatTime(parking.startTime)}'),
              if (parking.endTime != null)
                Text('Sluttid: ${_formatTime(parking.endTime)}'),
            ],
          ),
          trailing: isActive
              ? ElevatedButton(
                  onPressed: () => _stopParking(parking),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('Stoppa'),
                )
              : null,
        ),
      ),
    );
  }

  void _showParkingDetails(BuildContext context, Parking parking) {
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
              const Text(
                'Parkering Detaljer',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _detailRow('Plats-ID', parking.parkingSpaceId.toString()),
              _detailRow('Fordon', parking.vehicleRegistrationNumber),
              _detailRow('Starttid', _formatTime(parking.startTime)),
              _detailRow('Sluttid', _formatTime(parking.endTime)),
              _detailRow('Kostnad', '${parking.totalCost.toStringAsFixed(2)} kr'),
            ],
          ),
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }

  Future<void> _stopParking(Parking parking) async {
    final now = DateTime.now();
    final success = await _parkingService.updateParkingEndTime(parking.id, now);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Parkeringen har stoppats.')),
      );
      _loadAllParkings();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Misslyckades med att stoppa parkeringen.')),
      );
    }
  }

  String _formatTime(DateTime? time) {
    if (time == null) return 'Ej tillgänglig';
    return '${time.year}/${time.month.toString().padLeft(2, '0')}/${time.day.toString().padLeft(2, '0')} '
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}