import 'dart:io';
import 'package:flutter/material.dart';

class PickImageContainer extends StatelessWidget {
  final Function onTap;
  final File image;
  final String imageUrl;

  PickImageContainer({
    @required this.onTap,
    @required this.image,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(
          color: Colors.black87,
          width: 2,
        )),
        width: 150,
        height: 150,
        child: image == null
            ? (imageUrl == null
                ? Center(
                    child: Text(
                      "Add a Image",
                    ),
                  )
                : Image.network(imageUrl))
            : Image.file(image),
      ),
    );
  }
}
