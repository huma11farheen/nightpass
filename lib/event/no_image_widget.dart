import 'package:flutter/material.dart';

class NoImageWidget extends StatelessWidget {
  final String imageResource;
  final double? width;
  final double? height;

  const NoImageWidget.normal({super.key, 
    this.width,
    this.height,
  })  : imageResource = 'assets/images/common/other/picture_shop_no_image.png';

  const NoImageWidget.squared({super.key, 
    this.width,
    this.height,
  })  : imageResource =
  'assets/images/common/other/picture_shop_no_image_squared.png';

  @override
  Widget build(BuildContext context) {
    return Image.asset(
        imageResource,
        width: width,
        height: height,
        fit: BoxFit.cover,
    );
  }
}
