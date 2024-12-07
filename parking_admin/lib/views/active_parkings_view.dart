import 'package:flutter/material.dart';

class ActiveParkingsView extends StatelessWidget {
  const ActiveParkingsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Active Parkings')),
      body: ListView.builder(
        itemCount: 10, // Replace with actual count
        itemBuilder: (context, index) {
          return ListTile(
            title: Text('Parking $index'),
            subtitle: Text('Vehicle: XYZ | Cost: 50 kr'),
            trailing: IconButton(
              icon: const Icon(Icons.timer, color: Colors.green),
              onPressed: () {
                // Extend parking time
              },
            ),
            onTap: () {
              // Stop parking logic
            },
          );
        },
      ),
    );
  }
}