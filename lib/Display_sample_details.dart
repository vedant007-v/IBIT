import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DisplaySamples extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.purple, width: 2.0),
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('samples').orderBy('timestamp', descending: true).limit(1).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildSampleRow(sampleId: 'N/A', sampleNo: 'N/A', initialAxis: 'N/A', longAxis: 'N/A', shortAxis: 'N/A');
          }

          final doc = snapshot.data!.docs.first;
          final data = doc.data() as Map<String, dynamic>;

          // Extracting values from the Firestore data
          String sampleId = data['sampleId']?.toString() ?? 'N/A';
          String sampleNo = data['sampleNo']?.toString() ?? 'N/A';
          String initialAxis = data['Initial Axis']?.toString() ?? 'N/A';
          String longAxis = data['Long Axis']?.toString() ?? 'N/A';
          String shortAxis = data['Short Axis']?.toString() ?? 'N/A';

          // You can pass these values further in your app, display them, or store them in state
          return _buildSampleRow(sampleId: sampleId, sampleNo: sampleNo, initialAxis: initialAxis, longAxis: longAxis, shortAxis: shortAxis);
        },
      ),
    );
  }

  Widget _buildSampleRow({required String sampleId, required String sampleNo, required String initialAxis, required String longAxis, required String shortAxis}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildRichText('Sample ID: ', sampleId),
            _buildRichText('Sample No: ', sampleNo),
          ],
        ),
        SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRichText('Short Axis: ', shortAxis),
            _buildRichText('Intermediate Axis: ', initialAxis),
            _buildRichText('Long Axis: ', longAxis),
          ],
        ),
      ],
    );
  }

  Widget _buildRichText(String label, String value) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: label,
            style: TextStyle(fontSize: 15, color: Colors.black),
          ),
          TextSpan(
            text: value,
            style: TextStyle(fontSize: 15, color: Colors.black),
          ),
        ],
      ),
      textAlign: TextAlign.justify,
    );
  }
}
