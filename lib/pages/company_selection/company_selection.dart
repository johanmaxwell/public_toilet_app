import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:public_app/models/company_data.dart';
import 'package:public_app/pages/company_selection/company_dropdown.dart';
import 'package:public_app/pages/gender_selection/gender_selection_page.dart';
import 'package:public_app/utils/firebase_usage_monitor.dart';

class CompanySelectionPage extends StatefulWidget {
  const CompanySelectionPage({super.key});

  @override
  State<CompanySelectionPage> createState() => _CompanySelectionPageState();
}

class _CompanySelectionPageState extends State<CompanySelectionPage> {
  String? selectedCompany;
  late Future<List<CompanyData>> companyFuture;

  final FirestoreUsageMonitor usageMonitor = FirestoreUsageMonitor();

  @override
  void initState() {
    super.initState();
    companyFuture = fetchCompanyList();
  }

  Future<List<CompanyData>> fetchCompanyList() async {
    final List<CompanyData> companyList = [];
    final snapshot =
        await FirebaseFirestore.instance
            .collection('company')
            .where('is_deactivated', isEqualTo: false)
            .get();

    // Track reads
    usageMonitor.incrementReads(snapshot.docs.length);

    for (var doc in snapshot.docs) {
      final data = doc.data();
      companyList.add(
        CompanyData.fromFirestore(doc.id, data['privacy'], data['kode_akses']),
      );
    }
    return companyList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal[50],
      body: FutureBuilder<List<CompanyData>>(
        future: companyFuture,
        builder: (context, snapshot) {
          final companyData = snapshot.data ?? [];
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Selamat Datang!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  CompanyDropdown(
                    companyOption: companyData.map((c) => c.id).toList(),
                    selectedCompany: selectedCompany,
                    onChanged: (value) {
                      setState(() {
                        selectedCompany = value;

                        if (selectedCompany != null) {
                          usageMonitor.updateCompanyId(selectedCompany!);
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      if (selectedCompany == null) {
                        showDialog(
                          context: context,
                          builder:
                              (context) => AlertDialog(
                                title: const Text('Error'),
                                content: const Text(
                                  'Please select a company first.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('OK'),
                                  ),
                                ],
                              ),
                        );
                        return;
                      }

                      final selectedCompanyData = companyData.firstWhere(
                        (company) => company.id == selectedCompany,
                      );
                      if (selectedCompanyData.privacy == 'public') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => GenderSelectionPage(
                                  company: selectedCompany!,
                                ),
                          ),
                        );
                      } else {
                        _showKodeAksesDialog(selectedCompanyData);
                      }
                    },
                    icon: const Icon(
                      Icons.check_circle_outline,
                      color: Colors.yellowAccent,
                    ),
                    label: const Text(
                      'Submit',
                      style: TextStyle(color: Colors.yellowAccent),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlue,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showKodeAksesDialog(CompanyData companyData) {
    TextEditingController kodeAksesController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Masukkan kode akses'),
          content: TextField(
            controller: kodeAksesController,
            decoration: const InputDecoration(labelText: 'Access Code'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final enteredKodeAkses = kodeAksesController.text.trim();
                if (enteredKodeAkses == companyData.kodeAkses) {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) =>
                              GenderSelectionPage(company: companyData.id),
                    ),
                  );
                } else {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Gagal'),
                        content: const Text('Kode Akses Invalid'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }
}
