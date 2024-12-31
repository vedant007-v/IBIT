import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DetailsCollection extends StatefulWidget {
  @override
  _DetailsCollectionState createState() => _DetailsCollectionState();
}

class _DetailsCollectionState extends State<DetailsCollection> {
  final TextEditingController sampleIdController = TextEditingController();
  final TextEditingController sampleNoController = TextEditingController();
  final TextEditingController longAxisController = TextEditingController();
  final TextEditingController shortAxisController = TextEditingController();
  final TextEditingController initialAxisController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;

  String selectedCity = 'Nadiad';
  final List<String> cities = ['Nadiad', 'Anand', 'Changa'];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5.0),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.purple,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(2.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Shape',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      _buildTextField(initialAxisController, 'Initial Axis'),
                      _buildTextField(longAxisController, 'Long Axis'),
                      _buildTextField(shortAxisController, 'Short Axis'),
                    ],
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sample Info',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      _buildTextField(sampleIdController, 'Sample ID'),
                      _buildTextField(sampleNoController, 'Sample Number'),
                      _buildCityDropdown(),
                      ElevatedButton(
                        onPressed: () => _saveSampleDetails(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple[600],
                        ),
                        child: Row(
                          children: [
                            SizedBox(width: 8),
                            Text('Upload', style: TextStyle(color: Colors.white)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hintText) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
          hintText: hintText,
          border: OutlineInputBorder(),
        ),
        keyboardType: TextInputType.number,
        style: TextStyle(fontSize: 14),
      ),
    );
  }

  Widget _buildCityDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: DropdownButtonFormField<String>(
        value: selectedCity,
        onChanged: (newValue) {
          setState(() {
            selectedCity = newValue!;
          });
        },
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
          border: OutlineInputBorder(),
        ),
        items: cities.map<DropdownMenuItem<String>>((String city) {
          return DropdownMenuItem<String>(
            value: city,
            child: Text(city),
          );
        }).toList(),
      ),
    );
  }

  void _saveSampleDetails(BuildContext context) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final sampleId = int.tryParse(sampleIdController.text);
      final sampleNo = int.tryParse(sampleNoController.text);
      final longAxis = int.tryParse(longAxisController.text);
      final initialAxis = int.tryParse(initialAxisController.text);
      final shortAxis = int.tryParse(shortAxisController.text);
      final timestamp = DateTime.now();

      if (sampleId != null &&
          sampleNo != null &&
          longAxis != null &&
          initialAxis != null &&
          shortAxis != null) {
        await _firestore.collection('samples').add({
          'sampleId': sampleId,
          'sampleNo': sampleNo,
          'Initial Axis': initialAxis,
          'Long Axis': longAxis,
          'Short Axis': shortAxis,
          'city': selectedCity,
          'timestamp': timestamp,
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Details saved successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
        _clearControllers();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Please enter valid data in all fields.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving sample details: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _clearControllers() {
    sampleIdController.clear();
    sampleNoController.clear();
    longAxisController.clear();
    shortAxisController.clear();
    initialAxisController.clear();
    selectedCity = 'Nadiad'; // Reset city to default
  }
}
