import 'package:flutter/material.dart';
import 'scorecard_form.dart';

class HomeScreen extends StatefulWidget {
  final String username;
  final String stationName;
  final String trainNumber;

  const HomeScreen({
    super.key,
    required this.username,
    required this.stationName,
    required this.trainNumber,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Tab> myTabs = const [
    Tab(text: 'Scorecard'),
    Tab(text: 'Summary'),
    Tab(text: 'Settings'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: myTabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Digital Score Card App'),
        bottom: TabBar(
          controller: _tabController,
          tabs: myTabs,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          ScorecardFormScreen(
            username: widget.username,
            stationName: widget.stationName,
            trainNumber: widget.trainNumber,
          ),
          const Center(child: Text('Summary Tab - Coming Soon')),
          const Center(child: Text('Settings Tab - Coming Soon')),
        ],
      ),
    );
  }
}
