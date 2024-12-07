import 'package:flutter/material.dart';
import 'package:parking_user/services/profile_service.dart';
import 'package:parking_user/utilities/user_session.dart';

class EditProfileView extends StatefulWidget {
  const EditProfileView({Key? key}) : super(key: key);

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  final ProfileService _profileService = ProfileService();
  final TextEditingController _emailController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Load the current email from UserSession
    _emailController.text = UserSession().email ?? '';
  }

  Future<void> _saveEmail() async {
    final newEmail = _emailController.text.trim();
    final currentEmail = UserSession().email;

    if (newEmail.isEmpty || newEmail == currentEmail) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inga ändringar att spara.')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final success = await _profileService.updateUserEmail(currentEmail!, newEmail);
    if (success) {
      // Update the session email
      UserSession().email = newEmail;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('E-posten har uppdaterats.')),
      );
      Navigator.pop(context); // Go back to the profile view
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Det gick inte att uppdatera e-posten.')),
      );
    }

    setState(() {
      _isSaving = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Personuppgifter'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'E-post'),
            ),
            const SizedBox(height: 20),
            if (_isSaving)
              const CircularProgressIndicator()
            else
              ElevatedButton(
                onPressed: _saveEmail,
                child: const Text('Spara'),
              ),
          ],
        ),
      ),
    );
  }
}