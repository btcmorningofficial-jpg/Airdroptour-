import 'dart:async';
import 'package:flutter/material.dart';

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
      if (!mounted) return;
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
      width: double.infinity,
      child: GestureDetector(
        onPanDown: (_) => _userInteracting = true,
        onPanCancel: () => _userInteracting = false,
        onPanEnd: (_) => _userInteracting = false,
        child: SingleChildScrollView(
          controller: _controller,
          scrollDirection: Axis.horizontal,
          child: Row(
            children: widget.children,
          ),
        ),
      ),
    );
  }
}
