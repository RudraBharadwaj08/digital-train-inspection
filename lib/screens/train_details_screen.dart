import 'package:flutter/material.dart';
import 'scorecard_form.dart';

class TrainDetailsScreen extends StatefulWidget {
  final String username;

  const TrainDetailsScreen({super.key, required this.username});

  @override
  State<TrainDetailsScreen> createState() => _TrainDetailsScreenState();
}

class _TrainDetailsScreenState extends State<TrainDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _stationController = TextEditingController();
  final _trainController = TextEditingController();

  void _proceed() {
    if (_formKey.currentState!.validate()) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (ctx) => ScorecardFormScreen(
            username: widget.username,
            stationName: _stationController.text.trim(),
            trainNumber: _trainController.text.trim(),
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _stationController.dispose();
    _trainController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.tealAccent, Colors.blueAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
          ),
          child: AppBar(
            title: const Text('Enter Train Details'),
            centerTitle: true,
            backgroundColor: Colors.transparent, // important to make gradient visible
            elevation: 0,
            foregroundColor: Colors.white,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Welcome header
              Text(
                'Welcome, ${widget.username}!',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),

              Text(
                'Please enter the train details below to continue',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Station Name field
              TextFormField(
                controller: _stationController,
                decoration: InputDecoration(
                  labelText: 'Station Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  prefixIcon: const Icon(Icons.location_city),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceVariant,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter station name';
                  }
                  return null;
                },
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 24),

              // Train Number field
              TextFormField(
                controller: _trainController,
                decoration: InputDecoration(
                  labelText: 'Train Number',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  prefixIcon: const Icon(Icons.confirmation_number),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceVariant,
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter train number';
                  }
                  if (!RegExp(r'^\d+$').hasMatch(value.trim())) {
                    return 'Train number must be numeric only';
                  }
                  return null;
                },
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _proceed(),
              ),
              const SizedBox(height: 36),

              // Continue Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.arrow_forward),
                  label: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Text(
                      'Continue',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ),
                  onPressed: _proceed,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                    shadowColor: theme.colorScheme.primary.withOpacity(0.5),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
