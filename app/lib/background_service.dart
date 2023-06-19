import 'package:flutter/material.dart';
import 'package:flutter_background/flutter_background.dart';
import 'package:shake/shake.dart';
import 'package:torch_light/torch_light.dart';

class BackgroundSevices extends ChangeNotifier {
  bool lightOn = false;
  double sensitivity = 2.7;

  updateSensitivity(newValue) {
    sensitivity = newValue;
    notifyListeners();
  }

  FlutterBackgroundAndroidConfig androidConfig =
      const FlutterBackgroundAndroidConfig(
    notificationTitle: "EZ Light",
    notificationText: "EZ Light is running in the background",
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
      shakeThresholdGravity: sensitivity,
      minimumShakeCount: 1);

  Future<void> enableTorch() async {
    try {
      await TorchLight.enableTorch();
      lightOn = true;
    } on Exception catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> disableTorch() async {
    try {
      await TorchLight.disableTorch();
      lightOn = false;
    } on Exception catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<bool> isTorchAvailable() async {
    try {
      detector.startListening();
      return await TorchLight.isTorchAvailable();
    } on Exception catch (e) {
      debugPrint(e.toString());
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
        debugPrint(e.toString());
      }
    }
  }
}
