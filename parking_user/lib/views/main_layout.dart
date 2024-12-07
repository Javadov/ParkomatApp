import 'package:flutter/material.dart';
import 'home_view.dart';
import 'my_parkings_view.dart';
import 'profile_view.dart';
import '../services/parking_service.dart';
import '../utilities/user_session.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({Key? key}) : super(key: key);

  // Add this method to set an active page dynamically
  static void setActivePage(BuildContext context, Widget page) {
    final state = context.findAncestorStateOfType<_MainLayoutState>();
    state?._setActivePage(page);
  }

  static void refreshActiveParkingCount(BuildContext context) {
    final state = context.findAncestorStateOfType<_MainLayoutState>();
    state?._loadActiveParkingCount();
  }

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;
  int _activeParkingCount = 0;

  late Widget _activePage;

  final List<Widget> _defaultPages = [
    const HomeView(),         // Parkering
    const MyParkingsView(),   // Mina Parkeringar
    const ProfileView(),      // Mitt Konto
  ];

  @override
  void initState() {
    super.initState();
    _activePage = _defaultPages[_currentIndex];
    _loadActiveParkingCount();
  }

  Future<void> _loadActiveParkingCount() async {
    final userEmail = UserSession().email;
    if (userEmail != null) {
      final activeParkings = await ParkingService().getActiveParkings(userEmail: userEmail);
      setState(() {
        _activeParkingCount = activeParkings.length;
      });
    }
  }

  void _setActivePage(Widget page) {
    setState(() {
      _activePage = page;
    });
  }

  void _resetToDefaultPage() {
    setState(() {
      _activePage = _defaultPages[_currentIndex];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PARKOMAT'),
        titleTextStyle: const TextStyle(
          color: Colors.blueGrey,
          fontSize: 24,
          fontWeight: FontWeight.w900,
          fontFamily: 'Roboto',
        ),
        leading: _activePage != _defaultPages[_currentIndex]
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _resetToDefaultPage,
              )
            : null,
      ),
      body: _activePage,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            _activePage = _defaultPages[index];
          });
          _loadActiveParkingCount();
        },
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.local_parking),
            label: 'Parkering',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.access_time),
                if (_activeParkingCount > 0)
                  Positioned(
                    top: -5,
                    right: -5,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$_activeParkingCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            label: 'Mina Parkeringar',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Mitt Konto',
          ),
        ],
        selectedItemColor: Colors.red,
      ),
    );
  }
}