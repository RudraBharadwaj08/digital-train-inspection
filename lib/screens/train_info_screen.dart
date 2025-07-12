// train_info_screen.dart
import 'package:flutter/material.dart';
import 'home_screen.dart';

class TrainInfoScreen extends StatefulWidget {
  final String username;
  const TrainInfoScreen({super.key, required this.username});

  @override
  State<TrainInfoScreen> createState() => _TrainInfoScreenState();
}

class _TrainInfoScreenState extends State<TrainInfoScreen> {
  final TextEditingController _stationController = TextEditingController();
  final TextEditingController _trainController = TextEditingController();

  void _proceedToHome() {
    final station = _stationController.text.trim();
    final train = _trainController.text.trim();

    if (station.isEmpty || train.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both station and train number')),
      );
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (ctx) => HomeScreen(
          username: widget.username,
          stationName: station,
          trainNumber: train,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Train Information')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Enter Station and Train Info', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            TextField(
              controller: _stationController,
              decoration: const InputDecoration(
                labelText: 'Station Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _trainController,
              decoration: const InputDecoration(
                labelText: 'Train Number',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Continue'),
              onPressed: _proceedToHome,
            ),
          ],
        ),
      ),
    );
  }
}
