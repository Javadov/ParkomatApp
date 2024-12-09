// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:parking_user/services/profile_service.dart';
import 'package:parking_user/utilities/user_session.dart';
import 'package:parking_user/views/login_page.dart';
import 'package:parking_user/views/main_layout.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'edit_profile_view.dart';
import 'manage_vehicles_view.dart';
import 'favorites_view.dart';
import 'settings_view.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({Key? key}) : super(key: key);

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final ProfileService _profileService = ProfileService();
  String _email = 'Not Logged In';
  List<Map<String, dynamic>> _vehicles = [];

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    setState(() {
    });

    final session = UserSession();
    final email = session.email;

    if (email == null) {
      _logout();
      return;
    }
    final vehicles = await _profileService.fetchUserVehicles(email);

    setState(() {
      _email = session.email ?? 'Not Logged In';
      _vehicles = vehicles;
    });
  }

  // Future<void> _loadProfileData() async {
  //   setState(() {});

  //   final session = UserSession();
  //   final userId = session.userId;

  //   if (userId == null) {
  //     _logout();
  //     return;
  //   }

  //   final vehicles = await _profileService.fetchUserVehicles(userId);

  //   setState(() {
  //     _email = session.email ?? 'Not Logged In';
  //     _vehicles = vehicles;
  //   });
  // }

  void _openSubPage(Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    ).then((_) {
      _loadProfileData();
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isLoggedIn', false);
    UserSession().clear();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildNavigationList(context),
        ],
      ),
    );
  }

  Widget _buildNavigationList(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.account_circle),
          title: const Text('Personuppgifter'),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () {
            MainLayout.setActivePage(context, EditProfileView());
          },
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.directions_car),
          title: const Text('Fordon'),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () {
            MainLayout.setActivePage(
              context,
              ManageVehiclesView(
                vehicles: _vehicles,
                onRefreshProfile: () {
                  setState(() {
                    // Refresh the profile view if needed
                    _loadProfileData(); // Ensure _loadProfileData exists in your ProfileView
                  });
                },
              ),
            );
          },
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.favorite),
          title: const Text('Favoriter'),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () {
            MainLayout.setActivePage(context, const FavoritesView());
          },
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.settings),
          title: const Text('Inställningar'),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () {
            MainLayout.setActivePage(context, const SettingsView());
          },
        ),
        const Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: _logout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 254, 129, 120),
                  foregroundColor: const Color.fromARGB(255, 255, 255, 255),
                ),
                child: const Text('Logga ut'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}