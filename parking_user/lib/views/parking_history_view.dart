import 'package:flutter/material.dart';
import 'package:parking_shared/models/parking.dart';
import 'package:parking_user/utilities/license_plate.dart';

class ParkingHistoryView extends StatefulWidget {
  final Future<List<Parking>> parkingHistoryFuture;

  const ParkingHistoryView({Key? key, required this.parkingHistoryFuture}) : super(key: key);

  @override
  State<ParkingHistoryView> createState() => _ParkingHistoryViewState();
}

class _ParkingHistoryViewState extends State<ParkingHistoryView> {
  late List<Parking> _allParkingHistory = [];
  late List<Parking> _sortedParkingHistory = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchExpanded = false;
  bool _isSortByExpanded = false;

  String _selectedSort = 'Auto';
  final List<String> _sortOptions = [
    'Auto',
    'Startdatum',
    'Plats ID',
    'Regnummer',
  ];

  @override
  void initState() {
    super.initState();
    _loadParkingHistory();
  }

  Future<void> _loadParkingHistory() async {
    try {
      final parkingHistory = await widget.parkingHistoryFuture;
      setState(() {
        _allParkingHistory = parkingHistory;
        _sortedParkingHistory = parkingHistory;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load parking history')),
      );
    }
  }

  void _sortParkingHistory(String query) {
    setState(() {
      _sortedParkingHistory = _allParkingHistory.where((parking) {
        final idMatch = parking.parkingSpaceId.toString().contains(query);
        final vehicleMatch = parking.vehicleRegistrationNumber.toLowerCase().contains(query.toLowerCase());
        final dateMatch = parking.startTime.toString().contains(query);
        return idMatch || vehicleMatch || dateMatch;
      }).toList();
    });
  }

  void _applySort(String sortOption) {
    setState(() {
      _selectedSort = sortOption;
      switch (sortOption) {
        case 'Startdatum':
          _sortedParkingHistory.sort((a, b) => a.startTime.compareTo(b.startTime));
          break;
        case 'Plats ID':
          _sortedParkingHistory.sort((a, b) => a.parkingSpaceId.compareTo(b.parkingSpaceId));
          break;
        case 'Regnummer':
          _sortedParkingHistory.sort((a, b) => a.vehicleRegistrationNumber.compareTo(b.vehicleRegistrationNumber));
          break;
        default:
          _sortedParkingHistory = _allParkingHistory;
      }
    });
  }

  void _toggleSearch() {
    setState(() {
      if (_isSortByExpanded) _isSortByExpanded = false;
      _isSearchExpanded = !_isSearchExpanded;
      if (!_isSearchExpanded) {
        _searchController.clear();
        _sortedParkingHistory = _allParkingHistory;
      }
    });
  }

  void _toggleSortBy() {
    setState(() {
      if (_isSearchExpanded) _isSearchExpanded = false;
      _isSortByExpanded = !_isSortByExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Parkeringshistorik'),
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(16.0),
            children: _sortedParkingHistory.map((parking) {
              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: InkWell(
                  onTap: () => _showParkingDetails(parking),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Plats: ${parking.parkingSpaceId}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.blueAccent,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Kostnad: ${parking.totalCost.toStringAsFixed(2)} kr',
                                style: const TextStyle(
                                  fontSize: 14,
                                  // color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Slutade: ${_formatTime(parking.endTime)}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  // color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                        LicensePlate(
                          registrationNumber: parking.vehicleRegistrationNumber,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          Positioned(
            bottom: 9,
            left: 10,
            right: 10,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Search Button
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 56,
                  width: _isSearchExpanded ? MediaQuery.of(context).size.width - 120 : 56,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8,
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
                              hintText: ' Sök på ID, adress, datum...',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 16),
                              
                            ),
                            onChanged: _sortParkingHistory,
                          ),
                        ),
                      IconButton(
                        icon: Icon(
                          _isSearchExpanded ? Icons.close : Icons.search,
                          // color: Colors.blueAccent,
                        ),
                        onPressed: _toggleSearch,
                        constraints: const BoxConstraints(
                          minWidth: 56,
                          minHeight: 56,
                        ),
                      ),
                    ],
                  ),
                ),

                // Sort by Button
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 56,
                  width: _isSortByExpanded ? MediaQuery.of(context).size.width - 120 : 56,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      if (_isSortByExpanded)
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              // Open dropdown when clicking on "Sort By"
                              FocusScope.of(context).requestFocus(FocusNode());
                            },
                            child: Row(
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(left: 20.0),
                                  child: Text(
                                    "Sort By        ",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _selectedSort,
                                    onChanged: (value) {
                                      if (value != null) {
                                        _applySort(value);
                                      }
                                    },
                                    items: _sortOptions.map((String sort) {
                                      return DropdownMenuItem<String>(
                                        value: sort,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 0.1),
                                          child: Text(sort),
                                        ),
                                      );
                                    }).toList(),
                                    dropdownColor: Colors.white,
                                    style: const TextStyle(fontSize: 14, color: Colors.black),
                                    menuMaxHeight: 230,
                                    menuWidth: 130,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      IconButton(
                        icon: Icon(
                          _isSortByExpanded ? Icons.close : Icons.sort,
                        ),
                        onPressed: _toggleSortBy,
                        constraints: const BoxConstraints(
                          minWidth: 56,
                          minHeight: 56,
                        ),
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

  void _showParkingDetails(Parking parking) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(26.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Detaljer för parkering',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Roboto',
                ),
              ),
              const SizedBox(height: 16),
              _detailRow('Plats-ID', parking.parkingSpaceId.toString()),
              _detailRow('Fordon', parking.vehicleRegistrationNumber),
              _detailRow('Starttid', _formatTime(parking.startTime)),
              _detailRow('Sluttid', _formatTime(parking.endTime)),
              _detailRow(
                'Kostnad',
                '${parking.totalCost.toStringAsFixed(2)} kr',
              ),
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
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              // color: Colors.black87,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              // color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime? time) {
    if (time == null) return 'Okänt';
    return '${time.year}/${time.month.toString().padLeft(2, '0')}/${time.day.toString().padLeft(2, '0')} '
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}