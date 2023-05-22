import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:torch_light/torch_light.dart';
import 'package:shake/shake.dart';
import 'package:flutter_background_service/flutter_background_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  initBackgroundService();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Shake Light',
      debugShowCheckedModeBanner: false,
      home: SwitchScreen(),
    );
  }
}

void initBackgroundService() async {
  final service = FlutterBackgroundService();

  // const AndroidNotificationChannel channel = AndroidNotificationChannel(
  //   'my_foreground', // id
  //   'MY FOREGROUND SERVICE', // title
  //   description:
  //       'This channel is used for important notifications.', // description
  //   importance: Importance.low, // importance must be at low or higher level
  // );

  await service.configure(
    iosConfiguration: IosConfiguration(
      autoStart: false,
      onForeground: onStart,
    ),
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      isForegroundMode: false,
      autoStart: false,
      notificationChannelId: 'my_foreground',
      initialNotificationTitle: 'Shake Light',
      initialNotificationContent: 'Initializing',
      foregroundServiceNotificationId: 888,
    ),
  );
  service.startService();
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) {
  WidgetsFlutterBinding.ensureInitialized();
  bool lightOn = false;
  late ShakeDetector detector;

  Future<void> enableTorch() async {
    try {
      await TorchLight.enableTorch();
      lightOn = true;
    } on Exception catch (e) {
      print(e);
      // _showMessage('Could not enable torch', context);
    }
  }

  Future<void> disableTorch() async {
    try {
      await TorchLight.disableTorch();
      lightOn = false;
    } on Exception catch (e) {
      print(e);
      // _showMessage('Could not disable torch', context);
    }
  }

  Future<bool> isTorchAvailable() async {
    try {
      detector = ShakeDetector.waitForStart(
          onPhoneShake: () {
            if (!lightOn) {
              enableTorch();
            } else if (lightOn) {
              disableTorch();
            }
          },
          minimumShakeCount: 2);
      detector.startListening();
      return await TorchLight.isTorchAvailable();
    } on Exception catch (e) {
      Map<String, String> torchError = {'Torch Error': '$e'};
      service.invoke('torchError', torchError);
      // _showMessage(
      //   'Could not check if the device has an available torch',
      //   context,
      // );
      rethrow;
    }
  }

  service.on('startService').listen((event) async {
    try {
      isTorchAvailable();
    } catch (e) {
      print(e);
    }
    // if (await isTorchAvailable()) {
    //   // detector.startListening();
    //   // enableTorch();
    //   print('listening for shakes');
    // }
  });

  service.on('stopService').listen((event) {
    // detector.stopListening();
    // disableTorch();
    print('service stopped');
  });
}

class SwitchScreen extends StatefulWidget {
  const SwitchScreen({super.key});

  @override
  State<SwitchScreen> createState() => _SwitchScreenState();
}

class _SwitchScreenState extends State<SwitchScreen> {
  bool shakeLightActive = false;
  final service = FlutterBackgroundService();

  void _showMessage(String message, BuildContext context) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void initState() {
    super.initState();
    FlutterBackgroundService().on('torchError').listen((event) {
      print(event);
      // _showMessage('$event', context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shake Light'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Activate Shake Light',
            style: TextStyle(
              color: Colors.black,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(
            height: 6,
          ),
          Center(
            child: Switch(
              value: shakeLightActive,
              onChanged: (bool value) async {
                if (!shakeLightActive) {
                  setState(() {
                    service.invoke('startService');
                    shakeLightActive = value;
                  });
                } else if (shakeLightActive) {
                  setState(() {
                    service.invoke('stopService');
                    shakeLightActive = value;
                  });
                }
              },
            ),
          )
        ],
      ),
    );
  }
}
