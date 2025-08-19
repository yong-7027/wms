import 'package:flutter/material.dart';

import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/helpers/helper_functions.dart';

class OnBoardingPage extends StatelessWidget {
  const OnBoardingPage({
    super.key,
    required this.image,
    required this.title,
    required this.subTitle,
    required this.counter,
    this.bgColor = TColors.white,
  });

  final String image, title, subTitle, counter;
  final Color bgColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(TSizes.defaultSpace),
      color: bgColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        mainAxisSize: MainAxisSize.max,
        // max - 尽可能占满父容器的空间, min - 只占用子组件所需的最小空间
        children: [
          Image(
            width: THelperFunctions.screenWidth() * 0.8,
            height: THelperFunctions.screenHeight() * 0.4,
            image: AssetImage(image),
          ),
          Column(children: [
            Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: TSizes.spaceBtwItems,
            ),
            Text(
              subTitle,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ]),
          // Text(
          //   counter,
          //   style: Theme.of(context)
          //       .textTheme
          //       .bodyLarge!
          //       .apply(fontWeightDelta: 500),
          // ),
          const SizedBox(height: 80.0),
        ],
      ),
    );
  }
}
