// lib/screens/score_summary.dart
import 'package:flutter/material.dart';
import 'scorecard_form.dart'; // import your model or data structures

class ScoreSummaryScreen extends StatelessWidget {
  final Map<String, List<ScoreEntry>> coachWiseScores;
  final String stationName;
  final String trainNumber;
  final DateTime inspectionDate;

  const ScoreSummaryScreen({
    super.key,
    required this.coachWiseScores,
    required this.stationName,
    required this.trainNumber,
    required this.inspectionDate,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Score Summary'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: ListView(
          children: [
            Text('Station: $stationName'),
            Text('Train No: $trainNumber'),
            Text('Date: ${inspectionDate.toLocal().toString().split(' ')[0]}'),
            const SizedBox(height: 20),

            // Summary Table per Coach
            ...coachWiseScores.entries.map((entry) {
              final coachId = entry.key;
              final scores = entry.value;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Coach $coachId',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Table(
                    border: TableBorder.all(),
                    columnWidths: const {
                      0: FlexColumnWidth(4),
                      1: FlexColumnWidth(2),
                      2: FlexColumnWidth(4),
                    },
                    children: [
                      const TableRow(
                        decoration: BoxDecoration(color: Colors.grey),
                        children: [
                          Padding(
                            padding: EdgeInsets.all(6),
                            child: Text('Label', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          Padding(
                            padding: EdgeInsets.all(6),
                            child: Text('Score', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          Padding(
                            padding: EdgeInsets.all(6),
                            child: Text('Remarks', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      ...scores.map((e) {
                        return TableRow(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(6),
                              child: Text(e.label),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(6),
                              child: Text(e.score?.toString() ?? '-'),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(6),
                              child: Text(e.remarks ?? '-'),
                            ),
                          ],
                        );
                      }).toList(),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
