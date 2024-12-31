import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/scheduler.dart';
import 'package:iBIT/Details_collection.dart';
import 'package:iBIT/sample_list.dart';
import 'package:iBIT/uploadimage.dart';
import 'SplashScreen.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    _initializeFirebase();

    // Schedule a post-frame callback
    SchedulerBinding.instance.addPostFrameCallback((_) {
      // Perform actions here that need to happen after the first frame is rendered
    });
  }

  Future<void> _initializeFirebase() async {
    try {
      await Firebase.initializeApp();
    } catch (e) {
      print('Firebase initialization error: $e');
      // Optionally handle initialization error, e.g., show a dialog or retry.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            // Uncomment these lines if needed
            child: DetailsCollection(),
          ),
          
          Expanded(
            child: uploadimage(),
          ),
        ],
      ),
    );
  }


  // Future<bool> _onWillPop() async {
  //   bool exit = await showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: Text('Confirm Exit'),
  //         content: Text('Are you sure you want to quit?'),
  //         actions: <Widget>[
  //           TextButton(
  //             onPressed: () {
  //               Navigator.of(context).pop(false); // Return false to prevent exiting
  //             },
  //             child: Text('No'),
  //           ),
  //           TextButton(
  //             onPressed: () {
  //               Navigator.of(context).pop(true); // Return true to allow exiting
  //             },
  //             child: Text('Yes'),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  //   return exit;
  // }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text('iBIT'),
      actions: [
        IconButton(
          onPressed: () {
            Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SampleListPage(
                          
                        ),
                      ),
                    );
          },
          icon: Icon(Icons.account_circle),
        ),
      ],
    );
  }
}
