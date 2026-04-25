import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class NomuCachedNetworkImage extends StatelessWidget {
  const NomuCachedNetworkImage({
    super.key,
    required this.imageUrl,
    this.needLoading = true,
    this.fit = BoxFit.fill,
  });

  final String imageUrl;
  final bool needLoading;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) => CachedNetworkImage(
    fadeInDuration: Duration.zero,
    fadeOutDuration: Duration.zero,
    imageUrl: imageUrl,
    fit: fit,
    errorWidget: (context, url, err) => const SizedBox.shrink(),
    placeholder: needLoading
        ? (context, url) =>  Center(
      child: Container(),
    )
        : null,
  );
}
