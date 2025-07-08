import 'package:flutter/material.dart';
import '../models/score_entry.dart';

class ScoreInputTile extends StatelessWidget {
  final ScoreEntry entry;
  final void Function(int) onScoreChanged;
  final void Function(String) onRemarksChanged;

  const ScoreInputTile({
    super.key,
    required this.entry,
    required this.onScoreChanged,
    required this.onRemarksChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(entry.label, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            DropdownButton<int>(
              value: entry.score,
              items: List.generate(
                10,
                    (index) => DropdownMenuItem(
                  value: index + 1,
                  child: Text((index + 1).toString()),
                ),
              ),
              onChanged: (value) {
                if (value != null) {
                  onScoreChanged(value);
                }
              },
            ),
            const SizedBox(height: 8),
            TextField(
              decoration: const InputDecoration(labelText: 'Remarks'),
              controller: TextEditingController(text: entry.remarks),
              onChanged: onRemarksChanged,
            ),
          ],
        ),
      ),
    );
  }
}
