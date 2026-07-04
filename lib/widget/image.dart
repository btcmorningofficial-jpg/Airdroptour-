import 'package:airdrop/theme/color.dart';
import 'package:airdrop/services/bybugdb_bridge.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'dart:typed_data';
import 'package:http/http.dart' as http;

String parseURL(String url) {
  if (url.contains("database.bybug.com.tr")) {
    String fileName = url.split("/")[url.split("/").length - 1];

    return "https://database.bybug.com.tr:6620/publicFile/${ByBugDB.token}/$fileName";
  } else {
    return url;
  }
}

class ImageNetworks extends StatefulWidget {
  final String urlsa;
  final BoxFit? fit;
  final double? width;
  final double? height;
  final Widget? placeholder;
  final Widget? errorWidget;

  const ImageNetworks(
    this.urlsa, {
    super.key,
    this.fit,
    this.width,
    this.height,
    this.placeholder,
    this.errorWidget,
  });

  @override
  State<ImageNetworks> createState() => _PersistentImageState();
}

class _PersistentImageState extends State<ImageNetworks> {
  static final Map<String, Uint8List> _cache = {};
  Uint8List? _bytes;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(ImageNetworks oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (parseURL(widget.urlsa) != parseURL(oldWidget.urlsa)) {
      _bytes = null;
      _error = false;
      _loadImage();
    }
  }

  Future<void> _loadImage() async {
    if (_cache.containsKey(parseURL(widget.urlsa))) {
      _bytes = _cache[parseURL(widget.urlsa)];
      if (mounted) setState(() {});
      return;
    }

    try {
      final response = await http.get(Uri.parse(parseURL(widget.urlsa)));
      if (response.statusCode == 200) {
        _bytes = response.bodyBytes;
        _cache[parseURL(widget.urlsa)] = _bytes!;
      } else {
        _error = true;
      }
    } catch (_) {
      _error = true;
    }

    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_bytes != null) {
      return Image.memory(
        _bytes!,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        gaplessPlayback: true,
      );
    } else if (_error) {
      return widget.errorWidget ??
          Icon(Icons.broken_image, size: widget.width ?? 40);
    } else {
      return widget.placeholder ??
          SizedBox(
            width: widget.width,
            height: widget.height,
            child: Center(
              child: CupertinoActivityIndicator(
                color: Colors.white.withOpacity(0.5),
                radius: 6,
              ),
            ),
          );
    }
  }
}

class AirdroptourImage extends StatelessWidget {
  final String name;
  final Color? color;
  final BoxFit? fit;
  final double? width;
  final double? height;
  final Widget? placeholder;
  final Widget? errorWidget;
  const AirdroptourImage(
    this.name, {
    super.key,
    this.fit,
    this.width,
    this.height,
    this.placeholder,
    this.errorWidget,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (name.startsWith("http")) {
      return ImageNetworks(
        name,
        errorWidget: errorWidget,
        fit: fit,
        height: height,
        placeholder: placeholder,
        width: width,
      );
    } else {
      if (name.isEmpty) {
        return SizedBox();
      } else {
        return Image.asset(
          name,
          errorBuilder: (context, error, stackTrace) {
            return errorWidget ??
                SizedBox(
                  width: width,
                  height: height,
                  child: Placeholder(color: defaultColor),
                );
          },
          fit: fit,
          height: height,
          width: width,
          color: color,
        );
      }
    }
  }
}
