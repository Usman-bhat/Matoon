import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

// Import the screen files
import 'package:myapp/screens/home_screen.dart';
import 'package:myapp/screens/settings_screen.dart';
import 'package:myapp/screens/profile_screen.dart';

// Import the generated file
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  WidgetsFlutterBinding.ensureInitialized();
  print("[DEBUG] Initializing Firebase...");
  try {
    await Firebase.initializeApp(
      // Use the default options for the current platform.
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("[DEBUG] Firebase initialized successfully.");
    runApp(const MyApp());
  } catch (e) {
    // Handle Firebase initialization error (e.g., show an error message)
    print('Error initializing Firebase: $e');
    // Optionally run an error app: runApp(ErrorApp(errorMessage: e.toString()));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print("[DEBUG] Building MyApp widget...");
    return MaterialApp(
      title: 'Mathoon App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0; // Track the selected tab index

  // List of widgets to display for each tab
  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    SettingsScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
     print("[DEBUG] Building MyHomePage scaffold with index: $_selectedIndex");
    return Scaffold(
      // The body will now display the widget based on the selected index
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      // Add the BottomNavigationBar
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800], // Customize color
        onTap: _onItemTapped, // Function called when a tab is tapped
      ),
    );
  }
}