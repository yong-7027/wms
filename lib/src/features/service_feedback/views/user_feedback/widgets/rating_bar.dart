import 'package:flutter/material.dart';
import '../../../../../utils/constants/colors.dart';

class RatingBar extends StatelessWidget {
  const RatingBar({
    super.key,
    required this.rating,
    this.size = 20,
    this.itemCount = 5,
    this.color = TColors.warning,
  });

  final double rating;
  final double size;
  final int itemCount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(itemCount, (index) {
        return Icon(
          index < rating.floor()
              ? Icons.star
              : (index < rating.ceil() && rating - index > 0.5)
              ? Icons.star_half
              : Icons.star_border,
          color: index < rating ? color : TColors.grey,
          size: size,
        );
      }),
    );
  }
}