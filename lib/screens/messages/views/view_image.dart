import 'package:flutter/material.dart';
import 'package:switchcalls/screens/callscreens/pickup/pickup_layout.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ViewImage extends StatelessWidget {
  final String imageUrl;
  final String noImageAvailable =
      "https://www.esm.rochester.edu/uploads/NoPhotoAvailable.jpg";
  const ViewImage({Key key, this.imageUrl})
      : assert(imageUrl != null),
        super(key: key);
  @override
  Widget build(BuildContext context) {
    return PickupLayout(
      scaffold: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          automaticallyImplyLeading: true,
          backgroundColor: Colors.black,
          elevation: 0.0,
        ),
        body: Center(
          child: Hero(
            tag: 'Picture',
            child: CachedNetworkImage(
              imageUrl: imageUrl ?? noImageAvailable,
              fit: BoxFit.cover,
              placeholder: (context, url) =>
                  Center(child: CircularProgressIndicator()),
              errorWidget: (context, url, error) =>
                  Container(color: Colors.red),
              // Image.network(noImageAvailable, fit: BoxFit.cover),
            ),
          ),
        ),
      ),
    );
  }
}
