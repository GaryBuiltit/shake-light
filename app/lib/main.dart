import 'package:flutter/material.dart';
import 'package:torch_light/torch_light.dart';
import 'package:shake/shake.dart';
import 'package:flutter_background/flutter_background.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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

// void initBackgroundService() async {
//   final service = FlutterBackgroundService();

//   // const AndroidNotificationChannel channel = AndroidNotificationChannel(
//   //   'my_foreground', // id
//   //   'MY FOREGROUND SERVICE', // title
//   //   description:
//   //       'This channel is used for important notifications.', // description
//   //   importance: Importance.low, // importance must be at low or higher level
//   // );

//   await service.configure(
//     iosConfiguration: IosConfiguration(
//       autoStart: false,
//       onForeground: onStart,
//     ),
//     androidConfiguration: AndroidConfiguration(
//       onStart: onStart,
//       isForegroundMode: false,
//       autoStart: false,
//       notificationChannelId: 'my_foreground',
//       initialNotificationTitle: 'Shake Light',
//       initialNotificationContent: 'Initializing',
//       foregroundServiceNotificationId: 888,
//     ),
//   );
//   if (await service.isRunning() == false) {
//     try {
//       service.startService();
//     } on Exception catch (e) {
//       print(e);
//     }
//   }
// }

// @pragma('vm:entry-point')
// void onStart(ServiceInstance service) {
//   WidgetsFlutterBinding.ensureInitialized();
//   bool lightOn = false;
//   late ShakeDetector detector;

//   Future<void> enableTorch() async {
//     try {
//       await TorchLight.enableTorch();
//       lightOn = true;
//     } on Exception catch (e) {
//       print(e);
//       // _showMessage('Could not enable torch', context);
//     }
//   }

//   Future<void> disableTorch() async {
//     try {
//       await TorchLight.disableTorch();
//       lightOn = false;
//     } on Exception catch (e) {
//       print(e);
//       // _showMessage('Could not disable torch', context);
//     }
//   }

//   Future<bool> isTorchAvailable() async {
//     try {
//       detector = ShakeDetector.waitForStart(
//           onPhoneShake: () {
//             if (!lightOn) {
//               enableTorch();
//             } else if (lightOn) {
//               disableTorch();
//             }
//           },
//           minimumShakeCount: 2);
//       detector.startListening();
//       return await TorchLight.isTorchAvailable();
//     } on Exception catch (e) {
//       Map<String, String> torchError = {'Torch Error': '$e'};
//       service.invoke('torchError', torchError);
//       // _showMessage(
//       //   'Could not check if the device has an available torch',
//       //   context,
//       // );
//       rethrow;
//     }
//   }

//   service.on('startService').listen((event) async {
//     try {
//       isTorchAvailable();
//     } catch (e) {
//       print(e);
//     }
//     // if (await isTorchAvailable()) {
//     //   // detector.startListening();
//     //   // enableTorch();
//     //   print('listening for shakes');
//     // }
//   });

//   service.on('stopService').listen((event) {
//     service.stopSelf;
//     // detector.stopListening();
//     // disableTorch();
//     print('service stopped');
//   });
// }

class SwitchScreen extends StatefulWidget {
  const SwitchScreen({super.key});

  @override
  State<SwitchScreen> createState() => _SwitchScreenState();
}

class _SwitchScreenState extends State<SwitchScreen> {
  bool shakeLightActive = false;
  // final service = FlutterBackgroundService();

  // void _showMessage(String message, BuildContext context) {
  //   ScaffoldMessenger.of(context)
  //       .showSnackBar(SnackBar(content: Text(message)));
  // }

  // @override
  // void initState() {
  //   super.initState();
  //   initBackgroundService();
  //   FlutterBackgroundService().on('torchError').listen((event) {
  //     print(event);
  //     // _showMessage('$event', context);
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shake Light'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Image.asset(
          //   'app/images/shake-light-Icon.png',
          //   height: 100,
          //   width: 100,
          // ),
          const SizedBox(
            height: 10,
          ),
          Text(
            !shakeLightActive
                ? 'Activate Shake Light'
                : 'Deactivate Shake Light',
            style: const TextStyle(
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
                    BackgroundSevices().startBackground();
                    // service.invoke('startService');
                    shakeLightActive = value;
                  });
                } else if (shakeLightActive) {
                  setState(() {
                    BackgroundSevices().stopBackground();
                    // service.invoke('stopService');
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

class BackgroundSevices {
  bool lightOn = false;

  FlutterBackgroundAndroidConfig androidConfig =
      const FlutterBackgroundAndroidConfig(
    notificationTitle: "Shake Light",
    notificationText: "Shake Light is running in the background",
    notificationImportance: AndroidNotificationImportance.Default,
    notificationIcon: AndroidResource(
        name: 'background_icon',
        defType: 'drawable'), // Default is ic_launcher from folder mipmap
  );

  late ShakeDetector detector = ShakeDetector.waitForStart(
      onPhoneShake: () {
        if (!lightOn) {
          enableTorch();
        } else if (lightOn) {
          disableTorch();
        }
      },
      minimumShakeCount: 1);

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
      // detector = ShakeDetector.waitForStart(
      //     onPhoneShake: () {
      //       if (!lightOn) {
      //         enableTorch();
      //       } else if (lightOn) {
      //         disableTorch();
      //       }
      //     },
      //     minimumShakeCount: 4);
      detector.startListening();
      return await TorchLight.isTorchAvailable();
    } on Exception catch (e) {
      print(e);
      // Map<String, String> torchError = {'Torch Error': '$e'};
      // _showMessage(
      //   'Could not check if the device has an available torch',
      //   context,
      // );
      rethrow;
    }
  }

  startBackground() async {
    var hasPermissions =
        await FlutterBackground.initialize(androidConfig: androidConfig);

    if (hasPermissions) {
      final backgroundExecution =
          await FlutterBackground.enableBackgroundExecution();

      if (backgroundExecution) {
        isTorchAvailable();
      }
    }
  }

  stopBackground() async {
    var backgroundRunning = FlutterBackground.isBackgroundExecutionEnabled;

    if (backgroundRunning) {
      try {
        detector.stopListening();
        var initilized =
            await FlutterBackground.initialize(androidConfig: androidConfig);
        if (initilized) {
          await FlutterBackground.disableBackgroundExecution();
        }
      } catch (e) {
        print(e);
      }
    }
  }
}
