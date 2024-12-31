import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:iBIT/HomePage.dart';
import 'package:iBIT/uploadimage.dart';

class DrawScreen extends StatefulWidget {
  final Uint8List? image;

  DrawScreen({Key? key, required this.image}) : super(key: key);

  @override
  _DrawScreenState createState() => _DrawScreenState(image: image);
}

class _DrawScreenState extends State<DrawScreen> {
  final Uint8List? image;
  List<Offset?> points = [];
  Offset? startPoint;
  bool isDrawing = false;
  double pixelsToMicrometers = 1.0; // Initial conversion factor

  _DrawScreenState({required this.image});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async{
        Navigator.pop(context);
        // Navigator.pushReplacement(
        //   context,
        //   MaterialPageRoute(builder: (context) => uploadimage()),
        // );
        return false;
      },
      child: Scaffold(
          body: Stack(
            children: [
              if (image != null)
                Center(
                  child: Image.memory(
                    image!,
                    width: 350,
                    height: 300,
                    fit: BoxFit.cover,
                  ),
                ),
              GestureDetector(
                onPanStart: (details) {
                  if (isDrawing) {
                    RenderBox renderBox = context.findRenderObject() as RenderBox;
                    startPoint = renderBox.globalToLocal(details.globalPosition);
                  }
                },
                onPanUpdate: (details) {
                  if (isDrawing) {
                    RenderBox renderBox = context.findRenderObject() as RenderBox;
                    Offset currentPoint = renderBox.globalToLocal(details.globalPosition);
                    if (startPoint != null) {
                      double distance = (currentPoint - startPoint!).distance;
                      if (distance >= 20.0) {
                        setState(() {
                          points.clear();
                          points.add(startPoint);
                          points.add(currentPoint);
                        });
                      }
                    }
                  }
                },
                onPanEnd: (details) {
                  if (isDrawing) {
                    setState(() {
                      startPoint = null;
                    });
                  }
                },
                child: CustomPaint(
                  painter: LinePainter(points: points),
                  size: Size.infinite,
                ),
              ),
              if (points.length == 2 && points[0] != null && points[1] != null)
                Positioned(
                  top: (points[0]!.dy + points[1]!.dy) / 2 + 20,
                  left: (points[0]!.dx + points[1]!.dx) / 2 - 50,
                  child: Text(
                    '${calculateLength(points).toStringAsFixed(2)} μm',
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ),
              Positioned(
                top: 40,
                left: 20,
                child: IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () {
                    Navigator.pop(context); // Go back to the previous screen
                  },
                ),
              ),
              Positioned(
                bottom: 20,
                right: 20,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: Icon(isDrawing ? Icons.brush : Icons.brush_outlined),
                      onPressed: () {
                        setState(() {
                          isDrawing = !isDrawing;
                          points.clear();
                        });
                      },
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AdjustConversionFactorDialog(
                            initialValue: pixelsToMicrometers,
                            onValueChanged: (value) {
                              setState(() {
                                pixelsToMicrometers = value;
                              });
                            },
                          ),
                        );
                      },
                      child: Text('Adjust Conversion'),
                    ),
                  ],
                ),
              ),
            ],
          ),
      ),
    );
  }

  double calculateLength(List<Offset?> points) {
    if (points.length != 2 || points[0] == null || points[1] == null) {
      return 0.0;
    }
    double pixelDistance = (points[0]! - points[1]!).distance;
    return pixelDistance / pixelsToMicrometers;
  }
}

class LinePainter extends CustomPainter {
  List<Offset?> points;

  LinePainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    if (points.length == 2 && points[0] != null && points[1] != null) {
      canvas.drawLine(points[0]!, points[1]!, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class AdjustConversionFactorDialog extends StatefulWidget {
  final double initialValue;
  final ValueChanged<double> onValueChanged;

  AdjustConversionFactorDialog({
    required this.initialValue,
    required this.onValueChanged,
  });

  @override
  _AdjustConversionFactorDialogState createState() =>
      _AdjustConversionFactorDialogState();
}

class _AdjustConversionFactorDialogState
    extends State<AdjustConversionFactorDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.initialValue.toString(),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Adjust Conversion Factor'),
      content: TextField(
        controller: _controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          hintText: 'Enter conversion factor',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            double value = double.tryParse(_controller.text) ?? 0.0;
            widget.onValueChanged(value);
            Navigator.pop(context);
          },
          child: Text('Apply'),
        ),
      ],
    );
  }
}