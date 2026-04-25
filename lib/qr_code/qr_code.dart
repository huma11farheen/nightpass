import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';

class QRCodeGenerator extends StatelessWidget {
  final String data;
  final double height;

  const QRCodeGenerator(this.data, {super.key, required this.height});

  @override
  Widget build(BuildContext context) {
    return  Center(
      child: Consumer(
        builder: (context, ref, _) => SizedBox(
          height: height,
          child: PrettyQrView.data(
            decoration: const PrettyQrDecoration(
              shape:
              PrettyQrSmoothSymbol(color: Colors.black),
            ),
            data: data,
          ),
        ),
      ),
    );
  }
}
