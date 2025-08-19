import 'package:flutter/material.dart';

import '../../utils/constants/colors.dart';
import '../../utils/constants/sizes.dart';
import '../../utils/device/device_utility.dart';

class CircularLoader extends StatelessWidget {
  final String? message;

  const CircularLoader({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: TDeviceUtils.getScreenHeight() * 0.6,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: TColors.primary),
            SizedBox(height: TSizes.spaceBtwItems),
            Text(
              message ?? 'Loading ...',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: TColors.primary),
          SizedBox(height: TSizes.spaceBtwItems),
          Text(
            'Loading ...',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
