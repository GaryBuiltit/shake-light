import 'package:app/background_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:sizer/sizer.dart';

class SensitivtySlider extends StatelessWidget {
  const SensitivtySlider({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 60, right: 2),
      child: Slider(
          divisions: 20,
          label: Provider.of<BackgroundSevices>(context)
              .sensitivity
              .round()
              .toString(),
          value: Provider.of<BackgroundSevices>(context).sensitivity,
          max: 10,
          onChanged: (value) {
            try {
              Provider.of<BackgroundSevices>(context, listen: false)
                  .updateSensitivity(value);
            } catch (e) {
              debugPrint(e.toString());
            }
          }),
    );
  }
}
