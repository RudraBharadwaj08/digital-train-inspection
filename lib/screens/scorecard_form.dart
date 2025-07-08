import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shopping_list/screens/score_summary.dart';
import 'package:shopping_list/screens/submission_list_screen.dart';


class ScoreEntry {
  final String label;
  int? score;
  String? remarks;

  ScoreEntry({required this.label, this.score, this.remarks});
}

class ScorecardFormScreen extends StatefulWidget {
  final String username;
  const ScorecardFormScreen({super.key, required this.username});

  @override
  State<ScorecardFormScreen> createState() => _ScorecardFormScreenState();
}

class _ScorecardFormScreenState extends State<ScorecardFormScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Map<String, List<ScoreEntry>> _coachWiseScores = {};
  final TextEditingController _stationController = TextEditingController();
  final TextEditingController _trainController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 13, vsync: this);

    for (int i = 1; i <= 13; i++) {
      final String coachId = 'C$i';
      List<ScoreEntry> entries = [];

      for (int t = 1; t <= 4; t++) {
        entries.add(ScoreEntry(label: '$coachId - Toilet T$t'));
      }

      entries.addAll([
        ScoreEntry(label: '$coachId - Vestibule B1'),
        ScoreEntry(label: '$coachId - Vestibule B2'),
        ScoreEntry(label: '$coachId - Doorway D1'),
        ScoreEntry(label: '$coachId - Doorway D2'),
      ]);

      _coachWiseScores[coachId] = entries;
    }
  }

  Future<void> _generatePdf() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Text('Train Cleanliness Score Card',
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          pw.Text('Station: ${_stationController.text}'),
          pw.Text('Train No.: ${_trainController.text}'),
          pw.Text('Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}'),
          pw.SizedBox(height: 20),
          ..._coachWiseScores.entries.map((entry) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Coach ${entry.key}',
                    style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                pw.Table.fromTextArray(
                  headers: ['Label', 'Score', 'Remarks'],
                  data: entry.value
                      .map((e) => [
                    e.label,
                    e.score?.toString() ?? '-',
                    e.remarks ?? '-'
                  ])
                      .toList(),
                ),
                pw.SizedBox(height: 15),
              ],
            );
          }).toList(),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (format) => pdf.save());
  }

  Future<void> _submitForm() async {
    if (_stationController.text.isEmpty || _trainController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter Station and Train Number')),
      );
      return;
    }

    final Map<String, dynamic> data = {
      'username': widget.username,
      'station': _stationController.text,
      'trainNumber': _trainController.text,
      'date': DateFormat('yyyy-MM-dd').format(_selectedDate),
      'submittedAt': DateTime.now().toIso8601String(),
      'scores': _coachWiseScores.map((coachId, entries) {
        return MapEntry(
          coachId,
          entries.map((e) => {
            'label': e.label,
            'score': e.score ?? 0,
            'remarks': e.remarks ?? '',
          }).toList(),
        );
      }),
    };

    final url = Uri.parse('https://flutter-scorecard-app-default-rtdb.firebaseio.com/submissions.json');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Form submitted to Firebase successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Firebase submission failed: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting to Firebase: $e')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Digital Score Card Form'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: [
            for (int i = 1; i <= 13; i++) Tab(text: 'C$i'),
          ],
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          TextField(
                            controller: _stationController,
                            decoration: const InputDecoration(labelText: 'Station Name'),
                          ),
                          TextField(
                            controller: _trainController,
                            decoration: const InputDecoration(labelText: 'Train Number'),
                            keyboardType: TextInputType.number,
                          ),
                          Row(
                            children: [
                              Text('Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}'),
                              IconButton(
                                icon: const Icon(Icons.calendar_today),
                                onPressed: () async {
                                  final pickedDate = await showDatePicker(
                                    context: context,
                                    initialDate: _selectedDate,
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2100),
                                  );
                                  if (pickedDate != null) {
                                    setState(() {
                                      _selectedDate = pickedDate;
                                    });
                                  }
                                },
                              )
                            ],
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            alignment: WrapAlignment.center,
                            children: [
                              ElevatedButton.icon(
                                icon: const Icon(Icons.print),
                                label: const Text('Print Summary'),
                                onPressed: _generatePdf,
                              ),
                              ElevatedButton.icon(
                                icon: const Icon(Icons.send),
                                label: const Text('Submit'),
                                onPressed: _submitForm,
                              ),
                              ElevatedButton.icon(
                                icon: const Icon(Icons.list_alt),
                                label: const Text('Review Summary'),
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => ScoreSummaryScreen(
                                        coachWiseScores: _coachWiseScores,
                                        stationName: _stationController.text,
                                        trainNumber: _trainController.text,
                                        inspectionDate: _selectedDate,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              ElevatedButton.icon(
                                icon: const Icon(Icons.history),
                                label: const Text('View Submissions'),
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => SubmissionListScreen(username: widget.username),
                                    ),
                                  );
                                },
                              ),


                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: SizedBox(
                        height: constraints.maxHeight * 0.7,
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            for (int i = 1; i <= 13; i++) _buildCoachForm('C$i')
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCoachForm(String coachId) {
    final entries = _coachWiseScores[coachId]!;
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.label, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('Score:'),
                    const SizedBox(width: 8),
                    DropdownButton<int>(
                      value: entry.score,
                      hint: const Text('Select'),
                      items: List.generate(10, (i) => i + 1)
                          .map((score) => DropdownMenuItem(
                        value: score,
                        child: Text(score.toString()), // <--- Default key reused!
                      ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          entry.score = value;
                        });
                      },
                    ),

                  ],
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Remarks (optional)'),
                  onChanged: (value) => entry.remarks = value,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _stationController.dispose();
    _trainController.dispose();
    _tabController.dispose();
    super.dispose();
  }
}

class SubmissionListScreen extends StatefulWidget {
  final String username;
  const SubmissionListScreen({super.key, required this.username});

  @override
  State<SubmissionListScreen> createState() => _SubmissionListScreenState();
}

class _SubmissionListScreenState extends State<SubmissionListScreen> {
  List<Map<String, dynamic>> _allSubmissions = [];
  List<Map<String, dynamic>> _filteredSubmissions = [];
  bool _isLoading = true;
  String _stationFilter = '';
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _fetchSubmissions();
  }

  Future<void> _fetchSubmissions() async {
    final url = Uri.parse('https://flutter-scorecard-app-default-rtdb.firebaseio.com/submissions.json');

    try {
      final response = await http.get(url);
      final Map<String, dynamic> data = json.decode(response.body);

      final List<Map<String, dynamic>> loaded = [];

      data.forEach((key, value) {
        if (value['username'] == widget.username) {
          value['id'] = key; // Store Firebase key for delete
          loaded.add(value);
        }
      });

      setState(() {
        _allSubmissions = loaded.reversed.toList();
        _applyFilters();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading submissions: $e')),
      );
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredSubmissions = _allSubmissions.where((sub) {
        final matchesStation = _stationFilter.isEmpty ||
            sub['station'].toString().toLowerCase().contains(_stationFilter.toLowerCase());
        final matchesDate = _selectedDate == null ||
            sub['date'] == DateFormat('yyyy-MM-dd').format(_selectedDate!);
        return matchesStation && matchesDate;
      }).toList();
    });
  }

  Future<void> _deleteSubmission(String id) async {
    final url = Uri.parse('https://flutter-scorecard-app-default-rtdb.firebaseio.com/submissions/$id.json');
    try {
      final response = await http.delete(url);
      if (response.statusCode == 200) {
        setState(() {
          _allSubmissions.removeWhere((s) => s['id'] == id);
          _applyFilters();
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Submission deleted')));
      } else {
        throw Exception('Failed to delete');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Delete failed: $e')));
    }
  }

  void _resetFilters() {
    setState(() {
      _stationFilter = '';
      _selectedDate = null;
      _applyFilters();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Submission History')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Filter by Station',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (value) {
                    _stationFilter = value;
                    _applyFilters();
                  },
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _selectedDate == null
                            ? 'Filter by Date: None'
                            : 'Filter by Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate!)}',
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2022),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          _selectedDate = picked;
                          _applyFilters();
                        }
                      },
                      child: const Text('Pick Date'),
                    ),
                    if (_selectedDate != null)
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: _resetFilters,
                      )
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredSubmissions.isEmpty
                ? const Center(child: Text('No submissions match your filter.'))
                : ListView.builder(
              itemCount: _filteredSubmissions.length,
              itemBuilder: (ctx, i) {
                final sub = _filteredSubmissions[i];
                return ListTile(
                  leading: const Icon(Icons.description),
                  title: Text('${sub['station']} | Train ${sub['trainNumber']}'),
                  subtitle: Text('Date: ${sub['date']}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _deleteSubmission(sub['id']),
                  ),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => SubmissionDetailScreen(submission: sub),
                    ));
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class SubmissionDetailScreen extends StatelessWidget {
  final Map<String, dynamic> submission;

  const SubmissionDetailScreen({super.key, required this.submission});

  @override
  Widget build(BuildContext context) {
    final station = submission['station'] ?? 'Unknown';
    final trainNumber = submission['trainNumber'] ?? 'Unknown';
    final date = submission['date'] ?? 'Unknown';
    final inspector = submission['username'] ?? 'Unknown';
    final scores = Map<String, dynamic>.from(submission['scores'] ?? {});

    return Scaffold(
      appBar: AppBar(
        title: const Text('Submission Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () => _exportAsPdf(context, station, trainNumber, date, inspector, scores),
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          _buildInfoRow('Station', station),
          _buildInfoRow('Train Number', trainNumber),
          _buildInfoRow('Date', date),
          _buildInfoRow('Inspector', inspector),
          const SizedBox(height: 20),
          const Text('Coach-wise Scores:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ...scores.entries.map((coach) {
            final List<dynamic> entries = coach.value;
            return ExpansionTile(
              title: Text('Coach ${coach.key}'),
              children: entries.map((entry) {
                return ListTile(
                  title: Text(entry['label'] ?? '-'),
                  subtitle: Text(
                    'Score: ${entry['score'] ?? '-'} • Remarks: ${entry['remarks']?.toString().trim().isEmpty ?? true ? '-' : entry['remarks']}',
                  ),
                );
              }).toList(),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text('$title: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Future<void> _exportAsPdf(
      BuildContext context,
      String station,
      String trainNumber,
      String date,
      String inspector,
      Map<String, dynamic> scores,
      ) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build: (pw.Context context) => [
          pw.Text('Train Cleanliness Score Card',
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          pw.Text('Station: $station'),
          pw.Text('Train No.: $trainNumber'),
          pw.Text('Date: $date'),
          pw.Text('Inspector: $inspector'),
          pw.SizedBox(height: 20),
          ...scores.entries.map((entry) {
            final List<dynamic> items = entry.value;
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Coach ${entry.key}',
                    style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                pw.Table.fromTextArray(
                  headers: ['Label', 'Score', 'Remarks'],
                  data: items.map((e) {
                    return [
                      e['label'] ?? '',
                      (e['score'] ?? '-').toString(),
                      (e['remarks']?.toString().trim().isEmpty ?? true) ? '-' : e['remarks'],
                    ];
                  }).toList(),
                ),
                pw.SizedBox(height: 15),
              ],
            );
          }).toList(),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (format) => pdf.save());
  }
}
