import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';

void showImageSourceBottomSheet(BuildContext context, Function(File) img) {
  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return Wrap(
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.camera),
            title: const Text('Camera'),
            onTap: () async {
              final image =
              await ImagePicker().pickImage(source: ImageSource.camera);
              if (image != null) {
                img(File(image.path));
              }

              if (context.mounted) {
                context.pop();
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Gallery'),
            onTap: () async {
              final image =
              await ImagePicker().pickImage(source: ImageSource.gallery);
              if (image != null) {
                img(File(image.path));
              }

              if (context.mounted) {
                context.pop();
              }
            },
          ),
        ],
      );
    },
  );
}
