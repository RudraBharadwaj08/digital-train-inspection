import 'package:flutter/material.dart';
import '../models/score_entry.dart';

class ScoreInputTile extends StatefulWidget {
  final ScoreEntry entry;

  const ScoreInputTile({super.key, required this.entry});

  @override
  State<ScoreInputTile> createState() => _ScoreInputTileState();
}

class _ScoreInputTileState extends State<ScoreInputTile> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.entry.label,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('Score:'),
                const SizedBox(width: 10),
                DropdownButton<int>(
                  value: widget.entry.score,
                  hint: const Text('-'), // Show this if value is null
                  underline: const SizedBox(),
                  items: [
                    const DropdownMenuItem<int>(
                      value: null,
                      child: Text('-'),
                    ),
                    ...List.generate(
                      10,
                          (i) => DropdownMenuItem(
                        value: i + 1,
                        child: Text('${i + 1}'),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      widget.entry.score = value;
                    });
                  },
                ),

              ],
            ),
            const SizedBox(height: 10),
            TextFormField(
              initialValue: widget.entry.remarks ?? '',
              decoration: const InputDecoration(
                labelText: 'Remarks (optional)',
                border: OutlineInputBorder(),
              ),
              onChanged: (text) {
                widget.entry.remarks = text;
              },
            ),
          ],
        ),
      ),
    );
  }
}
