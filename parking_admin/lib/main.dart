import 'package:flutter/material.dart';
import 'package:parking_admin/views/active_parkings_view.dart';
import 'package:parking_admin/views/dashboard_view.dart';
import 'package:parking_admin/views/parking_spaces_view.dart';

void main() {
  runApp(const ParkingAdminApp());
}

class ParkingAdminApp extends StatelessWidget {
  const ParkingAdminApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Parking Admin',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: const MainLayout(),
    );
  }
}

class MainLayout extends StatefulWidget {
  const MainLayout({Key? key}) : super(key: key);

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  final List<Widget> _views = [
    const DashboardView(),
    const ParkingSpacesView(),
    const ActiveParkingsView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            labelType: NavigationRailLabelType.selected,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard),
                label: Text('Dashboard'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.local_parking),
                label: Text('Parking Spaces'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.monitor),
                label: Text('Active Parkings'),
              ),
            ],
          ),
          Expanded(
            child: _views[_selectedIndex],
          ),
        ],
      ),
    );
  }
}