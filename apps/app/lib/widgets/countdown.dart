import 'dart:async';
import 'package:flutter/material.dart';

class Countdown extends StatefulWidget {
  final DateTime endAtUtc;
  const Countdown({super.key, required this.endAtUtc});

  @override
  State<Countdown> createState() => _CountdownState();
}

class _CountdownState extends State<Countdown> {
  late Timer _t;
  Duration _d = Duration.zero;

  @override
  void initState() {
    super.initState();
    _tick();
    _t = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    final now = DateTime.now().toUtc();
    setState(() {
      _d = widget.endAtUtc.difference(now);
      if (_d.isNegative) _d = Duration.zero;
    });
  }

  @override
  void dispose() {
    _t.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final d = _d.inDays;
    final h = _d.inHours.remainder(24);
    final m = _d.inMinutes.remainder(60);
    return Text(
      _d == Duration.zero ? 'Hết hạn' : 'HSD: ${d}d ${h}h ${m}m',
      style: const TextStyle(color: Colors.black54),
    );
  }
}
