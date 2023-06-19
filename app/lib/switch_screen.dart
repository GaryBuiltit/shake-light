import 'package:app/background_service.dart';
// import 'package:app/sensitivity_slider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class SwitchScreen extends StatefulWidget {
  const SwitchScreen({super.key});

  @override
  State<SwitchScreen> createState() => _SwitchScreenState();
}

class _SwitchScreenState extends State<SwitchScreen> {
  bool ezLightActive = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // appBar: AppBar(
      //   centerTitle: true,
      //   title: const Text('EZ Light'),
      // ),
      body: SafeArea(
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 8.h,
            ),
            Image.asset(
              'images/ez-light-Icon-white.png',
              // height: 50.h,
              width: 75.w,
              height: 30.h,
            ),
            // SizedBox(
            //   height: 5.h,
            // ),
            // const Text(
            //   "Shake Sensitivity",
            //   style: const TextStyle(
            //     color: Colors.black,
            //     fontSize: 22,
            //     fontWeight: FontWeight.bold,
            //   ),
            // ),
            // Row(
            //   children: [
            //     const SensitivtySlider(),
            //     Container(
            //       height: 25,
            //       width: 25,
            //       color: Colors.grey[200],
            //       child: Center(
            //         child: Text(Provider.of<BackgroundSevices>(context)
            //             .sensitivity
            //             .round()
            //             .toString()),
            //       ),
            //     )
            //   ],
            // ),
            const SizedBox(
              height: 40,
            ),
            Text(
              !ezLightActive ? 'Activate EZ Light' : 'Deactivate EZ Light',
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
                value: ezLightActive,
                onChanged: (bool value) async {
                  if (!ezLightActive) {
                    context.read<BackgroundSevices>().startBackground();
                    setState(() {
                      ezLightActive = value;
                    });
                  } else if (ezLightActive) {
                    context.read<BackgroundSevices>().stopBackground();
                    setState(() {
                      ezLightActive = value;
                    });
                  }
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
