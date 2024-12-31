import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart';
import 'package:iBIT/learnmorefeature.dart';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';

class ScreenshotImagePage extends StatefulWidget {
  final Uint8List? image;
  final List<MapEntry<Offset, Color>> dots;
  final Map<String, int> featureCounts;
  final String? sampleId;
  final String? sampleNo;
  final String? initialAxis;
  final String? longAxis;
  final String? shortAxis;
  final String? city;

  ScreenshotImagePage({
    Key? key,
    required this.image,
    required this.dots,
    required this.featureCounts,
    this.sampleId,
    this.sampleNo,
    this.initialAxis,
    this.longAxis,
    this.shortAxis,
    this.city,
  }) : super(key: key);

  @override
  _ScreenshotImagePageState createState() => _ScreenshotImagePageState();
}

class _ScreenshotImagePageState extends State<ScreenshotImagePage> {
  Color? _selectedColor;
  List<String> _selectedFeatures = [];
  GlobalKey _globalKey = GlobalKey(); //

  // Declare global variables
  String _globalSampleId = 'N/A';
  String _globalSampleNo = 'N/A';
  String _globalInitialAxis = 'N/A';
  String _globalLongAxis = 'N/A';
  String _globalShortAxis = 'N/A';
  String _globalCity = 'N/A';

  Future<String?> _uploadImage(Uint8List imageBytes) async {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference storageRef =
          FirebaseStorage.instance.ref().child('images/$fileName');
      UploadTask uploadTask = storageRef.putData(imageBytes);
      TaskSnapshot snapshot = await uploadTask;
      String downloadURL = await snapshot.ref.getDownloadURL();
      return downloadURL;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchSampleData();
  }

  Future<void> _fetchSampleData() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('samples')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        final data = doc.data() as Map<String, dynamic>;

        setState(() {
          _globalSampleId = data['sampleId']?.toString() ?? 'N/A';
          _globalSampleNo = data['sampleNo']?.toString() ?? 'N/A';
          _globalInitialAxis = data['Initial Axis']?.toString() ?? 'N/A';
          _globalLongAxis = data['Long Axis']?.toString() ?? 'N/A';
          _globalShortAxis = data['Short Axis']?.toString() ?? 'N/A';
          _globalCity = data['city']?.toString() ?? 'N/A';
        });
      }
    } catch (e) {
      print('Error fetching sample data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple[100],
        title: Row(
          children: [
            Text('Extraction'),
            Spacer(),
            SizedBox(
              width: 120,
              height: 30,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LearnMore(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple, // Button color
                ),
                child: Text(
                  'Learn More',
                  style: TextStyle(fontSize: 12, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildSampleDisplay(),
              SizedBox(height: 20),
              RepaintBoundary(
                key: _globalKey, // Attach key to RepaintBoundary
                child: _buildImageWithDots(),
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: _buildUsedFeatureList(),
              ),
              SizedBox(height: 20),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSampleDisplay() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.purple, width: 2.0),
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: _buildSampleRow(
        sampleId: _globalSampleId,
        sampleNo: _globalSampleNo,
        initialAxis: _globalInitialAxis,
        longAxis: _globalLongAxis,
        shortAxis: _globalShortAxis,
        city: _globalCity
      ),
    );
  }

  Widget _buildSampleRow({
    required String sampleId,
    required String sampleNo,
    required String initialAxis,
    required String longAxis,
    required String shortAxis, 
    required String city,
  }) {
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

  Widget _buildImageWithDots() {
    List<MapEntry<Offset, Color>> filteredDots =
        _filteredDots(widget.dots, _selectedColor);
    return Stack(
      alignment: Alignment.center,
      children: [
        if (widget.image != null)
          Image.memory(
            widget.image!,
            height: 300,
            width: 350,
            fit: BoxFit.cover,
          ),
        ...filteredDots.map((dot) {
          return Positioned(
            left:
                dot.key.dx - 5, // Adjusting position to center dot on the point
            top:
                dot.key.dy - 5, // Adjusting position to center dot on the point
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: dot.value,
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  List<MapEntry<Offset, Color>> _filteredDots(
      List<MapEntry<Offset, Color>> dots, Color? color) {
    if (color == null) {
      return dots;
    } else {
      return dots.where((dot) => dot.value == color).toList();
    }
  }

  Widget _buildUsedFeatureList() {
    List<Color> colors = _extractColors(widget.dots);

    Map<String, int> usedFeatures = Map.fromEntries(
      widget.featureCounts.entries.where((entry) => entry.value > 0),
    );

    if (usedFeatures.isEmpty) {
      return Center(
        child: Text(
          'No used features to display.',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: usedFeatures.keys.map((feature) {
        int featureIndex = usedFeatures.keys.toList().indexOf(feature);
        Color featureColor =
            (featureIndex < colors.length) ? colors[featureIndex] : Colors.grey;

        int featureUsageCount = usedFeatures[feature]!;

        return Row(
          children: [
            Container(
              width: 15,
              height: 15,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: featureColor,
              ),
            ),
            SizedBox(width: 10),
            Text(
              '$feature ($featureUsageCount)',
              style: TextStyle(fontSize: 14),
            ),
          ],
        );
      }).toList(),
    );
  }

  List<Color> _extractColors(List<MapEntry<Offset, Color>> dots) {
    List<Color> colors = [];
    dots.forEach((dot) {
      if (!colors.contains(dot.value)) {
        colors.add(dot.value);
      }
    });
    return colors;
  }

  Future<void> _captureAndUploadImage() async {
    try {
      // Capture the widget as an image
      RenderRepaintBoundary boundary = _globalKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      var image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      // Upload the image to Firebase Storage
      String? imageUrl = await _uploadImageToFirebase(pngBytes);

      if (imageUrl != null) {
        // Store the download URL in Firestore (optional)
        await FirebaseFirestore.instance.collection('extracted_features').add({
          'image_url': imageUrl,
          'timestamp': FieldValue.serverTimestamp(),
          // Add other relevant fields if necessary
        });

        print('Image uploaded and URL stored successfully.');
      } else {
        print('Failed to upload image.');
      }
    } catch (e) {
      print('Error capturing or uploading image: $e');
    }
  }

  Future<String?> _uploadImageToFirebase(Uint8List imageBytes) async {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference storageRef =
          FirebaseStorage.instance.ref().child('images/$fileName');
      UploadTask uploadTask = storageRef.putData(imageBytes);
      TaskSnapshot snapshot = await uploadTask;

      // Get the download URL for the uploaded image
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: () {
        _submitData();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.purple,
      ),
      child: Text(
        'Submit Information',
        style: TextStyle(fontSize: 16, color: Colors.white),
      ),
    );
  }

  void _submitData() async {
    try {
      if (_globalSampleId == 'N/A' ||
          _globalSampleNo == 'N/A' ||
          _globalInitialAxis == 'N/A' ||
          _globalLongAxis == 'N/A' ||
          _globalShortAxis == 'N/A') {
        print('One or more required fields are null.');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('One or more required fields are missing.')),
        );
        return;
      }
      
      String? selectedColorHex =
          _selectedColor != null ? _colorToHex(_selectedColor!) : null;

      // Upload image to Firebase Storage and get the download URL
        RenderRepaintBoundary boundary = _globalKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      var image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      // Upload the image to Firebase Storage
      String? imageUrl = await _uploadImageToFirebase(pngBytes);

      Map<String, dynamic> data = {
        'selectedColor': selectedColorHex,
        'featureCounts': widget.featureCounts,
        'timestamp': FieldValue.serverTimestamp(),
        'sampleId': _globalSampleId,
        'sampleNumber': _globalSampleNo,
        'xAxis': _globalInitialAxis,
        'yAxis': _globalLongAxis,
        'zAxis': _globalShortAxis,
        'city' : _globalCity,
        'imageUrl': imageUrl, // Store the image URL
      };

      print('Submitting data: $data');

      await FirebaseFirestore.instance
          .collection('extracted_features')
          .add(data);

      setState(() {
        _selectedColor = null;
        _selectedFeatures.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Information submitted to Firebase and cleared successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting information: $e')),
      );
    }
  }

  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).padLeft(8, '0').toUpperCase()}';
  }
}
