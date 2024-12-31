
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:iBIT/Drawing_pan.dart';
import 'package:iBIT/screenshot.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:screenshot/screenshot.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:iBIT/Details_collection.dart';



class uploadimage extends StatefulWidget {
    
  
 
  @override
  State<uploadimage> createState() => _uploadimageState();
}

class _uploadimageState extends State<uploadimage> {
   

  bool _featureCountsInitialized = false;
  double _sliderValue = 1.0;
  List<MapEntry<Offset, Color>> _dots = [];
  Map<String, int> _featureCounts = {}; 
  Uint8List? _image;
  late Size _originalSize;
  Offset _offset = Offset.zero;
  // late Map<String, int> _featureCounts;
  bool _showNotification = false;
  Offset _notificationOffset = Offset.zero;
  List<MapEntry<Offset, Color>> _removedDots = [];


  ScreenshotController screenshotController = ScreenshotController();

  void _handleImageSelected(Uint8List? image) {
    setState(() {
      _image = image;
    });
  }

  Map<String, List<Offset>> _Features = {
    'Angular Outline': [],
    'Subangular Outline': [],
    'Rounded Outline': [],
    'Small Conchoidal Fractures(<10um)': [],
    'Medium Conchoidal Fractures(<100)': [],
    'Large Conchoidal Fractures(>100um)': [],
    'Arcuate Steps': [],
    'Straight Steps': [],
    'Meandering Ridges': [],
    'Flat Cleavage Surface': [],
    'Graded Arcs': [],
    'V-Shaped percussion cracks': [],
    'Straight/Curved Grooves/Scratches': [],
    'Upturned Plates': [],
    'Crescentic Percussion Marks': [],
    'Bulbous edges': [],
    'Abrasion Fatigue': [],
    'Parallel Striations': [],
    'Imbricated Grinding Features': [],
    'Oriented Etch Pits': [],
    'Solution Pits': [],
    'Solution Crevasses': [],
    'Scaling': [],
    'Silica Globules': [],
    'Silica Flowers': [],
    'Crystalline Overgrowths': [],
    'Low Relief': [],
    'Medium Relief': [],
    'High Relief': [],
    'Elongated Depressions': [],
    'Chattermarks': [],
    'Adhering Particles': [],
    'Arcuate/Circular/Ploygonal Cracks': [],
  };
  String _selectedVal = "Angular Outline";
  String get selectedVal => _selectedVal;


  Map<String, Color> _dotColors = {
    'Angular Outline': Color(0xFFFFAFCC),
    'Subangular Outline': Color(0xFFFF0000),
    'Rounded Outline': Color(0xFF0000FF),
    'Small Conchoidal Fractures(<10um)':Color(0xFF00FF00),
    'Medium Conchoidal Fractures(<100)': Color(0xFFFFA500),
    'Large Conchoidal Fractures(>100um)': Color(0xFF800080),
    'Arcuate Steps': Color(0xFFFF4500),
    'Straight Steps': Color(0xFFFFD700),
    'Meandering Ridges': Color(0xFF4B0082),
    'Flat Cleavage Surface': Color(0xFF708090),
    'Graded Arcs':Color(0xFF6A5ACD),
    'V-Shaped percussion cracks':  Color(0xFFA9A9A9),
    'Straight/Curved Grooves/Scratches':Color(0xFFADFF2F),
    'Upturned Plates': Color(0xFF00CED1),
    'Crescentic Percussion Marks': Color(0xFFDE3163),
    'Bulbous edges': Color(0xFF7FFFD4),
    'Abrasion Fatigue':Color(0xFFFF7F50),
    'Parallel Striations': Color(0xFFFA8072),
    'Imbricated Grinding Features': Color(0xFF8B0000),
    'Oriented Etch Pits': Color(0xFFA0522D),
    'Solution Pits': Color(0xFF6B8E23),
    'Solution Crevasses': Color(0xFF8B4513),
    'Scaling':Color(0xFF000080),
    'Silica Globules': Color(0xFFBDB76B),
    'Silica Flowers':  Color(0xFFDC143C),
    'Crystalline Overgrowths': Color(0xFF283618),
    'Low Relief': Color(0xFFA9DEF9),
    'Medium Relief': Color(0xFF6D6875),
    'High Relief': Color(0xFF081C15),
    'Elongated Depressions': Color(0xFFBC3908),
    'Chattermarks': Color(0xFF450920),
    'Adhering Particles': Colors.white,
    'Arcuate/Circular/Ploygonal Cracks':  Color(0xFF001427),
  };
  @override
  void initState() {
    super.initState();
    _initializeFeatureCounts(); // Initialize feature counts map
  }
  void _initializeFeatureCounts() {
    // Initialize feature counts map with counts initialized to 0 for each feature
    _featureCounts = Map.fromIterable(_Features.keys, value: (_) => 0);
    _featureCountsInitialized = true;
  }
  


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTapDown: _image == null ? null : (TapDownDetails details) {
                if (_sliderValue != 1.0) {
                  setState(() {
                    _showNotification = true;
                    _notificationOffset = details.localPosition;
                  });
                  Future.delayed(Duration(seconds: 3), () {
                    setState(() {
                      _showNotification = false;
                    });
                  });
                  return;
                }
                setState(() {
                  final scaledPosition = (details.localPosition - _offset) / _sliderValue;
                  final dotColor = _dotColors[_selectedVal] ?? Colors.black;
                  _dots.add(MapEntry(scaledPosition, dotColor));
                  _Features[_selectedVal]!.add(scaledPosition);
                  _updateItemCounts();
                });
              },

              onPanUpdate: (details) {
                setState(() {
                  _offset += details.delta;
                });
              },
              child: Stack(
                children: [
                  Container(
                    width: 350,
                    height: 300,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.purple[100],
                    ),
                    child: ClipRect(
                      child: Transform.translate(
                        offset: _offset,
                        child: Transform.scale(
                          scale: _sliderValue,
                          child: Stack(
                            children: [
                              _image == null
                                  ? Center(
                                child: Text(
                                  'No image selected',
                                  style: TextStyle(
                                    fontSize: 20,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              )
                                  : Image.memory(
                                _image!,
                                height: 300,
                                width: 350,
                                fit: BoxFit.fill,
                                alignment: Alignment.center,
                              ),
                              CustomPaint(
                                size: Size(350, 300),
                                painter: DotPainter(_dots),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (_showNotification) // Show the notification when _showNotification is true
                    Positioned(
                      left: _notificationOffset.dx,
                      top: _notificationOffset.dy,
                      child: Container(
                        padding: EdgeInsets.all(10),
                        color: Colors.black.withOpacity(0.7),
                        child: Text(
                          'Get to 1 to place Dots',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                ],
              ),
            ),








            SizedBox(height: 3),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Align children to the start and end of the row
              children: [
                Column(
                  children: [
                    Slider(
                      value: _sliderValue,
                      min: 0.5,
                      max: 2.0,
                      divisions: 30,
                      label: _sliderValue.toStringAsFixed(2),
                      onChanged: (double value) {
                        setState(() {
                          _sliderValue = value;
                        });
                        _updateItemCounts(); // Update counts when slider value changes
                      },
                    ),
                    Text(
                      'Place dots at 1 index',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                IconButton(
                  onPressed: () {
                    if (_dots.isNotEmpty) {
                      setState(() {
                        final removedDot = _dots.removeLast();
                        _removedDots.add(removedDot);
                        _updateItemCounts(); // Update counts after removing dot
                      });
                    }
                  },
                  icon: Icon(Icons.undo_sharp),
                ),
                IconButton(
                  onPressed: () {
                    if (_removedDots.isNotEmpty) {
                      setState(() {
                        final addedDot = _removedDots.removeLast();
                        _dots.add(addedDot);
                        _updateItemCounts(); // Update counts after adding dot back
                      });
                    }
                  },
                  icon: Icon(Icons.redo_sharp),
                ),

                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DrawScreen(image: _image),
                      ),
                    );
                  },
                  icon: Icon(Icons.brush_outlined),
                ),


                // IconButton(
                //   onPressed: () {
                //     setState(() {
                //       _offset = Offset.zero;
                //       _sliderValue = 1.0;
                //     });
                //   },
                //   icon: Icon(Icons.refresh),
                // ),



              ],
            ),


            SizedBox(height: 5),
            Row(
              children: [
                SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    _uploadImage(ImageSource.gallery);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple[600],
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.upload, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Upload',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                SizedBox(width:8),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ScreenshotImagePage(
                          image: _image,
                          dots: _dots,
                          featureCounts: _featureCounts,

                          // Pass the feature counts here
                        ),
                      ),
                    );

                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple[600],
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.more, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'More',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),


                SizedBox(width: 8),
               
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Colors.purple,
              width: 3.0,
            ),
          ),
        ),
        // Container for the bottom navigation bar
        padding: EdgeInsets.only(bottom: 30, left: 35), // Padding for bottom navigation bar
        child: Row(
          children: [
            Expanded(
              // Expanded widget to make dropdown full width
              child: DropdownButton<String>(
  value: _selectedVal,
  isExpanded: true,
  items: _featureCounts == null ? [] : _Features.keys.map((String value) {
    return DropdownMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Container(
            width: 10, 
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _dotColors[value], 
            ),
            margin: EdgeInsets.only(right: 8),
          ),
          Text('$value (${_featureCounts[value] ?? 0})', style: TextStyle(fontSize: 14)),
        ],
      ),
    );
  }).toList(),
  onChanged: (String? newValue) {
    setState(() {
      _selectedVal = newValue!;
      _updateItemCounts(); // Update counts
    });
  },
),

            ),
            SizedBox(width: 20), // SizedBox for spacing
          ],
        ),
      ),

    );
  }

  void _uploadImage(ImageSource source) async {
    final XFile? imageFile = await ImagePicker().pickImage(source: source); // Select image from gallery
    if (imageFile != null) {
      final Uint8List img = await imageFile.readAsBytes(); // Read image bytes

      // Clear existing dots and features
      _dots.clear();
      _Features.values.forEach((list) => list.clear());

      // Get the original size of the image
      final image = await decodeImageFromList(img);
      setState(() {
        _image = img; // Update image bytes with the newly selected image
        _originalSize = Size(image.width.toDouble(), image.height.toDouble());
        _sliderValue = 1.0;
        _offset = Offset.zero;
        _updateItemCounts(); // Initialize feature counts after image upload
      });
    }
  }



 void _updateItemCounts() {
  if (!_featureCountsInitialized) return; // Ensure _featureCounts is initialized
  
  // Clear counts for all features
  _featureCounts.forEach((key, value) {
    _featureCounts[key] = 0;
  });

  // Update counts based on current dots
  for (var dot in _dots) {
    for (var key in _Features.keys) {
      if (_Features[key]!.contains(dot.key)) {
        _featureCounts[key] = (_featureCounts[key] ?? 0) + 1;
      }
    }
  }
}










  void _saveSampleDetails() async {
  if (_image == null) return;

  try {
    // Ensure user is authenticated
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      await FirebaseAuth.instance.signInAnonymously();
    }

    // Generate a unique ID using current time in milliseconds
    String uniqueId = DateTime.now().millisecondsSinceEpoch.toString();

    // Upload image to Firebase Storage
    String imagePath = 'sample_images/$uniqueId.png';
    Reference storageRef = FirebaseStorage.instance.ref().child(imagePath);
    UploadTask uploadTask = storageRef.putData(_image!);

    // Wait for the upload to complete and get the download URL
    TaskSnapshot snapshot = await uploadTask;
    String downloadURL = await snapshot.ref.getDownloadURL();

    // Save the download URL and feature counts to Firestore
    await FirebaseFirestore.instance.collection('sample_details').doc(uniqueId).set({
      'features': _Features.map((key, value) => MapEntry(key, value.length)),
      'image_url': downloadURL,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Show a success message
    _showSuccessMessage();
  } catch (e) {
    // Handle error by not showing any immediate error message
    print('Error saving data to Firestore: $e');
  }
}

void _showSuccessMessage() {
  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return Container(
        padding: EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 10),
            Text('Data and image saved successfully!'),
          ],
        ),
      );
    },
  );
}

void _showErrorMessage(dynamic e) {
  print('Error saving data to Firestore: $e');
  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return Container(
        padding: EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, color: Colors.red),
            SizedBox(width: 10),
            Text('Failed to save data. Please try again.'),
          ],
        ),
      );
    },
  );
}
}

class DotPainter extends CustomPainter {
  final List<MapEntry<Offset, Color>> dots;

  DotPainter(this.dots);

  @override
  void paint(Canvas canvas, Size size) {
    for (var dot in dots) {
      final Paint paint = Paint()..color = dot.value; // Set paint color
      canvas.drawCircle(dot.key * size.width / 350, 5, paint); // Draw circle with color
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
