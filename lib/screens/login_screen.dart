import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shopping_list/screens/train_details_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final nameController = TextEditingController();

  void _proceedWithEmail() {
    final name = nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter agent name')),
      );
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => TrainDetailsScreen(username: name),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Colors.tealAccent, Colors.blueAccent],
          ).createShader(const Rect.fromLTWH(0, 0, 200, 70)),
          child: const Text(
            'TrainZY',
            style: TextStyle(
              fontSize: 35,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: Colors.white,
              shadows: [
                Shadow(
                  offset: Offset(1, 1),
                  blurRadius: 2,
                  color: Colors.black54,
                ),
              ],
            ),
          ),

        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/animation/Train.json',
              width: MediaQuery.of(context).size.width,
              height: 200,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 30),

            TextField(
              controller: nameController,
              onChanged: (value) {
                setState(() {}); // To rebuild the widget and show/hide the icon
              },
              decoration: InputDecoration(
                labelText: 'Agent Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.person),
                suffixIcon: nameController.text.trim().isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.arrow_forward_ios),
                  tooltip: 'Continue',
                  onPressed: _proceedWithEmail,
                )
                    : null,
              ),
            ),

            const SizedBox(height: 30),


            const SizedBox(height: 20),

            // Phone login
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.phone),
                label: const Text('Continue with Phone Number'),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Phone login not implemented yet')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Email login
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.email),
                label: const Text('Continue with Email'),
                onPressed: _proceedWithEmail,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Google login
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.g_mobiledata),
                label: const Text('Continue with Google'),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Google login not implemented yet')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }
}
