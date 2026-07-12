import 'dart:async';
import 'package:flutter/material.dart';

// Anasayfadaki kripto listesini kendiliğinden, yavaşça kaydıran satır.
// Kullanıcı isterse manuel olarak da kaydırabilir (elini çekince
// otomatik kaydırma kaldığı yerden devam eder).
class AutoScrollCryptoRow extends StatefulWidget {
  final List<Widget> children;
  final double height;
  const AutoScrollCryptoRow({
    super.key,
    required this.children,
    this.height = 80,
  });

  @override
  State<AutoScrollCryptoRow> createState() => _AutoScrollCryptoRowState();
}

class _AutoScrollCryptoRowState extends State<AutoScrollCryptoRow> {
  final ScrollController _controller = ScrollController();
  Timer? _timer;
  bool _userInteracting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startAutoScroll());
  }

  void _startAutoScroll() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 40), (timer) {
      if (!_controller.hasClients || _userInteracting) return;
      final maxScroll = _controller.position.maxScrollExtent;
      if (maxScroll <= 0) return;
      double next = _controller.offset + 0.8;
      if (next >= maxScroll) {
        next = 0;
      }
      _controller.jumpTo(next);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollStartNotification &&
              notification.dragDetails != null) {
            _userInteracting = true;
          } else if (notification is ScrollEndNotification) {
            _userInteracting = false;
          }
          return false;
        },
        child: ListView(
          controller: _controller,
          scrollDirection: Axis.horizontal,
          children: widget.children,
        ),
      ),
    );
  }
}
