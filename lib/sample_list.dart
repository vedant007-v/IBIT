
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:excel/excel.dart' as excel_lib;

class SampleListPage extends StatefulWidget {
  @override
  _SampleListPageState createState() => _SampleListPageState();
}

class _SampleListPageState extends State<SampleListPage> {
  String searchQuery = '';
  String? selectedCity; // Holds the selected city filter
  TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sample List'),
        backgroundColor: Colors.purple[100],
      ),
      body: Column(
        children: [
          // Search field outside AppBar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Column(
              children: [
                DropdownButton<String>(
                  isExpanded: true,
                  value: selectedCity,
                  hint: Text("Select City", style: TextStyle(color: Colors.black)),
                  onChanged: (value) {
                    setState(() {
                      selectedCity = value;
                    });
                  },
                  items: ["Nadiad", "Annad", "Changa"].map((city) {
                    return DropdownMenuItem(
                      value: city,
                      child: Text(
                        city,
                        style: TextStyle(color: Colors.black),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    searchQuery = value.toLowerCase();
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search by Sample ID',
                  hintStyle: TextStyle(color: Colors.black.withOpacity(0.6)),
                  border: InputBorder.none,
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.black,
                  ),
                ),
                style: TextStyle(color: Colors.black),
              ),
            ),
          ),
          // Dropdown for selecting city
          
          // StreamBuilder for displaying sample list
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance.collection('extracted_features').snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error fetching data.'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No samples found.'));
                }

                final sampleDocs = snapshot.data!.docs;

                // Apply city and search filters
                final filteredSamples = sampleDocs.where((doc) {
                  final sampleId = doc['sampleId']?.toString().toLowerCase() ?? '';
                  final city = doc['city']?.toString();
                  final matchesCity = selectedCity == null || city == selectedCity; // Show all if no city is selected
                  final matchesQuery = sampleId.contains(searchQuery);
                  return matchesCity && matchesQuery;
                }).toList();

                return ListView.builder(
                  itemCount: filteredSamples.length,
                  itemBuilder: (context, index) {
                    final sample = filteredSamples[index];
                    final sampleId = sample['sampleId'] ?? 'Unknown ID';

                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                        title: Text(
                          'Sample ID: $sampleId',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'City: ${sample['city'] ?? 'Unknown'}',
                          style: TextStyle(fontSize: 14),
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.purple[100],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SampleDetailPage(sampleData: sample),
                            ),
                          );
                        },
                      ),
                    );
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





class SampleDetailPage extends StatelessWidget {
  final QueryDocumentSnapshot sampleData;

  SampleDetailPage({required this.sampleData});

  @override
  Widget build(BuildContext context) {
    // Fetch the sample data fields
    final sampleId = sampleData['sampleId'] ?? 'N/A';
    final sampleNo = sampleData['sampleNumber'] ?? 'N/A';
    final selectedColor = sampleData['selectedColor'] ?? 'N/A';
    final xAxis = sampleData['xAxis'] ?? 'N/A';
    final yAxis = sampleData['yAxis'] ?? 'N/A';
    final zAxis = sampleData['zAxis'] ?? 'N/A';
    final featureCounts = sampleData['featureCounts'] ?? {};
    final imageUrl = sampleData['imageUrl']; // Get the image URL from Firestore

    return Scaffold(
      appBar: AppBar(
        title: Text('Sample Details'),
        backgroundColor: Colors.purple[100],
        actions: [
          IconButton(
            icon: Icon(Icons.download),
            onPressed: () async {
              await exportToExcel(
                sampleId,
                sampleNo,
                selectedColor,
                xAxis,
                yAxis,
                zAxis,
                featureCounts,
               
              );
                ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Exported to Excel successfully!')),
  );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRichText('Sample ID: ', sampleId),
              _buildRichText('Sample No: ', sampleNo),
              _buildRichText('Selected Color: ', selectedColor),
              _buildRichText('X Axis: ', xAxis),
              _buildRichText('Y Axis: ', yAxis),
              _buildRichText('Z Axis: ', zAxis),
              SizedBox(height: 20),
              if (imageUrl != null) // Check if imageUrl exists
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Image.network(
                    imageUrl,
                    height: 300,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Text('Failed to load image.');
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) {
                        return child;
                      } else {
                        return Center(child: CircularProgressIndicator());
                      }
                    },
                  ),
                ),
              SizedBox(height: 20),
              Text(
                'Feature Counts:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              ..._buildFeatureCountList(featureCounts),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRichText(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: label,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextSpan(
              text: value,
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildFeatureCountList(Map<String, dynamic> featureCounts) {
    List<Widget> featureCountWidgets = [];

    featureCounts.forEach((feature, count) {
      featureCountWidgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Text('$feature: $count'),
        ),
      );
    });

    return featureCountWidgets;
  }

 Future<void> exportToExcel(
  String sampleId,
  String sampleNo,
  String selectedColor,
  String xAxis,
  String yAxis,
  String zAxis,
  Map<String, dynamic> featureCounts,
) async {
  var excel = excel_lib.Excel.createExcel(); // Create a new Excel document
  excel_lib.Sheet sheet = excel['Sheet1'];

  // Add headers
  // sheet.appendRow([
  //   excel_lib.TextCellValue('Sample ID'),
  //   excel_lib.TextCellValue('Sample No'),
  //   excel_lib.TextCellValue('Selected Color'),
  //   excel_lib.TextCellValue('X Axis'),
  //   excel_lib.TextCellValue('Y Axis'),
  //   excel_lib.TextCellValue('Z Axis'),
  //   excel_lib.TextCellValue('Feature'),
  //   excel_lib.TextCellValue('Count'),
  // ]);

  // Add main data in the first row

    sheet.appendRow([excel_lib.TextCellValue('Sample ID: $sampleId')]);
  sheet.appendRow([excel_lib.TextCellValue('Sample No: $sampleNo')]);
  sheet.appendRow([excel_lib.TextCellValue('X Axis: $xAxis')]);
  sheet.appendRow([excel_lib.TextCellValue('Y Axis: $yAxis')]);
  sheet.appendRow([excel_lib.TextCellValue('Z Axis: $zAxis')]);
  sheet.appendRow([excel_lib.TextCellValue(' ')]);
  sheet.appendRow([excel_lib.TextCellValue('feature')]);

  // sheet.appendRow([
  //   excel_lib.TextCellValue(sampleId),
  //   excel_lib.TextCellValue(sampleNo),
  //   excel_lib.TextCellValue(selectedColor),
  //   excel_lib.TextCellValue(xAxis),
  //   excel_lib.TextCellValue(yAxis),
  //   excel_lib.TextCellValue(zAxis),
  //   excel_lib.TextCellValue(''), // Leave Feature blank in the main row
  //   excel_lib.TextCellValue(''), // Leave Count blank in the main row
  // ]);

  // Add each feature and count in a new row
  featureCounts.forEach((feature, count) {
    sheet.appendRow([
      // excel_lib.TextCellValue(''), // Leave Sample ID blank
      // excel_lib.TextCellValue(''), // Leave Sample No blank
      // excel_lib.TextCellValue(''), // Leave Selected Color blank
      // excel_lib.TextCellValue(''), // Leave X Axis blank
      // excel_lib.TextCellValue(''), // Leave Y Axis blank
      // excel_lib.TextCellValue(''), // Leave Z Axis blank
      excel_lib.TextCellValue(feature), // Feature Name
      excel_lib.TextCellValue(count.toString()), // Feature Count
    ]);
  });

  // Convert the Excel document to a byte array
  List<int> excelFile = excel.save()!;

  // Define the output file path
  final directory = Directory('/storage/emulated/0/Download');
  final path = '${directory.path}/sample_details_$sampleId.xlsx';
  final file = File(path);

  // Write Excel data to file
  await file.writeAsBytes(excelFile);
  print('Excel file saved at: $path');
}


}
