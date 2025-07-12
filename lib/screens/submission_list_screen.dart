import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class SubmissionListScreen extends StatefulWidget {
  final String username;

  const SubmissionListScreen({super.key, required this.username});

  @override
  State<SubmissionListScreen> createState() => _SubmissionListScreenState();
}

class _SubmissionListScreenState extends State<SubmissionListScreen> {
  List<Map<String, dynamic>> _submissions = [];
  List<String> _submissionKeys = [];
  List<Map<String, dynamic>> _filteredSubmissions = [];
  bool _isLoading = true;

  DateTime? _selectedDate;
  String _selectedStation = 'All';

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
      final List<String> keys = [];

      data.forEach((key, value) {
        if (value['username'] == widget.username) {
          loaded.add(value);
          keys.add(key);
        }
      });

      setState(() {
        _submissions = loaded;
        _submissionKeys = keys;
        _filteredSubmissions = List.from(_submissions);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading submissions: $e')),
      );
    }
  }

  void _filterSubmissions() {
    setState(() {
      _filteredSubmissions = _submissions.where((sub) {
        final matchesDate = _selectedDate == null ||
            sub['date'] == DateFormat('yyyy-MM-dd').format(_selectedDate!);
        final matchesStation =
            _selectedStation == 'All' || sub['station'] == _selectedStation;
        return matchesDate && matchesStation;
      }).toList();
    });
  }

  Future<void> _deleteSubmission(int index) async {
    final key = _submissionKeys[index];
    final url = Uri.parse('https://flutter-scorecard-app-default-rtdb.firebaseio.com/submissions/$key.json');

    try {
      final response = await http.delete(url);
      if (response.statusCode == 200) {
        setState(() {
          _submissions.removeAt(index);
          _submissionKeys.removeAt(index);
          _filteredSubmissions = List.from(_submissions);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Submission deleted successfully.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting submission: $e')),
      );
    }
  }

  Future<void> _exportFilteredSubmissionsAsPdf() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build: (pw.Context context) => [
          pw.Text('Filtered Submission Report',
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 15),
          ..._filteredSubmissions.map((sub) {
            final scores = Map<String, dynamic>.from(sub['scores'] ?? {});
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                    'Station: ${sub['station']}, Train: ${sub['trainNumber']}, Date: ${sub['date']}',
                    style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                pw.Text('Inspector: ${sub['username']}'),
                pw.SizedBox(height: 10),
                ...scores.entries.map((entry) {
                  final List<dynamic> items = entry.value;
                  return pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Coach ${entry.key}',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
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
                }),
                pw.Divider(thickness: 1),
                pw.SizedBox(height: 10),
              ],
            );
          }).toList(),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (format) => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    final stations = [
      'All',
      ..._submissions.map((s) => s['station']).toSet().cast<String>()
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Submission History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Export Filtered as PDF',
            onPressed: _filteredSubmissions.isEmpty
                ? null
                : _exportFilteredSubmissionsAsPdf,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      children: [
                        DropdownButton<String>(
                          value: _selectedStation,
                          items: stations
                              .map((s) => DropdownMenuItem(
                            value: s,
                            child: Text(s),
                          ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedStation = value!;
                              _filterSubmissions();
                            });
                          },
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.calendar_today),
                          label: Text(_selectedDate == null
                              ? 'Filter by Date'
                              : DateFormat('yyyy-MM-dd')
                              .format(_selectedDate!)),
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2023),
                              lastDate: DateTime.now(),
                            );
                            if (picked != null) {
                              setState(() {
                                _selectedDate = picked;
                                _filterSubmissions();
                              });
                            }
                          },
                        ),
                        const SizedBox(width: 10),
                        if (_selectedDate != null ||
                            _selectedStation != 'All')
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _selectedDate = null;
                                _selectedStation = 'All';
                                _filteredSubmissions =
                                    List.from(_submissions);
                              });
                            },
                            child: const Text('Clear Filters'),
                          ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _filteredSubmissions.isEmpty
                        ? const Center(child: Text('No submissions found.'))
                        : ListView.builder(
                      itemCount: _filteredSubmissions.length,
                      itemBuilder: (ctx, i) {
                        final sub = _filteredSubmissions[i];
                        final originalIndex =
                        _submissions.indexOf(sub);

                        return Dismissible(
                          key: ValueKey(sub['trainNumber'] + sub['date']),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),
                          confirmDismiss: (_) async {
                            return await showDialog<bool>(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text('Delete Confirmation'),
                                content: const Text('Are you sure you want to delete this submission?'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                                  TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
                                ],
                              ),
                            ) ??
                                false;
                          },
                          onDismissed: (_) => _deleteSubmission(originalIndex),
                          child: ListTile(
                            leading: const Icon(Icons.description),
                            title: Text('${sub['station']} - ${sub['trainNumber']}'),
                            subtitle: Text('Date: ${sub['date']}'),
                            trailing: PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert),
                              onSelected: (value) {
                                if (value == 'pdf') {
                                  _exportSingleSubmissionAsPdf(sub);
                                }
                                // Add more options like 'view' if needed
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'pdf',
                                  child: Row(
                                    children: [
                                      Icon(Icons.picture_as_pdf, size: 18),
                                      SizedBox(width: 8),
                                      Text('Export PDF'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

Future<void> _exportSingleSubmissionAsPdf(Map<String, dynamic> sub) async {
  final pdf = pw.Document();

  final String station = sub['station'] ?? '';
  final String trainNumber = sub['trainNumber'] ?? '';
  final String date = sub['date'] ?? '';
  final String inspector = sub['username'] ?? '';
  final Map<String, dynamic> scores = Map<String, dynamic>.from(sub['scores'] ?? {});

  pdf.addPage(
    pw.MultiPage(
      build: (pw.Context context) => [
        pw.Text('Train Cleanliness Score Card',
            style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 12),
        pw.Text('Station: $station'),
        pw.Text('Train No.: $trainNumber'),
        pw.Text('Date: $date'),
        pw.Text('Inspector: $inspector'),
        pw.SizedBox(height: 20),
        ...scores.entries.map((entry) {
          final List<dynamic> items = entry.value ?? [];
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Coach ${entry.key}',
                  style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              pw.Table.fromTextArray(
                headers: ['Label', 'Score', 'Remarks'],
                data: items.map((e) {
                  return [
                    e['label'] ?? '',
                    (e['score'] ?? '-').toString(),
                    (e['remarks']?.toString().trim().isEmpty ?? true) ? '-' : e['remarks'],
                  ];
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
