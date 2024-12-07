import 'package:flutter/material.dart';

class FavoritesView extends StatelessWidget {
  const FavoritesView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favoriter'),
        // backgroundColor: const Color.fromARGB(255, 167, 196, 210),
        // foregroundColor: const Color.fromARGB(255, 255, 255, 255),
        // titleTextStyle: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
      body: const Center(
        child: Text('Favoriter kommer snart!'),
      ),
    );
  }
}
