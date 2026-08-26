import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'presentation/screens/sleep_tracker/sleep_tracker_screen.dart';
import 'presentation/screens/step_tracker/step_tracker_screen.dart';
import 'presentation/screens/heart_rate/heart_rate_screen.dart';
import 'services/sleep_tracker_service.dart';
import 'services/step_tracker_service.dart';
import 'services/heart_rate_service.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    switch (task) {
      case 'trackSleep':
        await SleepTrackerService().trackSleepInBackground();
        break;
      case 'trackSteps':
        await StepTrackerService().startStepTracking();
        break;
    }
    return Future.value(true);
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: false,
  );
  
  await Workmanager().registerPeriodicTask(
    'trackSleep',
    'trackSleep',
    frequency: const Duration(hours: 1),
  );
  
  await Workmanager().registerPeriodicTask(
    'trackSteps',
    'trackSteps',
    frequency: const Duration(minutes: 30),
  );
  
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  
  const DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings();
  
  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );
  
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  
  await Permission.microphone.request();
  await Permission.sensors.request();
  await Permission.storage.request();
  await Permission.activityRecognition.request();
  await Permission.camera.request();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sehatak',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Cairo',
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    StepTrackerScreen(),
    SleepTrackerScreen(),
    HeartRateScreen(),
  ];

  final List<Map<String, dynamic>> _items = [
    {'title': '🚶 خطوات', 'icon': Icons.directions_walk, 'color': Colors.blue},
    {'title': '🛌 نوم', 'icon': Icons.bedtime, 'color': Colors.indigo},
    {'title': '🫀 نبضات', 'icon': Icons.favorite, 'color': Colors.red},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: _items.map((item) {
          return BottomNavigationBarItem(
            icon: Icon(item['icon']),
            label: item['title'],
          );
        }).toList(),
        selectedItemColor: _items[_selectedIndex]['color'],
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
