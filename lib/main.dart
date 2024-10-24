import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'dart:math';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FenLights',
      theme: ThemeData.dark().copyWith(
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.black54,
          titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('FenLights')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Welcome to FenLights', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LEDControlPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                child: Text('Control LED Lights', style: TextStyle(fontSize: 18)),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  // Placeholder for future implementation for underglow and animation
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                child: Text('Control Underglow & Animation', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LEDControlPage extends StatefulWidget {
  @override
  _LEDControlPageState createState() => _LEDControlPageState();
}

class _LEDControlPageState extends State<LEDControlPage> {
  List<Color> headlightColors = List.filled(50, Colors.white);
  List<List<Color>> animationFrames = [];
  int frameDelay = 1; // Delay in seconds
  bool isAnimating = false;

  void pickColor(int index) {
    Color initialColor = headlightColors[index];
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Pick a color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: initialColor,
              onColorChanged: (color) {
                setState(() {
                  headlightColors[index] = color;
                });
                Navigator.of(context).pop();
              },
            ),
          ),
        );
      },
    );
  }

  void saveFrame() {
    setState(() {
      animationFrames.add(List.from(headlightColors));
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Frame saved!')));
  }

  void playAnimation() async {
    if (animationFrames.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No frames to play!')));
      return;
    }

    setState(() {
      isAnimating = true;
    });

    for (int i = 0; i < animationFrames.length; i++) {
      setState(() {
        headlightColors = animationFrames[i];
      });
      await Future.delayed(Duration(seconds: frameDelay));
    }

    setState(() {
      isAnimating = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('LED Control')),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {
                  // Placeholder for connect lights function
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                child: Text('Connect your lights'),
              ),
            ),
            TabBar(
              tabs: [
                Tab(text: 'Headlights'),
                Tab(text: 'Animation'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  // Headlights tab
                  SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text('Headlights', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                          Container(
                            height: 200,
                            child: CustomPaint(
                              painter: LEDRingPainter(headlightColors),
                            ),
                          ),
                          SizedBox(height: 20),
                          Wrap(
                            spacing: 15, // Increased spacing
                            runSpacing: 15, // Increased run spacing
                            alignment: WrapAlignment.center,
                            children: List.generate(50, (index) {
                              return GestureDetector(
                                onTap: () => pickColor(index),
                                child: Container(
                                  width: 30, // Adjusted size for clarity
                                  height: 30, // Adjusted size for clarity
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: headlightColors[index],
                                    border: Border.all(color: Colors.grey),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Animation tab
                  SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text('Animation', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                          TextField(
                            decoration: InputDecoration(
                              labelText: 'Frame Delay (seconds)',
                              border: OutlineInputBorder(),
                              fillColor: Colors.grey[900],
                              filled: true,
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              frameDelay = int.tryParse(value) ?? 1;
                            },
                          ),
                          SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: saveFrame,
                            child: Text('Save Current Frame', style: TextStyle(fontSize: 18)),
                          ),
                          SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: playAnimation,
                            child: Text(isAnimating ? 'Stop Animation' : 'Play Animation', style: TextStyle(fontSize: 18)),
                          ),
                          SizedBox(height: 20),
                          Text('Saved Frames:', style: TextStyle(fontSize: 20)),
                          SizedBox(height: 10),
                          Wrap(
                            spacing: 15, // Increased spacing
                            runSpacing: 15, // Increased run spacing
                            alignment: WrapAlignment.center,
                            children: List.generate(animationFrames.length, (index) {
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    headlightColors = animationFrames[index];
                                  });
                                },
                                child: Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: animationFrames[index][0], // Display the first LED's color
                                    border: Border.all(color: Colors.grey),
                                  ),
                                ),
                              );
                            }),
                          ),
                          SizedBox(height: 20),
                          Container(
                            height: 200,
                            child: CustomPaint(
                              painter: LEDRingPainter(headlightColors),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LEDRingPainter extends CustomPainter {
  final List<Color> colors;

  LEDRingPainter(this.colors);

  @override
  void paint(Canvas canvas, Size size) {
    double radius = size.height / 2;
    double angle = 2 * pi / colors.length;
    double outerRadius = radius - 20; // Adjusted to give more spacing
    double ledRadius = 5; // Radius of each LED circle, ensuring no overlap

    for (int i = 0; i < colors.length; i++) {
      final paint = Paint()..color = colors[i].withOpacity(1.0);
      double startAngle = angle * i - (pi / 2);

      // Draw non-intersecting circles
      canvas.drawCircle(
        Offset(radius + outerRadius * cos(startAngle), radius + outerRadius * sin(startAngle)),
        ledRadius, // Use defined ledRadius
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
