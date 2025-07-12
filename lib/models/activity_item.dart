import 'score_entry.dart';

class ActivityItem {
  final String label;                 // e.g. T1, B1
  final String description;          // Full description
  final Map<String, ScoreEntry> coachScores; // C1–C13 scores

  ActivityItem({
    required this.label,
    required this.description,
    required this.coachScores,
  });
}
