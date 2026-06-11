import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'werkbon_detail_page.dart';

class WerkbonnenPage extends StatefulWidget {
  const WerkbonnenPage({super.key});

  @override
  State<WerkbonnenPage> createState() => _WerkbonnenPageState();
}

class _WerkbonnenPageState extends State<WerkbonnenPage> {
  static const _statusFilters = [
    'Alle',
    'Geparsed',
    'Goedgekeurd',
    'In Productie',
    'Gereed',
  ];

  bool isUploading = false;
  bool isLoading = true;

  List<dynamic> werkbonnen = [];

  final String apiUrl = 'http://10.26.80.10/langman_api';
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';
  String _selectedStatus = 'Alle';

  @override
  void initState() {
    super.initState();
    laadWerkbonnen();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<dynamic> get _gefilterdeWerkbonnen {
    return werkbonnen.where((werkbon) {
      final werkbonnummer =
          (werkbon['werkbonnummer'] ?? '').toString().toLowerCase();
      final klantnaam =
          (werkbon['klantnaam'] ?? '').toString().toLowerCase();
      final status = (werkbon['status'] ?? '').toString();

      final matchtZoekopdracht = _searchQuery.isEmpty ||
          werkbonnummer.contains(_searchQuery) ||
          klantnaam.contains(_searchQuery);

      final matchtStatus =
          _selectedStatus == 'Alle' || status == _selectedStatus;

      return matchtZoekopdracht && matchtStatus;
    }).toList();
  }

  Future<void> laadWerkbonnen() async {
    try {
      final response = await http.get(
        Uri.parse('$apiUrl/get_werkbonnen.php'),
      );

      final data = jsonDecode(response.body);

      setState(() {
        werkbonnen = data is List ? data : [];
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      debugPrint(e.toString());
    }
  }

  Future<void> keurWerkbonGoed(int id) async {
    await http.post(
      Uri.parse('$apiUrl/approve_werkbon.php'),
      body: {
        'id': id.toString(),
      },
    );

    await laadWerkbonnen();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Werkbon goedgekeurd'),
      ),
    );
  }

  Future<void> uploadPdf() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: true,
      );

      if (result == null) return;

      setState(() {
        isUploading = true;
      });

      final file = result.files.single;

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$apiUrl/upload_werkbon.php'),
      );

      request.files.add(
        http.MultipartFile.fromBytes(
          'pdf',
          file.bytes!,
          filename: file.name,
        ),
      );

      final response = await request.send();

      setState(() {
        isUploading = false;
      });

      if (!mounted) return;

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Werkbon geüpload: ${file.name}'),
          ),
        );

        laadWerkbonnen();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Upload mislukt'),
          ),
        );
      }
    } catch (e) {
      setState(() {
        isUploading = false;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fout: $e'),
        ),
      );
    }
  }

  Future<void> verwijderWerkbon(
    int id,
    String werkbonnummer,
  ) async {
    final bevestigen = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Werkbon verwijderen'),
          content: Text('Werkbon $werkbonnummer verwijderen?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annuleren'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Verwijderen'),
            ),
          ],
        );
      },
    );

    if (bevestigen != true) return;

    await http.post(
      Uri.parse('$apiUrl/delete_werkbon.php'),
      body: {
        'id': id.toString(),
      },
    );

    await laadWerkbonnen();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Werkbon verwijderd'),
      ),
    );
  }

  Color _statusKleur(String status) {
    switch (status) {
      case 'Goedgekeurd':
        return Colors.green.shade100;
      case 'Geparsed':
        return Colors.orange.shade100;
      case 'In Productie':
        return Colors.blue.shade100;
      case 'Gereed':
        return Colors.teal.shade100;
      default:
        return Colors.grey.shade200;
    }
  }

  Widget _buildHeader() {
    final totaal = werkbonnen.length;
    final zichtbaar = _gefilterdeWerkbonnen.length;
    final heeftFilter =
        _searchQuery.isNotEmpty || _selectedStatus != 'Alle';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            heeftFilter
                ? '$zichtbaar van $totaal werkbonnen'
                : '$totaal werkbonnen',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Zoek op werkbonnummer of klantnaam',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value.trim().toLowerCase();
              });
            },
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _statusFilters.map((status) {
                final isSelected = _selectedStatus == status;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(status),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() {
                        _selectedStatus = status;
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWerkbonCard(Map<String, dynamic> werkbon) {
    final status = (werkbon['status'] ?? '').toString();
    final id = int.tryParse(werkbon['id']?.toString() ?? '');

    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              werkbon['werkbonnummer']?.toString() ?? '',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              werkbon['klantnaam']?.toString() ?? '',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              'Contact: ${werkbon['contactpersoon'] ?? '-'}',
            ),
            const SizedBox(height: 4),
            Text(
              'Leverdatum: ${werkbon['leverdatum'] ?? '-'}',
            ),
            const SizedBox(height: 10),
            Chip(
              backgroundColor: _statusKleur(status),
              label: Text(status.isEmpty ? 'Onbekend' : status),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: id == null
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => WerkbonDetailPage(
                                werkbonId: id,
                              ),
                            ),
                          );
                        },
                  icon: const Icon(Icons.visibility),
                  label: const Text('Openen'),
                ),
                ElevatedButton.icon(
                  onPressed: id == null
                      ? null
                      : () => keurWerkbonGoed(id),
                  icon: const Icon(Icons.check),
                  label: const Text('Goedkeuren'),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: id == null
                      ? null
                      : () => verwijderWerkbon(
                            id,
                            werkbon['werkbonnummer']?.toString() ?? '',
                          ),
                  icon: const Icon(Icons.delete),
                  label: const Text('Verwijderen'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gefilterd = _gefilterdeWerkbonnen;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Werkbonnen Inbox'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: isUploading ? null : uploadPdf,
        icon: const Icon(Icons.upload_file),
        label: const Text('Upload PDF'),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: laadWerkbonnen,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 88),
                children: [
                  _buildHeader(),
                  if (gefilterd.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(32),
                      child: Center(
                        child: Text(
                          werkbonnen.isEmpty
                              ? 'Geen werkbonnen gevonden'
                              : 'Geen werkbonnen voor deze zoekopdracht of filter',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  else
                    ...gefilterd.map((werkbon) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _buildWerkbonCard(
                          Map<String, dynamic>.from(werkbon as Map),
                        ),
                      );
                    }),
                ],
              ),
            ),
    );
  }
}
