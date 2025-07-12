import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shopping_list/models/score_entry.dart';
import 'package:shopping_list/screens/score_summary.dart';
import 'package:shopping_list/screens/submission_list_screen.dart';

import '../widgets/score_input_tile.dart';

class ScorecardFormScreen extends StatefulWidget {
  final String username;
  final String stationName;
  final String trainNumber;


  const ScorecardFormScreen({super.key, required this.username, required this.stationName, required this.trainNumber});

  @override
  State<ScorecardFormScreen> createState() => _ScorecardFormScreenState();
}

class _ScorecardFormScreenState extends State<ScorecardFormScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Map<String, List<ScoreEntry>> _coachWiseScores = {};
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 13, vsync: this); // C1 to C13

    for (int i = 1; i <= 13; i++) {
      final coachId = 'C$i';
      _coachWiseScores[coachId] = [
        for (int t = 1; t <= 4; t++)
          ScoreEntry(label: 'Toilet T$t'),
        ScoreEntry(label: 'Vestibule B1'),
        ScoreEntry(label: 'Vestibule B2'),
        ScoreEntry(label: 'Doorway D1'),
        ScoreEntry(label: 'Doorway D2'),
      ];
    }
  }

  Future<void> _generatePdf() async {
    final pdf = pw.Document();

    final coaches = _coachWiseScores.keys.toList();

    final allLabels = <String>{};
    for (var scores in _coachWiseScores.values) {
      for (var entry in scores) {
        allLabels.add(entry.label);
      }
    }
    final labelsList = allLabels.toList()..sort();

    String scoreText(String coachId, String label) {
      final entries = _coachWiseScores[coachId]!;
      final entry = entries.firstWhere(
            (e) => e.label == label,
        orElse: () => ScoreEntry(label: label, score: null, remarks: null),
      );
      return entry.score?.toString() ?? '-';
    }

    String remarksText(String coachId, String label) {
      final entries = _coachWiseScores[coachId]!;
      final entry = entries.firstWhere(
            (e) => e.label == label,
        orElse: () => ScoreEntry(label: label, score: null, remarks: null),
      );
      final r = entry.remarks?.trim();
      if (r == null || r.isEmpty) return '';
      return r;
    }

    final half = (coaches.length / 2).ceil();
    final firstHalf = coaches.sublist(0, half);
    final secondHalf = coaches.sublist(half);

    pw.Widget buildCoachTable(List<String> coachSubset) {
      final headers = <pw.Widget>[
        pw.Container(
          padding: const pw.EdgeInsets.all(6),
          child: pw.Text('Item',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
        )
      ];
      headers.addAll(coachSubset.map((c) => pw.Container(
        padding: const pw.EdgeInsets.all(6),
        alignment: pw.Alignment.center,
        child: pw.Text(c,
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
      )));

      final rows = <pw.TableRow>[];
      rows.add(pw.TableRow(
        children: headers,
        decoration: const pw.BoxDecoration(color: PdfColors.grey300),
      ));

      for (var label in labelsList) {
        final scoreCells = <pw.Widget>[
          pw.Padding(
            padding: const pw.EdgeInsets.all(6),
            child: pw.Text(label,
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 13)),
          ),
        ];
        final remarksCells = <pw.Widget>[
          pw.Padding(
            padding: const pw.EdgeInsets.all(6),
            child: pw.Text(''),
          ),
        ];

        for (var coach in coachSubset) {
          scoreCells.add(pw.Padding(
            padding: const pw.EdgeInsets.all(6),
            child: pw.Text(scoreText(coach, label),
                textAlign: pw.TextAlign.center, style: const pw.TextStyle(fontSize: 13)),
          ));
          remarksCells.add(pw.Padding(
            padding: const pw.EdgeInsets.all(6),
            child: pw.Text(
              remarksText(coach, label),
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey800),
              textAlign: pw.TextAlign.center,
            ),
          ));
        }

        rows.add(pw.TableRow(children: scoreCells));
        rows.add(pw.TableRow(children: remarksCells));
      }

      return pw.Table(
        border: pw.TableBorder.all(width: 0.7, color: PdfColors.grey),
        children: rows,
        defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
        columnWidths: {
          0: pw.FlexColumnWidth(3),
          for (int i = 1; i <= coachSubset.length; i++) i: pw.FlexColumnWidth(1),
        },
      );
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Text('Train Cleanliness Score Card',
              style:  pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 15),
          pw.Text('Station: ${widget.stationName}', style: const pw.TextStyle(fontSize: 16)),
          pw.Text('Train No.: ${widget.trainNumber}', style: const pw.TextStyle(fontSize: 16)),
          pw.Text('Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}',
              style: const pw.TextStyle(fontSize: 16)),
          pw.SizedBox(height: 25),
          buildCoachTable(firstHalf),
        ],
      ),
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Text('Train Cleanliness Score Card (contd.)',
              style:  pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 15),
          pw.Text('Station: ${widget.stationName}', style: const pw.TextStyle(fontSize: 16)),
          pw.Text('Train No.: ${widget.trainNumber}', style: const pw.TextStyle(fontSize: 16)),
          pw.Text('Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}',
              style: const pw.TextStyle(fontSize: 16)),
          pw.SizedBox(height: 25),
          buildCoachTable(secondHalf),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (format) => pdf.save());
  }




  Future<void> _submitForm() async {
    if (widget.stationName.isEmpty || widget.trainNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter Station and Train Number')),
      );
      return;
    }

    final Map<String, dynamic> data = {
      'username': widget.username,
      'station': widget.stationName,
      'trainNumber': widget.trainNumber,
      'date': DateFormat('yyyy-MM-dd').format(_selectedDate),
      'submittedAt': DateTime.now().toIso8601String(),
      'scores': _coachWiseScores.map((coachId, entries) {
        return MapEntry(
          coachId,
          entries
              .map((e) => {
            'label': e.label,
            'score': e.score ?? 0,
            'remarks': e.remarks ?? '',
          })
              .toList(),
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
    final screenWidth = MediaQuery.of(context).size.width;
    final remarksFieldWidth = screenWidth * 0.4;
    int _selectedIndex = 0;
    int? _hoveredIndex;
    bool isDateSelected = _selectedDate != null;




    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade700,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.stationName,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    offset: Offset(0, 1),
                    blurRadius: 3,
                    color: Colors.black45,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Train No: ${widget.trainNumber}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.blue.shade100,
                fontWeight: FontWeight.w600,
                shadows: const [
                  Shadow(
                    offset: Offset(0, 1),
                    blurRadius: 2,
                    color: Colors.black26,
                  ),
                ],
              ),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.amberAccent,
          labelColor: Colors.white,      // <-- set selected tab label color to white
          unselectedLabelColor: Colors.white70,  // <-- unselected tabs a bit faded white
          tabs: [for (int i = 1; i <= 13; i++) Tab(text: 'C$i')],
        ),

      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(), // Prevent future dates
                    );
                    if (pickedDate != null) {
                      setState(() {
                        _selectedDate = pickedDate;
                      });
                    }
                  },
                  icon: const Icon(Icons.calendar_today_outlined, size: 18),
                  label: const Text('Pick Date'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                ),


              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    for (int i = 1; i <= 13; i++) _buildCoachForm('C$i', remarksFieldWidth),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Theme.of(context).colorScheme.surface,
          selectedItemColor: Theme.of(context).colorScheme.primary,
          unselectedItemColor: Colors.grey[600],
          showSelectedLabels: false,
          showUnselectedLabels: false,
          elevation: 10,
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() => _selectedIndex = index);

            switch (index) {
              case 0:
                _generatePdf();
                break;
              case 1:
                _submitForm();
                break;
              case 2:
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ScoreSummaryScreen(
                      coachWiseScores: _coachWiseScores,
                      stationName: widget.stationName,
                      trainNumber: widget.trainNumber,
                      inspectionDate: _selectedDate,
                    ),
                  ),
                );
                break;
              case 3:
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => SubmissionListScreen(username: widget.username),
                  ),
                );
                break;
            }
          },
          items: List.generate(4, (index) {
            final icons = [
              Icons.print,
              Icons.send,
              Icons.list_alt,
              Icons.history,
            ];
            final labels = ['Print', 'Submit', 'Review', 'History'];

            return BottomNavigationBarItem(
              label: labels[index],
              icon: MouseRegion(
                onEnter: (_) {
                  setState(() => _hoveredIndex = index);
                },
                onExit: (_) {
                  setState(() => _hoveredIndex = null);
                },
                child: AnimatedScale(
                  scale: (_selectedIndex == index || _hoveredIndex == index) ? 1.3 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  child: Icon(icons[index]),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }


  Widget _buildCoachForm(String coachId, double remarksFieldWidth) {
    final entries = _coachWiseScores[coachId]!;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: MaterialStateProperty.resolveWith((states) => Colors.blue.shade100),
        columnSpacing: 20,
        columns: const [
          DataColumn(
              label: Text('S. No.',
                  style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(
              label: Text('Item',
                  style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(
              label: Text('Score',
                  style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(
              label: Text('Remarks',
                  style: TextStyle(fontWeight: FontWeight.bold))),
        ],
        rows: List<DataRow>.generate(entries.length, (index) {
          final entry = entries[index];

          return DataRow(
            color: MaterialStateProperty.resolveWith<Color?>(
                    (Set<MaterialState> states) {
                  return index.isEven ? Colors.blue.shade50 : null;
                }),
            cells: [
              DataCell(Text('${index + 1}')),
              DataCell(Text(entry.label)),
              DataCell(
                DropdownButton<int?>(
                  value: entry.score,
                  hint: const Text('-'),
                  underline: const SizedBox(),
                  items: [
                    const DropdownMenuItem<int?>(
                      value: null,
                      child: Text('-'),
                    ),
                    ...List.generate(
                      10,
                          (i) => DropdownMenuItem<int?>(
                        value: i + 1,
                        child: Text('${i + 1}'),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      entry.score = value;
                    });
                  },
                ),
              ),
              DataCell(
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: SizedBox(
                    width: remarksFieldWidth < 180 ? 180 : remarksFieldWidth,
                    child: TextFormField(
                      initialValue: entry.remarks ?? '',
                      decoration: const InputDecoration(
                        hintText: 'Optional',
                        isDense: true,
                        border: OutlineInputBorder(),
                        contentPadding:
                        EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      ),
                      onChanged: (text) {
                        entry.remarks = text;
                      },
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  @override
  void dispose() {
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
          value['id'] = key;
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
      appBar: AppBar(
        title: const Text('Submission History'),
        backgroundColor: Colors.blue.shade700,
      ),
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
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  onChanged: (value) {
                    _stationFilter = value;
                    _applyFilters();
                  },
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _selectedDate == null
                            ? 'Filter by Date: None'
                            : 'Filter by Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate!)}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
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
                        tooltip: 'Clear Date Filter',
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
                : GridView.builder(
              padding: const EdgeInsets.all(10),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
              ),
              itemCount: _filteredSubmissions.length,
              itemBuilder: (ctx, i) {
                final sub = _filteredSubmissions[i];
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => SubmissionDetailScreen(submission: sub),
                    ));
                  },
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.description, size: 30, color: Colors.blueAccent),
                          Text('Station: ${sub['station']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text('Train: ${sub['trainNumber']}'),
                          Text('Date: ${sub['date']}'),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: IconButton(
                              icon: const Icon(Icons.delete, size: 20, color: Colors.redAccent),
                              onPressed: () => _deleteSubmission(sub['id']),
                              tooltip: 'Delete Submission',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
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
        backgroundColor: Colors.blue.shade700,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Export as PDF',
            onPressed: () =>
                _exportAsPdf(
                    context, station, trainNumber, date, inspector, scores),
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
          const Text('Coach-wise Scores:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ...scores.entries.map((coach) {
            final List<dynamic> entries = coach.value;
            return ExpansionTile(
              title: Text('Coach ${coach.key}'),
              children: entries.map((entry) {
                final remarks = (entry['remarks']
                    ?.toString()
                    .trim()
                    .isEmpty ?? true) ? '-' : entry['remarks'];
                return ListTile(
                  title: Text(entry['label'] ?? '-'),
                  subtitle: Text('Score: ${entry['score'] ??
                      '-'} • Remarks: $remarks'),
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
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text('$title: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Future<void> _exportAsPdf(BuildContext context,
      String station,
      String trainNumber,
      String date,
      String inspector,
      Map<String, dynamic> scores,) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build: (pw.Context context) =>
        [
          pw.Text(
            'Train Cleanliness Score Card',
            style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 12),
          pw.Text('Station: $station'),
          pw.Text('Train No.: $trainNumber'),
          pw.Text('Date: $date'),
          pw.Text('Inspector: $inspector'),
          pw.SizedBox(height: 20),

          ...scores.entries.map((entry) {
            final String coachName = entry.key.toString();
            final List<dynamic> items = entry.value ?? [];

            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Coach $coachName',
                  style: pw.TextStyle(
                      fontSize: 18, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 8),
                pw.Table.fromTextArray(
                  headers: ['Label', 'Score', 'Remarks'],
                  data: items.map((e) {
                    final label = e['label'] ?? '';
                    final score = (e['score'] ?? '-').toString();
                    final remarks = (e['remarks']
                        ?.toString()
                        .trim()
                        .isEmpty ?? true)
                        ? '-'
                        : e['remarks'];
                    return [label, score, remarks];
                  }).toList(),
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  cellAlignment: pw.Alignment.centerLeft,
                ),
                pw.SizedBox(height: 16),
              ],
            );
          }).toList(),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (format) => pdf.save());
  }
}