import 'dart:ui';
import 'package:flutter/material.dart';
import 'main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class launchscreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
            debugShowCheckedModeBanner: false,
      title: 'Tree Saving Game',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: SwipeableScreens(),
    );
  }
}

class SwipeableScreens extends StatefulWidget {
  @override
  _SwipeableScreensState createState() => _SwipeableScreensState();
}

class _SwipeableScreensState extends State<SwipeableScreens> {
  final controller = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: controller,
        children: [
          buildPage(Icons.nature, 'Tree Saving', 'Our application is dedicated to saving trees. We donate 100% of our earnings to causes that protect and plant trees.', Colors.green),
          buildPage(Icons.cancel, 'Plant Trees', 'Did you know? One human is equivalent to planting 10 trees annually. By using this app, you contribute to this goal.', Colors.red),
          buildPage(Icons.gamepad, 'Play & Save', 'Engage in our game and contribute to saving trees! Every game you play helps us plant more trees.', Colors.blue, true),
        ],
      ),
    );
  }

  Widget buildPage(IconData icon, String title, String text, Color color, [bool isLastPage = false]) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color.withOpacity(0.6), color],
            ),
          ),
          child: Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(
                  width: 300,
                  height: 400,
                  padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, size: 100, color: Colors.white),
                      SizedBox(height: 20),
                      Text(
                        title,
                        style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      SizedBox(height: 20),
                      Text(
                        text,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 24, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        if (isLastPage)
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.white,
                  onPrimary: color,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () async {
                // Get an instance of SharedPreferences
                SharedPreferences prefs = await SharedPreferences.getInstance();

                // Set 'firstLaunch' to false
                await prefs.setBool('firstLaunch', false);

                // Navigate to the home screen
                Navigator.push(
                 context, 
                 MaterialPageRoute(builder: (context) => MergeGameApp()),
                );
              },

                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  child: Text('Go to the app', style: TextStyle(fontSize: 20)),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
